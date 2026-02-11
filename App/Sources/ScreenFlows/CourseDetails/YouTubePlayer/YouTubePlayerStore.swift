// Copyright © 2026 Pharos Solutions. All rights reserved.

import ComposableArchitecture
import Foundation
import UIKit

struct YouTubePlayer: Reducer {
    struct State: Equatable {
        @BindingState var isLoading: Bool = true
        @BindingState var bufferedTime: TimeInterval = .zero
        @BindingState var playedTime: TimeInterval = .zero
        @BindingState var videoDuration: TimeInterval = .zero
        @BindingState var isPlaying: Bool = true
        @BindingState var wasPlayingBeforeSeek: Bool = true
        @BindingState var userDidTogglePlay: Bool = false
        @BindingState var isControlsVisiable: Bool = true
        @BindingState var playbackRate: PlaybackRate = .normal
        @BindingState var availablePlaybackRates: [PlaybackRate] = [.normal]
        @BindingState var isRateChanged: Bool = false
        @BindingState var isEditingSlider: Bool = false
        @BindingState var isEdittingFinished: Bool = false
        @BindingState var shouldMinimize: Bool = false
        @BindingState var errorMessage: String?
        @BindingState var fastForward: Bool = false
        @BindingState var fastForwardAnimationIsActive: Bool = false
        @BindingState var rewind: Bool = false
        @BindingState var rewindAnimationIsActive: Bool = false
        @BindingState var didEnterForground: Bool = false
        @BindingState var didEnterBackground: Bool = false

        var videoURL: URL
        var videoYouTubeId: String?
        var dismissWebView: Bool = false
        var phoneNumber: String = ""
        var lastViewStatusBarStyle: UIStatusBarStyle = UIApplication.shared.statusBarStyle
        @PresentationState var alertState: AlertState<Action.Alert>?
    }

    @CasePathable
    enum Action: Equatable, BindableAction {
        enum Alert: Equatable {
            case navigateBack
        }
        case viewWillLoad
        case onDisappear
        case didEnterForground
        case didEnterbackground

        case changeSliderValue(isEditing: Bool)
        case sendPlayedTime
        case startTimer
        case stopTimer
        case binding(BindingAction<State>)
        case setIsPlaying
        case showControllers
        case fastForward
        case rewind

        // MARK: Screenshot
        case errorReceived(String)
        case alert(PresentationAction<Alert>)
    }
}
