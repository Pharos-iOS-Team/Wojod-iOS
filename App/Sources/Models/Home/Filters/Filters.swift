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
    var academicYear: KeyValue?
    var subject: Subject?
    var field: KeyValue?

    var filterCount: Int {
        guard let level = academicLevel else { return 0 }

        let count = level == .schoolStudent ? 5 : 6
        return AppEnvironment.shouldHideOrganization ? 2 : count
    }

    mutating func reset() {
        self = .empty
    }
}
