// Copyright © 2026 Pharos Solutions. All rights reserved.

import ComposableArchitecture
import SwiftUI

public extension YouTubePlayerRepresentable {
    class Coordinator: NSObject, YTPlayerViewDelegate {
        var parent: YouTubePlayerRepresentable
        var wasMuted: Bool = false

        public init(parent: YouTubePlayerRepresentable) {
            self.parent = parent
        }

        public func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
            playerView.configureVideoPlaybackRestrictions()
            playerView.duration { [weak self] duration, error in
                if let error = error {
                    self?.parent.errorMessage = error.localizedDescription
                } else {
                    self?.parent.videoDuration = duration
                }
            }
            parent.isLoading = false
            playerView.loadVideoWithCurrentTime()
            if parent.didEnterBackground {
                playerView.pauseVideo()
            }
            if UIScreen.main.isCaptured {
                playerView.mute()
                wasMuted = true
            }
        }

        public func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float, bufferedTime bufferTime: Float) {
            playerView.playerState { state, _ in
                if !self.parent.isEditingSlider, !self.parent.isEdittingFinished, state != .buffering {
                    self.parent.playedTime = state == .ended ? self.parent.videoDuration : min(TimeInterval(playTime).rounded(.up), self.parent.videoDuration)
                    self.parent.bufferedTime = TimeInterval(bufferTime)
                }
            }
        }

        public func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
            parent.errorMessage = L10n.Shared.Alerts.youtubeError
            parent.isPlaying = false
            parent.isLoading = false
        }

        public func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
            switch state {
            case .paused:
                parent.isPlaying = false

            case .ended:
                parent.isPlaying = false
                parent.playedTime = parent.videoDuration

            case .playing:
                returnPlaybackRate(for: playerView)
                parent.isPlaying = true

            default:
                break
            }
        }

        public func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
            return UIColor.black
        }

        public func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
            parent.isLoading = true
            let swiftUIView = LoadingView()
            let hostingController = UIHostingController(rootView: swiftUIView)
            hostingController.view.backgroundColor = .black
            return hostingController.view
        }

        // MARK: Playback rate
        public func setPlaybackRate(for playerView: YTPlayerView, to rate: PlaybackRate) {
            playerView.setPlaybackRate(rate.rawValue)
            parent.isRateChanged = false
        }

        public func returnPlaybackRate(for playerView: YTPlayerView) {
            playerView.availablePlaybackRates { [weak self] availableRates, _ in
                let videoRates: [PlaybackRate] = (availableRates as? [Float])?.compactMap {
                    PlaybackRate(rawValue: $0)
                } ?? []
                if !videoRates.isEmpty {
                    self?.parent.availableRates = videoRates
                }
            }
        }
    }
}
