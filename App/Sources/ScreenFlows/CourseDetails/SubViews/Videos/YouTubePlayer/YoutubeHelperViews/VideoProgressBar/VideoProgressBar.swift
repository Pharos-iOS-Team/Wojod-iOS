// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct VideoProgressBar: View {
    var state: VideoProgressBarState
    var changeSliderAction: (Bool) -> Void

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background bar (dark gray)
                RoundedRectangle(cornerRadius: UIConstants.slightCornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geo.size.width, height: 4)

                // Buffered progress bar (white with opacity 50%)
                RoundedRectangle(cornerRadius: UIConstants.slightCornerRadius)
                    .fill(Color.white.opacity(0.5))
                    .padding(.leading, 1)
                    .frame(
                        width: geo.size.width * state.bufferedTime,
                        height: 4
                    )

                // Played progress bar (red)
                Slider(
                    value: state.$playedTime,
                    in: 0.0 ... state.videoDuration
                ) { editing in
                    changeSliderAction(editing)
                }
                .accentColor(.red)
                .background(Color.clear)
                .frame(width: geo.size.width)
            }
            .frame(height: 4)
            .animation(.linear(duration: 0.1), value: state.playedTime)
        }
        .frame(height: 4)
    }
}
