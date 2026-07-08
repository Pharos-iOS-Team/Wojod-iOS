// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

final class AcademicInfo {
    static let shared = AcademicInfo()

    var educationalTypes: [KeyValue]?
    var divisions: [Division]?
    var batches: [KeyValue]?
    var specializations: [KeyValue]?

    private init(educationalTypes: [KeyValue]? = nil, divisions: [Division]? = nil, batches: [KeyValue]? = nil, specializations: [KeyValue]? = nil) {
        self.educationalTypes = educationalTypes
        self.divisions = divisions
        self.batches = batches
        self.specializations = specializations
    }
}
