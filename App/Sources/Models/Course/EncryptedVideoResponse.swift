// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct EncryptedVideoResponse: Codable, Equatable {
    var otp: String?
    var playback: String?
    var updateId: Int?
    var guid: String?
    var libraryId: Int?
}
