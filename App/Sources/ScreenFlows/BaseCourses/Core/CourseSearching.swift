// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol CourseSearching {
    var searchText: String { get set }
    var isInSearchMode: Bool { get }
  mutating func updateSearchText(_ text: String)
}

extension CourseSearching {
    var isInSearchMode: Bool {
        return searchText.isValid
    }

  mutating func updateSearchText(_ text: String) {
        searchText = text
        if !text.isValid {
            // Reset pagination when clearing search
        }
    }
}
