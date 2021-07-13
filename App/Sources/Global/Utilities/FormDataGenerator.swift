// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum FormDataGenerator {
    static func getImagesFormData(images: [ImageAttachmentDetails], key: String) -> [Moya.MultipartFormData] {
        var formData = [Moya.MultipartFormData]()
        for attachment in images {
            let imageData = attachment.image.jpegData(compressionQuality: 0.5) ?? Data()
            let imgFormData = Moya.MultipartFormData(
                provider: .data(imageData),
                name: key,
                fileName: attachment.imageName,
                mimeType: attachment.mimeType
            )
            formData.append(imgFormData)
        }
        return formData
    }

    static func getFilesFormData(files: [URL], key: String) -> [Moya.MultipartFormData] {
        var formData = [Moya.MultipartFormData]()
        for file in files {
            if let fileData = try? Data(contentsOf: file) {
                let fileFormData = Moya.MultipartFormData(
                    provider: .data(fileData),
                    name: key,
                    fileName: file.lastPathComponent,
                    mimeType: file.mimeType
                )
                formData.append(fileFormData)
            }
        }
        return formData
    }

    static func getDictionaryFormData(requestDictionary: [String: Any]) -> [Moya.MultipartFormData] {
        var formDataArr = [Moya.MultipartFormData]()
        for (key, value) in requestDictionary {
            let dataOfValue = getDataFrom(value)
            let formData = Moya.MultipartFormData(provider: .data(dataOfValue), name: key)
            formDataArr.append(formData)
        }
        return formDataArr
    }

    static func getDataFrom(_ value: Any) -> Data {
        if let value = value as? String {
            return value.data(using: String.Encoding.utf8) ?? Data()
        } else if let value = value as? [String] {
            var valueData = Data()
            for string in value {
                valueData.append(string.data(using: String.Encoding.utf8) ?? Data())
            }
            return valueData
        } else {
            return Data()
        }
    }
}
