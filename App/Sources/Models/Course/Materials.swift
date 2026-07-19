// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Materials: Codable {
    var quizzes: [Assessment]?
    var assignments: [Assessment]?
    var videos: [Video]?
    var documents: [Attachment]?

    mutating func sort() {
        quizzes?.sort { $0.publishedAt > $1.publishedAt }
        assignments?.sort { $0.publishedAt > $1.publishedAt }
        videos?.sort { $0.publishedAt ?? Date() > $1.publishedAt ?? Date() }
        documents?.sort {
            if let date1 = $0.publishedAt, let date2 = $1.publishedAt {
                return date1 > date2
            }
            return false
        }
    }
}

// MARK: - DomainModel
extension Materials {
    var domainModel: MaterialDomain {
        MaterialDomain(
            quizzes: quizzes?.sorted { $0.publishedAt > $1.publishedAt }.map { $0.domainModel } ?? [],
            assignments: assignments?.sorted { $0.publishedAt > $1.publishedAt }.map { $0.domainModel } ?? [],
            videos: videos?.sorted { ($0.publishedAt ?? Date()) > ($1.publishedAt ?? Date()) }.map { $0.domainModel } ?? [],
            documents: documents?.sorted { ($0.publishedAt ?? Date()) > ($1.publishedAt ?? Date()) }.map { $0.domainModel } ?? []
        )
    }
}
