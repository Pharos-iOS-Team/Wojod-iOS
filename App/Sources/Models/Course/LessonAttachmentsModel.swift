// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct LessonAttachmentsModel: Codable {
    var quizzes: [Assessment]?
    var assignments: [Assessment]?
    var videos: [Video]?
    var documents: [Attachment]?
}
