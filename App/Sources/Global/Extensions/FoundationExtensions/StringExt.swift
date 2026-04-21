// Copyright © 2020 Pharos Solutions. All rights reserved.

import UIKit
import UniformTypeIdentifiers

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
        return NSLinguisticTagger.dominantLanguage(for: self) == "ar" ? .right : .left
    }

    var urlPathExtension: FileExtension {
        let fileExtension = NSURL(fileURLWithPath: self).pathExtension ?? ""
        guard let type = UTType(filenameExtension: fileExtension) else { return .other }

        if type.conforms(to: .image) {
            return .image
        } else if type.conforms(to: .movie) {
            return .video
        } else if type.conforms(to: .pdf) {
            return .pdf
        } else if type.conforms(to: .spreadsheet) {
            return .excel
        } else if type.conforms(to: .data) {
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

    func getYoutubeId() -> String? {
        let pattern = #"(?:(?<=v=|/videos/|embed/|youtu\.be/|/v/|/e/|/shorts/|/watch/)-?)([a-zA-Z0-9_-]{11})"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = self as NSString
        let results = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: nsString.length))

        if let range = results?.range(at: 1) {
            return nsString.substring(with: range)
        }
        return nil
    }

    // MARK: - Validation

    var isValid: Bool {
        return !isEmpty && !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isValidURL: Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }

    var isValidPhoneNumber: Bool {
        return isValid && count >= 11
    }

    var isValidEmail: Bool {
        let emailFormat = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return predicate.evaluate(with: self)
    }

    func isValidPassword(minLength: Int = 6) -> Bool {
        return count >= minLength
    }
}
