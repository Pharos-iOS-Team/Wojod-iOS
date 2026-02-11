// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import SFSafeSymbols
import SwiftUI

public extension Image {
    init?(_ name: String?) {
        guard let name = name else { return nil }
        self.init(name)
    }

    init?(systemSymbol name: SFSymbol?) {
        guard let name = name else { return nil }
        self.init(systemSymbol: name)
    }
}
