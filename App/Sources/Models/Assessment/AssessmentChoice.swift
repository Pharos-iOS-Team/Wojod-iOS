// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct AssessmentChoice: Codable {
    let id: Int32?
    let modelAnswer: Bool?
    let title: String?
    let fileName: String?
    let attachment: String?
    let attachmentType: String?
}
