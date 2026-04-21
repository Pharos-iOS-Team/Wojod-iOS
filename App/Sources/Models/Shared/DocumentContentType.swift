// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

enum DocumentContentType: String {
    case pdf = "application/pdf"
    case excel = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case word = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case imagePng = "image/png"
    case imageJpeg = "image/jpeg"
    case imageJpg = "image/jpg"
    case zip = "application/zip"

    var isImage: Bool {
        switch self {
        case .imagePng, .imageJpeg, .imageJpg:
            return true
        default:
            return false
        }
    }

    var icon: UIImage {
        switch self {
        case .pdf:
            return Images.pdfExtension.image
        case .excel:
            return Images.excelExtension.image
        case .word:
            return Images.wordExtension.image
        case .imagePng, .imageJpeg, .imageJpg:
            return Images.imageExtension.image
        case .zip:
            return Images.zipExtension.image
        }
    }
}
