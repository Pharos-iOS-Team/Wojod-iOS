// Copyright © 2026 Pharos Solutions. All rights reserved.

import AVFAudio
import ComposableArchitecture
import Foundation
import MediaPlayer
import UIKit

extension YouTubePlayer {
    enum CancelID {
        case cancelTimer
        case cancelAnimationTimer
    }

    var body: some Reducer<State, Action> {
        CombineReducers {
            BindingReducer()
            Reduce { state, action in
                switch action {
                case .viewWillLoad:
                    UIApplication.shared.statusBarStyle = .lightContent
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                    state.phoneNumber = User.shared.mobileNumber ?? ""
                    if let youtubeId = state.videoURL.absoluteString.getYoutubeId() {
                        state.videoYouTubeId = youtubeId
                    } else {
                        state.isLoading = false
                        state.isPlaying = false
                        return .send(.errorReceived(L10n.Shared.Alerts.youtubeError))
                    }

                case .didEnterForground:
                    state.didEnterForground = true
                    state.isControlsVisiable = true
                    return .send(.stopTimer)

                case .didEnterbackground:
                    state.didEnterBackground = true

                case .onDisappear:
                    state.dismissWebView = true
                    UIApplication.shared.statusBarStyle = state.lastViewStatusBarStyle

                case .sendPlayedTime:
                    return .none // TODO: send playtime

                case .binding(\.$errorMessage):
                    guard let errorMessage = state.errorMessage else { return .none }
                    return .send(.errorReceived(errorMessage))

                case .binding(\.$isPlaying):
                    if state.isPlaying {
                        return .send(.startTimer)
                    } else {
                        return .send(.stopTimer)
                    }

                case .binding(\.$playbackRate):
                    state.isRateChanged = true

                case .startTimer:
                    if state.isPlaying {
                        return .run { send in
                            while true {
                                try await Task.sleep(seconds: 4)
                                await  send(.binding(.set(\.$isControlsVisiable, false)))
                            }
                        }
                        .cancellable(id: CancelID.cancelTimer, cancelInFlight: true)
                    }

                case .stopTimer:
                    return .cancel(id: CancelID.cancelTimer)

                case .setIsPlaying:
                    state.isPlaying.toggle()
                    state.userDidTogglePlay = true

                case let .changeSliderValue(isEditing):
                    state.isEditingSlider = isEditing
                    if isEditing {
                        state.wasPlayingBeforeSeek = state.isPlaying
                        return .send(.stopTimer)
                    } else {
                        state.isEdittingFinished = true
                        return .send(.startTimer)
                    }

                case .showControllers:
                    if !state.rewindAnimationIsActive && !state.fastForwardAnimationIsActive {
                        state.isControlsVisiable.toggle()
                        if state.isPlaying && state.isControlsVisiable {
                            return .send(.startTimer)
                        }
                    }

                case .fastForward:
                    state.isControlsVisiable = true
                    state.fastForward = true
                    state.fastForwardAnimationIsActive = true
                    state.rewind = false
                    state.rewindAnimationIsActive = false
                    return .merge(
                        .cancel(id: CancelID.cancelAnimationTimer),
                        .send(.stopTimer),
                        .send(.startTimer),
                        .run { send in
                            try await DispatchQueue.main.sleep(for: .seconds(1))
                            await send(.binding(.set(\.$fastForwardAnimationIsActive, false)))
                        }
                            .cancellable(id: CancelID.cancelAnimationTimer, cancelInFlight: true)
                    )

                case .rewind:
                    state.isControlsVisiable = true
                    state.rewind = true
                    state.rewindAnimationIsActive = true
                    state.fastForward = false
                    state.fastForwardAnimationIsActive = false
                    return .merge(
                        .cancel(id: CancelID.cancelAnimationTimer),
                        .send(.stopTimer),
                        .send(.startTimer),
                        .run { send in
                            try await DispatchQueue.main.sleep(for: .seconds(1))
                            await send(.binding(.set(\.$rewindAnimationIsActive, false)))
                        }
                            .cancellable(id: CancelID.cancelAnimationTimer, cancelInFlight: true)
                    )

                case .alert(.presented(.navigateBack)):
                    state.dismissWebView = true
                    state.shouldMinimize = true

                case .alert(.dismiss):
                    state.alertState = nil

                case let .errorReceived(error):
                    state.alertState = .init(message: error) {
                        ButtonState(action: .send(.navigateBack)) {
                            TextState(L10n.Global.Actions.ok)
                        }
                    }

                case .binding:
                    break
                }
                return .none
            }
        }
    }
}
