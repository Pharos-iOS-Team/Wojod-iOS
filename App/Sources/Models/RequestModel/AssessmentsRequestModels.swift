// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct GetAssessmentsRequestModel: Encodable {
    let studentId: Int?
    let subjectId: Int?
}

struct SubmitAnswerRequestModel: Encodable {
    let deviceToken: String
    let questionId: Int?
    let choicesIds: [Int]?
    let freeTextAnswer: String?
    let ignoreAttachment: String

    enum CodingKeys: String, CodingKey {
        case deviceToken
        case questionId
        case choicesIds
        case freeTextAnswer
        case ignoreAttachment
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceToken, forKey: .deviceToken)
        try container.encode(questionId, forKey: .questionId)
        // Only encode choicesIds if it's not empty
        if let choicesIds = choicesIds, !choicesIds.isEmpty {
            try container.encode(choicesIds, forKey: .choicesIds)
        }
        try container.encode(freeTextAnswer, forKey: .freeTextAnswer)
        try container.encode(ignoreAttachment, forKey: .ignoreAttachment)
    }
}
