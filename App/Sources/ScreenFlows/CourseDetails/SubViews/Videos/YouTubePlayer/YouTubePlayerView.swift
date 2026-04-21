// Copyright © 2026 Pharos Solutions. All rights reserved.

import ComposableArchitecture
import SwiftUI
import WebKit

struct YouTubePlayerView: View {
    @Environment(\.dismiss)
    var dismiss: DismissAction

    @Environment(\.scenePhase)
    var scenePhase: ScenePhase

    @State private var playTimer = Timer.publish(every: .seconds(5), on: .main, in: .common).autoconnect()
    var store: StoreOf<YouTubePlayer>

    init(store: StoreOf<YouTubePlayer>) {
        self.store = store
    }

    var body: some View {
        Group {
            WithViewStore(store, observe: { $0 }) { viewStore in
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        ZStack(alignment: .topLeading) {
                            if let videoYouTubeId = viewStore.videoYouTubeId {
                                YouTubePlayerRepresentable(
                                    videoId: videoYouTubeId,
                                    isLoading: viewStore.$isLoading,
                                    didEnterForground: viewStore.$didEnterForground,
                                    didEnterBackground: viewStore.$didEnterBackground,
                                    playedTime: viewStore.$playedTime,
                                    bufferedTime: viewStore.$bufferedTime,
                                    errorMessage: viewStore.$errorMessage,
                                    videoDuration: viewStore.$videoDuration,
                                    isPlaying: viewStore.$isPlaying,
                                    wasPlayingBeforeSeek: viewStore.$wasPlayingBeforeSeek,
                                    userDidTogglePlay: viewStore.$userDidTogglePlay,
                                    dismissWebView: viewStore.dismissWebView,
                                    isRateChanged: viewStore.$isRateChanged,
                                    availableRates: viewStore.$availablePlaybackRates,
                                    playbackRate: viewStore.playbackRate,
                                    isEditingSlider: viewStore.isEditingSlider,
                                    isEdittingFinished: viewStore.$isEdittingFinished,
                                    fastForward: viewStore.$fastForward,
                                    rewind: viewStore.$rewind,
                                    isMuted: viewStore.$isMuted
                                )
                                .ignoresSafeArea()
                                .watermark( /// Add watermark when video is displayed
                                    viewStore.phoneNumber,
                                    hideWatermark: viewStore.$isLoading
                                )
                            }

                            // Fastforward/Rewind layer
                            ZStack {
                                Color.black.opacity(0.0001)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(.rect)
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        viewStore.send(.showControllers)
                                    }

                                HStack(spacing: 0) {
                                    DoubleTapControlView(
                                        state: .init(
                                            width: geometry.size.width,
                                            isActive: viewStore.$rewindAnimationIsActive,
                                            roundedCorners: [.topRight, .bottomRight]
                                        ),
                                        singleTapAction: { viewStore.send(.showControllers) },
                                        doubleTapAction: { viewStore.send(.rewind) }
                                    )

                                    Spacer()

                                    DoubleTapControlView(
                                        state: .init(
                                            width: geometry.size.width,
                                            isActive: viewStore.$fastForwardAnimationIsActive,
                                            roundedCorners: [.topLeft, .bottomLeft]
                                        ),
                                        singleTapAction: { viewStore.send(.showControllers) },
                                        doubleTapAction: { viewStore.send(.fastForward) }
                                    )
                                }
                            }
                            // Control bar
                            YouTubeControlsView(
                                geometry: geometry,
                                playedTime: viewStore.$playedTime,
                                bufferedTime: viewStore.$bufferedTime,
                                isPlaying: viewStore.$isPlaying,
                                userDidTogglePlay: viewStore.$userDidTogglePlay,
                                playbackRate: viewStore.$playbackRate,
                                availablePlaybackRates: viewStore.availablePlaybackRates,
                                videoDuration: viewStore.videoDuration,
                                changeSliderAction: { isEditing in viewStore.send(.changeSliderValue(isEditing: isEditing)) },
                                startTimerAction: { viewStore.send(.startTimer) },
                                stopTimerAction: { viewStore.send(.stopTimer) },
                                isLandscape: viewStore.$isLandscape,
                                toggleOrientationAction: { viewStore.send(.toggleOrientation) }
                            )
                            .isHidden(!viewStore.isControlsVisiable || viewStore.isLoading)

                            // Exit button
                            Button {
                                viewStore.send(.onDisappear)
                                dismiss()
                            } label: {
                                VStack {
                                    Image(systemSymbol: .xmark)
                                        .foregroundColor(Color.gray)
                                        .font(.title)
                                }
                                .padding(7)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                                .contentShape(Circle())
                            }
                            .padding(.leading, geometry.size.height > geometry.size.width ? 30 : 45)
                            .padding(.top, geometry.size.height > geometry.size.width ? 65 : 45)
                            .isHidden(!viewStore.isControlsVisiable)
                        }

                        // Play/Pause button
                        PlayPauseButton(state: .init(
                            isPlaying: viewStore.$isPlaying
                        )) {
                            viewStore.send(.setIsPlaying)
                        }
                        .isHidden(!viewStore.isControlsVisiable || viewStore.isLoading || viewStore.isEditingSlider)
                    }
                    .ignoresSafeArea()
                    .environment(\.layoutDirection, .leftToRight)
                    .background(.black)
                    .onReceive(playTimer) { _ in
                        viewStore.send(.sendPlayedTime)
                    }
                    .navigationBarHidden(true)
                    .onLoad {
                        viewStore.send(.viewWillLoad)
                    }
                    .onWillDisappear {
                        viewStore.send(.onDisappear)
                    }
                    .alert(
                        store: self.store.scope(
                            state: \.$alertState
                        ) { .alert($0) }
                    )
                    .onChange(of: viewStore.shouldMinimize) { shouldMinimize in
                        if shouldMinimize {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onChange(of: scenePhase) {  newPhase in
            if newPhase == .active {
                store.send(.didEnterForground)
            } else if newPhase == .background {
                store.send(.didEnterbackground)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            store.send(.binding(.set(\.$isMuted, UIScreen.main.isCaptured)))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            store.send(.binding(.set(\.$isLandscape, UIDevice.current.orientation.isLandscape)))
        }
    }
}
