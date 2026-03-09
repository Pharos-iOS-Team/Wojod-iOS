// Copyright © 2026 Pharos Solutions. All rights reserved.

import ComposableArchitecture
import Foundation

extension AlertState {
    init(
        title: String = "",
        message: String,
        @ButtonStateBuilder<Action> actions: @escaping () -> [ComposableArchitecture.ButtonState<Action>]
    ) {
        self.init(title: { TextState(title) }, actions: actions, message: { TextState(message) })
    }
}
