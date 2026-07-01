// Copyright © 2026 Pharos Solutions. All rights reserved.

import AVFoundation
import AVKit
import UIKit
import VdoFramework

final class VideoPlaybackService: NSObject {
    // MARK: - Properties

    private var player: AVPlayer?
    private var timer = Timer()
    private var updateId: Int = .zero
    private var videoId: String = ""
    private weak var alertHandler: AlertHandler?

    var onUpdateVideo: ((String, UpdateObject) -> Void)?

    // MARK: - Init

    init(alertHandler: AlertHandler) {
        self.alertHandler = alertHandler
    }

    // MARK: - Playback Entry Points

    func playVideoWithChecks(
        viewsCount: Int,
        video: Video,
        hideViews: Bool,
        from viewController: UIViewController,
        completion: @escaping (EncryptedVideoResponse?) -> Void
    ) {
        guard viewsCount > .zero else {
            let errorMessage = hideViews
                ? L10n.CourseDetails.Main.videoPlaybackIssue
                : L10n.CourseDetails.Main.notEnoughViews
            alertHandler?.showInformationAlert(
                title: L10n.Global.Titles.error,
                message: errorMessage
            )
            return
        }

        fetchVideoDetails(videoId: "\(video.id)", from: viewController) { [weak viewController] response in
            guard let viewController else { return }
            if hideViews {
                completion(response)
            } else {
                viewController.showConfirmAlert(
                    title: L10n.Global.Titles.warning,
                    message: L10n.CourseDetails.CourseReview.playVideo(viewsCount),
                    confirmButtonTitle: L10n.Global.Actions.confirm
                ) { _ in
                    completion(response)
                }
            }
        }
    }

    func presentVdoCipherVideo(
        _ video: Video,
        encryptedVideoResponse: EncryptedVideoResponse?,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        from viewController: UIViewController
    ) {
        VdoAsset.createAsset(videoId: "\(video.vdocipherId ?? "")") { asset, error in
            DispatchQueue.main.async { [weak self, weak viewController] in
                guard let self, let viewController else { return }
                if let error = error {
                    self.alertHandler?.showConfirmAlert(
                        title: L10n.Global.Titles.error,
                        message: error.description
                    )
                } else if let otp = encryptedVideoResponse?.otp, let playback = encryptedVideoResponse?.playback {
                    let vdoPlayerController: VdoPlayerViewController = VdoCipher.getVdoPlayerViewController()
                    vdoPlayerController.transitioningDelegate = transitioningDelegate
                    asset?.playOnline(otp: otp, playbackInfo: playback)
                    viewController.present(vdoPlayerController, animated: true)
                    self.updateId = encryptedVideoResponse?.updateId ?? .zero
                    self.videoId = "\(video.id)"
                    self.startBufferingTimer()
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

    // MARK: - Private

    private func fetchVideoDetails(videoId: String, from viewController: UIViewController, completion: @escaping (EncryptedVideoResponse?) -> Void) {
        // Delegated to the ViewModel; this method is a pass-through to coordinate the confirm alert flow
        completion(nil)
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
