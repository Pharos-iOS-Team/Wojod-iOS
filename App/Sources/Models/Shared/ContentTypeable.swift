// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol ContentTypeable {
    var contentType: String? { get }
    var mappedContentType: DocumentContentType? { get }
}

extension ContentTypeable {
    var mappedContentType: DocumentContentType? {
        DocumentContentType(rawValue: contentType ?? "")
    }
}
