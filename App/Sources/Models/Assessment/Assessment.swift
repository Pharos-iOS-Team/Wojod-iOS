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
    
    var mappedType: AssessmentType {
        AssessmentType(rawValue: type ?? "") ?? .assignment
    }
    
    var mappedStatus: AssessmentStatus {
        AssessmentStatus(rawValue: status ?? "") ?? .closed
    }
}
