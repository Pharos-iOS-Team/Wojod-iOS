// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct PlayPauseButtonState {
    @Binding var isPlaying: Bool
    let buttonSize: CGFloat
    let iconColor: Color

    public init(
        isPlaying: Binding<Bool>,
        buttonSize: CGFloat = 55,
        iconColor: Color = Color.gray
    ) {
        self.buttonSize = buttonSize
        self.iconColor = iconColor
        self._isPlaying = isPlaying
    }
}
