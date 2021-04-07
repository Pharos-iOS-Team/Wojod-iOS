// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

extension Array where Element == String {
    var commaSeparatedString: String {
        return joined(separator: ", ")
    }
}

extension Array where Element: Equatable {
    func index(of element: Element?) -> Int? {
        guard let element = element else { return nil }
        return firstIndex(of: element)
    }
}
