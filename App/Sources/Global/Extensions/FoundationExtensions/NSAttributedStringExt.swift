// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

typealias DocumentType = NSAttributedString.DocumentType
typealias CharacterEncoding = String.Encoding

extension NSAttributedString {
    var newlinesTrimmed: NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        while
            !mutableAttributedString.string.isEmpty,
            let last = mutableAttributedString.string.unicodeScalars.last,
            CharacterSet.newlines.contains(last)
        {
            mutableAttributedString.deleteCharacters(in: NSRange(location: mutableAttributedString.length - 1, length: 1))
        }
        return mutableAttributedString
    }

    convenience init(data: Data, documentType: DocumentType, encoding: CharacterEncoding = .utf8) throws {
        try self.init(
            data: data,
            options: [.documentType: documentType, .characterEncoding: encoding.rawValue],
            documentAttributes: nil
        )
    }
}
