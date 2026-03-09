// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public extension View {
    /// Hide or show the view based on a boolean value.
    @ViewBuilder
    func isHidden(_ hidden: Bool, remove: Bool = true) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

    func tapGesture(
        onSingleTap: @escaping () -> Void,
        onDoubleTap: @escaping () -> Void
    ) -> some View {
        self.onTapGesture {
            onSingleTap()
        }
        .simultaneousGesture(TapGesture(count: 2)
            .onEnded { _ in onDoubleTap() })
    }
}
