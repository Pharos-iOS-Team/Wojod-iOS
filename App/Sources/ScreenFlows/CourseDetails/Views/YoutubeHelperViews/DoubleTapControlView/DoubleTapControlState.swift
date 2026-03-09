// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct DoubleTapControlState {
    let width: CGFloat
    @Binding var isActive: Bool
    let roundedCorners: UIRectCorner

    public init(
        width: CGFloat,
        isActive: Binding<Bool>,
        roundedCorners: UIRectCorner
    ) {
        self.width = width
        self._isActive = isActive
        self.roundedCorners = roundedCorners
    }
}
