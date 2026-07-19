// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI
import WebKit

struct YouTubeControlsView: View {
    var geometry: GeometryProxy
    @Binding var playedTime: TimeInterval
    @Binding var bufferedTime: TimeInterval
    @Binding var isPlaying: Bool
    @Binding var userDidTogglePlay: Bool
    @Binding var playbackRate: PlaybackRate
    var availablePlaybackRates: [PlaybackRate]
    var videoDuration: Double
    var changeSliderAction: (Bool) -> Void
    var startTimerAction: () -> Void
    var stopTimerAction: () -> Void
    @Binding var isLandscape: Bool
    var toggleOrientationAction: () -> Void

    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.4)
                    .frame(height: geometry.size.height > geometry.size.width ? 80 : 73, alignment: .bottom)

                VStack(alignment: .leading, spacing: 20) {
                    // slider for video playback
                    VideoProgressBar(
                        state: .init(
                            playedTime: $playedTime,
                            bufferedTime: $bufferedTime,
                            videoDuration: videoDuration
                        ),
                        changeSliderAction: changeSliderAction
                    )
                    // Play/Pause button
                    HStack(spacing: 15) {
                        Button(action: {
                            isPlaying.toggle()
                            userDidTogglePlay = true
                        }, label: {
                            Image(systemSymbol: isPlaying ? .pauseFill : .playFill)
                                .font(.title2)
                                .contentShape(Rectangle())
                                .accentColor(Color.gray.opacity(0.9))
                                .frame(width: 27)
                        })
                        // Playback time and total duration
                        Text("\(playedTime.formattedTime()) / \(videoDuration.formattedTime())")
                            .monospacedDigit()
                            .foregroundColor(Color.gray.opacity(0.9))
                            .font(.body.bold())

                        Spacer()

                        // Rate Menu
                        EquatableView(content: MenuView(
                            selectedOption: $playbackRate,
                            availableOptions: availablePlaybackRates,
                            startTimerAction: startTimerAction,
                            stopTimerAction: stopTimerAction,
                            selectorImage: Image(systemSymbol: .speedometer),
                            selectorImageFrame: 22
                        ))

                        // Full-screen button
                        Button(action: toggleOrientationAction) {
                            Image(systemSymbol: isLandscape ? .arrowDownRightAndArrowUpLeft : .arrowUpLeftAndArrowDownRight)
                                .font(.title2)
                                .contentShape(Rectangle())
                                .accentColor(Color.gray.opacity(0.9))
                                .frame(width: 27)
                        }
                        .isHidden(UIDevice.current.userInterfaceIdiom == .pad)
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.bottom, geometry.size.height > geometry.size.width ? 29 : 22)
                .padding(.horizontal, geometry.size.height > geometry.size.width ? 20 : 50)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
