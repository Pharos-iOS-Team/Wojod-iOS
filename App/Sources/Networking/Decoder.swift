// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

enum Decoder {
    static func decode<T: Decodable>(modelType: T.Type, from data: Data) -> (data: T?, catchedError: String?) {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(modelType, from: data)
            return (decodedData, nil)
        } catch {
            return (nil, L10n.Global.Alerts.somethingWentWrong)
        }
    }
}
