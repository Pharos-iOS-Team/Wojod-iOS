// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    @Binding private var didLoad: Bool
    private let action: () -> Void

    init(didLoad: Binding<Bool>, perform action: @escaping () -> Void) {
        self.action = action
        self._didLoad = didLoad
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didLoad {
                    didLoad = true
                    action()
                }
            }
    }
}

public extension View {
    func onLoad(didLoad: Binding<Bool> = .constant(false), perform action: @escaping () -> Void) -> some View {
        modifier(ViewDidLoadModifier(didLoad: didLoad, perform: action))
    }
}
