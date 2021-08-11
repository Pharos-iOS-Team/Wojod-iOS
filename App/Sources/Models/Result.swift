// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum Result {
    case success(Decodable)
    case failure(WJError)
}
