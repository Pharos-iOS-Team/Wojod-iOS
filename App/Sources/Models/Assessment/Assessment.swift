// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

struct Assessment: Codable {
    var id: Int?
    var title: String?
    var instructions: String?
    var passMark: Double?
    var studentMark: Double?
    var gradeFinal: Bool?
    var duration: Int?
    var started: Bool?
    var status: String?
    var type: String?
    var publishedAt: Date
    var numberOfQuesions: Int?
}

// MARK: - DomainModel

extension Assessment {
    var domainModel: AssessmentDomain {
        AssessmentDomain(
            id: id,
            title: title,
            publishedAt: publishedAt,
            type: AssessmentType(rawValue: type ?? "") ?? .assignment,
            status: AssessmentStatus(rawValue: status ?? "") ?? .closed
        )
    }
}
