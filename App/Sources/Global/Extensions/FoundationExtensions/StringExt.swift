// Copyright © 2020 Pharos Solutions. All rights reserved.

import MobileCoreServices
import UIKit

extension String {
    var enToArDigits: String {
        let arabicNumbers = [
            "0": "٠",
            "1": "١",
            "2": "٢",
            "3": "٣",
            "4": "٤",
            "5": "٥",
            "6": "٦",
            "7": "٧",
            "8": "٨",
            "9": "٩"
        ]
        var txt = self
        _ = arabicNumbers.map {
            txt = txt.replacingOccurrences(of: $0, with: $1)
        }
        return txt
    }

    var dominantTextAlignment: NSTextAlignment {
        return NSLinguisticTagger.dominantLanguage(for: self) == "ar"
            ? .right
            : .left
    }

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

    func englishToArabicText() -> String {
        let arabicNumbers = ["٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4", "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"]
        var text = self
        _ = arabicNumbers.map { text = text.replacingOccurrences(of: $1, with: $0) }
        return text
    }

    func dashed() -> String {
        var result = ""
        for (offset, character) in self.enumerated() {
            if offset != 0 && offset % 4 == 0 {
                result.append("-")
            }
            result.append(character)
        }
        return result
    }

    func size(withAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> CGSize {
        return (self as NSString).size(withAttributes: attrs)
    }
}
