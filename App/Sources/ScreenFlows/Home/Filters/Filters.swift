// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

final class Filters {
    static let shared = Filters()

    var isDataBeingRetrieved: Bool = false
    var academicLevel: AcademicLevel?
    var academicType: KeyValue?
    var academicDivision: Division?
    var academicYear: Batch?
    var subject: Subject?
    var field: Specialization?
}
