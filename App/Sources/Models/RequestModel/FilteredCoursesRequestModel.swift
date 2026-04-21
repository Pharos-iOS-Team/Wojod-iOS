// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct FilteredCoursesRequestModel: Encodable {
    let isMyCourses: Bool
    let subjectID: Int?
    let batchID: Int
    let specializationID: Int?
}
