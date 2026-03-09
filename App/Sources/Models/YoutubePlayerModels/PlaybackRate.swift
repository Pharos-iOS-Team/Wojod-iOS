// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

public enum PlaybackRate: Float, CaseIterable, Displayable {
    case verySlow = 0.25
    case slow = 0.5
    case moderate = 0.75
    case normal = 1.0
    case slightlyFast = 1.25
    case fast = 1.5
    case veryFast = 1.75
    case ultraFast = 2.0

    public var id: Float { self.rawValue }

    public var displayName: String {
        return "\(self.rawValue)x"
    }
}
