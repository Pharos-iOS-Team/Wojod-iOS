// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

extension JSONSerialization {
  enum SerializationError: Error {
    case typeMismatch
  }

  class func jsonDictionaryObject(with data: Data, options opt: ReadingOptions = []) throws -> [String: Any] {
    guard let json = try jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw SerializationError.typeMismatch
    }
    return json
  }
}
