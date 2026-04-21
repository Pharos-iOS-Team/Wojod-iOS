// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct SubmitAnswerRequestModel: Encodable {
    let deviceToken: String
    let questionId: Int?
    let choicesIds: [Int]?
    let freeTextAnswer: String?
    let ignoreAttachment: String

    init(
        deviceToken: String,
        questionId: Int?,
        choicesIds: [Int]?,
        freeTextAnswer: String?,
        ignoreAttachment: String
    ) {
        self.deviceToken = deviceToken
        self.questionId = questionId
        self.choicesIds = (choicesIds?.isEmpty == true) ? nil : choicesIds
        self.freeTextAnswer = freeTextAnswer
        self.ignoreAttachment = ignoreAttachment
    }
}
