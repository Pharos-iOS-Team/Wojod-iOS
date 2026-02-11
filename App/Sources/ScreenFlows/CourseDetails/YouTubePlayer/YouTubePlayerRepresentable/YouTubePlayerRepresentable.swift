// Copyright © 2026 Pharos Solutions. All rights reserved.

import ComposableArchitecture
import HandyUIKit
import SwiftUI

public struct YouTubePlayerRepresentable: UIViewControllerRepresentable {
    var videoId: String
    @Binding var isLoading: Bool
    @Binding var didEnterForground: Bool
    @Binding var didEnterBackground: Bool
    @Binding var playedTime: TimeInterval
    @Binding var bufferedTime: TimeInterval
    @Binding var errorMessage: String?
    @Binding var videoDuration: TimeInterval
    @Binding var isPlaying: Bool
    @Binding var wasPlayingBeforeSeek: Bool
    @Binding var userDidTogglePlay: Bool
    @Binding var isRateChanged: Bool
    @Binding var availableRates: [PlaybackRate]
    var dismissWebView: Bool
    var playbackRate: PlaybackRate
    var isEditingSlider: Bool
    @Binding var isEdittingFinished: Bool
    @Binding var fastForward: Bool
    @Binding var rewind: Bool

    var playerVars: [String: Any] = [
        "autoplay": 1,
        "fs": 0,
        "controls": 0,
        "playsinline": 1,
        "enablejsapi": 1,
        "rel": 0,
        "iv_load_policy": 3,
        "cc_load_policy": 0
    ]

    public init(
        videoId: String,
        isLoading: Binding<Bool>,
        didEnterForground: Binding<Bool>,
        didEnterBackground: Binding<Bool>,
        playedTime: Binding<TimeInterval>,
        bufferedTime: Binding<TimeInterval>,
        errorMessage: Binding<String?>,
        videoDuration: Binding<TimeInterval>,
        isPlaying: Binding<Bool>,
        wasPlayingBeforeSeek: Binding<Bool>,
        userDidTogglePlay: Binding<Bool>,
        dismissWebView: Bool,
        isRateChanged: Binding<Bool>,
        availableRates: Binding<[PlaybackRate]>,
        playbackRate: PlaybackRate,
        isEditingSlider: Bool,
        isEdittingFinished: Binding<Bool>,
        fastForward: Binding<Bool>,
        rewind: Binding<Bool>
    ) {
        self.videoId = videoId
        self._isLoading = isLoading
        self._didEnterForground = didEnterForground
        self._didEnterBackground = didEnterBackground
        self._playedTime = playedTime
        self._bufferedTime = bufferedTime
        self._errorMessage = errorMessage
        self._videoDuration = videoDuration
        self._isPlaying = isPlaying
        self._wasPlayingBeforeSeek = wasPlayingBeforeSeek
        self._userDidTogglePlay = userDidTogglePlay
        self._availableRates = availableRates
        self._isRateChanged = isRateChanged
        self.playbackRate = playbackRate
        self.isEditingSlider = isEditingSlider
        self._isEdittingFinished = isEdittingFinished
        self.dismissWebView = dismissWebView
        self._fastForward = fastForward
        self._rewind = rewind
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let playerViewCtrl = UIViewController()
        let playerView = YTPlayerView()
        playerView.delegate = context.coordinator

        // Add the player view to the controller’s view hierarchy
        playerViewCtrl.view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.bindEdgesToSuperview()
        playerView.load(withVideoId: videoId, playerVars: playerVars)
        return playerViewCtrl
    }

    // swiftlint:disable function_body_length
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let playerView = uiViewController.view.subviews.first(where: { $0 is YTPlayerView }) as? YTPlayerView else {
            return
        }

        /// Handle view did return to forground
        if didEnterForground {
            didEnterBackground = false
            playerView.playerState { state, _ in
                if state == .unstarted {
                    playerView.loadVideoWithCurrentTime()
                    playerView.pauseVideo()
                }
            }
            didEnterForground = false
        }

        /// Handle view dismissal
        if dismissWebView {
            playerView.stopVideo()
            playerView.removeWebView()
            isPlaying = false
        }

        /// Handle fast-forward (skip forward 10 seconds)
        if fastForward {
            let seekToTime = min(playedTime + 10, videoDuration)
            playerView.seek(toSeconds: Float(seekToTime), allowSeekAhead: true)
            playedTime = seekToTime
            fastForward = false
        }

        /// Handle rewind (skip backward 10 seconds)
        if rewind {
            let seekToTime = max(playedTime - 10, 0)
            playerView.seek(toSeconds: Float(seekToTime), allowSeekAhead: true)
            playedTime = seekToTime
            rewind = false
        }

        /// Handle play/pause state changes
        if userDidTogglePlay {
            if isPlaying {
                playerView.playVideo()
            } else {
                playerView.pauseVideo()
            }
            userDidTogglePlay = false
        }

        /// Change playback rate
        if isRateChanged {
            context.coordinator.setPlaybackRate(for: playerView, to: playbackRate)
        }

        /// Seek To
        if isEditingSlider {
            isPlaying = false
            playerView.pauseVideo()
            playerView.seek(toSeconds: Float(playedTime), allowSeekAhead: true)
        } else if isEdittingFinished {
            playerView.seek(toSeconds: Float(playedTime), allowSeekAhead: true)
            if playedTime != videoDuration {
                isPlaying = wasPlayingBeforeSeek
                if isPlaying {
                    playerView.playVideo()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isEdittingFinished = false
            }
        }
    }
    // swiftlint:enable function_body_length

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}
