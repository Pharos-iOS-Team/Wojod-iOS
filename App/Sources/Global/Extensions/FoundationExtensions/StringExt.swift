// Copyright © 2020 Pharos Solutions. All rights reserved.

import MobileCoreServices
import UIKit

extension String {
    var isValid: Bool {
        return !isEmpty && !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isValidURL: Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }

    var urlPathExtension: FileExtension {
        guard
            let fileExtension = NSURL(fileURLWithPath: self).pathExtension,
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        else { return .other }

        let inputUTI = uti.takeRetainedValue()
        if UTTypeConformsTo(inputUTI, kUTTypeImage) {
            return .image
        } else if UTTypeConformsTo(inputUTI, kUTTypeMovie) {
            return .video
        } else if UTTypeConformsTo(inputUTI, kUTTypePDF) {
            return .pdf
        } else if UTTypeConformsTo(inputUTI, kUTTypeSpreadsheet) {
            return .excel
        } else if UTTypeConformsTo(inputUTI, kUTTypeData) {
            return .word
        } else {
            return .other
        }
    }

    func convertHtml(size: CGFloat? = nil) -> NSAttributedString? {
        var data = Data(self.utf8)
        if let size = size {
            let modifiedFont = String(format: "<span style=\"font-size: \(size)\">%@</span>", self)
            data = modifiedFont.data(using: .unicode, allowLossyConversion: false) ?? Data()
        }
        return try? NSAttributedString(data: data, documentType: .html).newlinesTrimmed
    }
}
