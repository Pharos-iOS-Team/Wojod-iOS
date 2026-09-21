// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Materials: Codable {
    var quizzes: [Assessment]?
    var assignments: [Assessment]?
    var videos: [Video]?
    var documents: [Attachment]?
}

// MARK: - DomainModel
extension Materials {
    var domainModel: MaterialDomain {
        MaterialDomain(
            quizzes: quizzes?.map { $0.domainModel } ?? [],
            assignments: assignments?.map { $0.domainModel } ?? [],
            videos: videos?.map { $0.domainModel } ?? [],
            documents: documents?.map { $0.domainModel } ?? []
        )
    }
}
