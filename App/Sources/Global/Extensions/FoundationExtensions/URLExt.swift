// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UniformTypeIdentifiers

extension URL {
    var mimeType: String {
        return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }

    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.contentTypeKey]))?.contentType?.identifier
    }

    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
