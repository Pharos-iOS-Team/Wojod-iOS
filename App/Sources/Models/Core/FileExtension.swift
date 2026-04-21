// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum FileExtension {
    case image
    case video
    case pdf
    case excel
    case word
    case other

    func getImageNameForExtension() -> String {
        switch self {
        case .image:
            return Images.imageExtension.name
        case .video:
            return Images.videoExtension.name
        case .word:
            return Images.wordExtension.name
        case .pdf:
            return Images.pdfExtension.name
        case .excel:
            return Images.excelExtension.name
        case .other:
            return Images.unknownExtension.name
        }
    }
}
