// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import MobileCoreServices

extension URL {
    var mimeType: String {
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue()
        if let uti = uti, let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimetype as String
        }
        return "application/octet-stream"
    }
}
