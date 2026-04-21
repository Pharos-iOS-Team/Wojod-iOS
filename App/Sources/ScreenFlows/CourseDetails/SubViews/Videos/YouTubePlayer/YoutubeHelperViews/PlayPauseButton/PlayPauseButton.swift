// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct PlayPauseButton: View {
    let state: PlayPauseButtonState
    let action: () -> Void

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: state.buttonSize, height: state.buttonSize)

            Image(systemSymbol: state.isPlaying ? .pauseFill : .playFill)
                .font(.title)
                .contentShape(Rectangle())
                .foregroundColor(Color.gray)
                .frame(width: 25)
        }
        .contentShape(Circle())
        .onTapGesture {
            action()
        }
    }
}
