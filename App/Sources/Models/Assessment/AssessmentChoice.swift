// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

struct AssessmentChoice: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, title, attachment
        case modelAnswer = "model_answer"
        case fileName = "file_name"
        case attachmentType = "attachment_type"
    }

    let id: Int32?
    let modelAnswer: Bool?
    let title, fileName, attachment, attachmentType: String?
}
