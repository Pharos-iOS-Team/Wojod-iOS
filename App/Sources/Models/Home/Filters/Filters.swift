// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct FilterSelection {
    static var empty: FilterSelection {
        return FilterSelection()
    }

    var isDataBeingRetrieved: Bool = false
    var academicLevel: AcademicLevel?
    var academicType: KeyValue?
    var academicDivision: Division?
    var academicYear: Batch?
    var subject: Subject?
    var field: Specialization?

    mutating func reset() {
        self = .empty
    }
}
