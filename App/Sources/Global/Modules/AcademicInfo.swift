// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

final class AcademicInfo {
    static let shared = AcademicInfo()
    var educationalTypes: EducationalTypesModel?
    var divisions: DivisionsModel?
    var batches: BatchesModel?
    var specializations: SpecializationsModel?
}
