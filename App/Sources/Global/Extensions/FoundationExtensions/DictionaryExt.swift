// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension Dictionary {
    func mergingKeepingCurrent(_ newDictionary: [Key: Value]) -> [Key: Value] {
        return merging(newDictionary) { current, _ in current }
    }
}
