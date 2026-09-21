// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct MaterialDomain {
    let quizzes: [AssessmentDomain]
    let assignments: [AssessmentDomain]
    let videos: [VideoDomain]
    let documents: [AttachmentDomain]

    var allMaterials: [MaterialItemProtocol] {
        quizzes + assignments + videos + documents
    }

    private var nonEmptySections: [[MaterialItemProtocol]] {
        [
            quizzes.map { $0 as MaterialItemProtocol },
            assignments.map { $0 as MaterialItemProtocol },
            videos.map { $0 as MaterialItemProtocol },
            documents.map { $0 as MaterialItemProtocol }
        ].filter { !$0.isEmpty }
    }

    var numberOfSections: Int {
        nonEmptySections.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard section < nonEmptySections.count else { return 0 }
        return nonEmptySections[section].count
    }

    func item(at indexPath: IndexPath) -> MaterialItemProtocol? {
        let sections = nonEmptySections
        guard indexPath.section < sections.count else { return nil }
        guard indexPath.row < sections[indexPath.section].count else { return nil }
        return sections[indexPath.section][indexPath.row]
    }
}
