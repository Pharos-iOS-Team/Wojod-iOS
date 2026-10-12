// Copyright © 2026 Pharos Solutions. All rights reserved.

import AVFoundation
import AVKit
import SwiftUI
import UIKit
import VdoFramework

final class VideoPlaybackService: NSObject {
    // MARK: - Properties

    private var player: AVPlayer?
    private var timer = Timer()
    private var updateId: Int = .zero
    private var videoId: String = ""
    private weak var alertHandler: AlertHandler?
    private var watermarkViewController: UIViewController?

    var onUpdateVideo: ((String, UpdateObject) -> Void)?

    // MARK: - Init

    init(alertHandler: AlertHandler) {
        self.alertHandler = alertHandler
    }

    // MARK: - Playback

    func presentVdoCipherVideo(
        _ video: VideoDomain,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        from viewController: UIViewController,
        fetchAction: @escaping (_ completion: @escaping (EncryptedVideoResponse?) -> Void) -> Void
    ) {
        let vdoPlayerController: VdoPlayerViewController = VdoCipher.getVdoPlayerViewController()
        vdoPlayerController.transitioningDelegate = transitioningDelegate
        vdoPlayerController.view.backgroundColor = .black

        let loadingHostingController = UIHostingController(rootView: LoadingView())
        loadingHostingController.view.backgroundColor = .clear
        loadingHostingController.view.translatesAutoresizingMaskIntoConstraints = false

        vdoPlayerController.addChild(loadingHostingController)
        vdoPlayerController.view.addSubview(loadingHostingController.view)

        NSLayoutConstraint.activate([
            loadingHostingController.view.centerXAnchor.constraint(equalTo: vdoPlayerController.view.centerXAnchor),
            loadingHostingController.view.centerYAnchor.constraint(equalTo: vdoPlayerController.view.centerYAnchor)
        ])
        loadingHostingController.didMove(toParent: vdoPlayerController)

        viewController.present(vdoPlayerController, animated: true) { [weak self] in
            guard let self = self else { return }

            fetchAction { response in
                VdoAsset.createAsset(videoId: "\(video.vdocipherId ?? "")") { asset, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.alertHandler?.showConfirmAlert(
                                title: L10n.Global.Titles.error,
                                message: error.description
                            ) { _ in
                                vdoPlayerController.dismiss(animated: true)
                            }
                        } else if let otp = response?.otp, let playback = response?.playback {
                            asset?.playOnline(otp: otp, playbackInfo: playback)
                            UIView.animate(withDuration: 0.3, animations: {
                                loadingHostingController.view.alpha = 0
                            }) { _ in
                                loadingHostingController.willMove(toParent: nil)
                                loadingHostingController.view.removeFromSuperview()
                                loadingHostingController.removeFromParent()

                                guard response?.watermarkEmbedded == false else { return }

                                let watermarkText = User.shared.mobileNumber ?? ""
                                let watermarkHostingController = UIHostingController(
                                    rootView: Color.clear.watermark(watermarkText)
                                )
                                watermarkHostingController.view.backgroundColor = .clear
                                watermarkHostingController.view.isUserInteractionEnabled = false
                                watermarkHostingController.view.translatesAutoresizingMaskIntoConstraints = false

                                self.watermarkViewController?.willMove(toParent: nil)
                                self.watermarkViewController?.view.removeFromSuperview()
                                self.watermarkViewController?.removeFromParent()

                                vdoPlayerController.addChild(watermarkHostingController)
                                vdoPlayerController.view.addSubview(watermarkHostingController.view)

                                NSLayoutConstraint.activate([
                                    watermarkHostingController.view.topAnchor.constraint(equalTo: vdoPlayerController.view.topAnchor),
                                    watermarkHostingController.view.bottomAnchor.constraint(equalTo: vdoPlayerController.view.bottomAnchor),
                                    watermarkHostingController.view.leadingAnchor.constraint(equalTo: vdoPlayerController.view.leadingAnchor),
                                    watermarkHostingController.view.trailingAnchor.constraint(equalTo: vdoPlayerController.view.trailingAnchor)
                                ])
                                watermarkHostingController.didMove(toParent: vdoPlayerController)
                                self.watermarkViewController = watermarkHostingController
                            }

                            self.updateId = response?.updateId ?? .zero
                            self.videoId = "\(video.id)"
                            self.startBufferingTimer()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Timer

    func startBufferingTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 60,
            target: self,
            selector: #selector(sendBufferUpdate),
            userInfo: nil,
            repeats: true
        )
    }

    func invalidateTimer() {
        timer.invalidate()
        player = nil
    }

    @objc
    private func sendBufferUpdate() {
        let updateObject = UpdateObject(
            updateId: updateId,
            totalBuffered: Int(player?.currentItem?.totalBuffer() ?? .zero)
        )
        onUpdateVideo?(videoId, updateObject)
    }

    // MARK: - Mute

    func updatePlayerMuteState() {
        player?.isMuted = UIScreen.main.isCaptured
    }
}

// MARK: - AssetPlaybackDelegate

extension VideoPlaybackService: AssetPlaybackDelegate {
    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        self.player = player
        player.play()
        player.isMuted = UIScreen.main.isCaptured
    }

    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        self.player = player
    }

    func streamLoadError(error: VdoFramework.VdoError) {}
}
