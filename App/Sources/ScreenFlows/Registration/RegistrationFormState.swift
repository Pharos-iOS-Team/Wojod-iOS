// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct RegistrationFormState {
    // MARK: - Factory

    static var initial: RegistrationFormState { RegistrationFormState() }

    // MARK: - Personal Info

    var name: String = ""
    var mobileNumber: String = ""
    var mobileNumber2: String = ""
    var homeNumber: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""

    // MARK: - Location Info

    var country: KeyName?
    var city: KeyName?
    var hasCities: Bool = true
    var region: String = ""
    var address: String = ""

    // MARK: - Academic Info

    var academicTrack: AcademicTrack = .school
    var hasChosenTrack: Bool = false

    // School-specific
    var parentNumber: String = ""
    var parentNumber2: String = ""
    var schoolName: String = ""
    var academicType: KeyValue?
    var schoolDivision: Division?
    var schoolBatch: KeyValue?
    var schoolSpecialization: KeyValue?

    // University-specific
    var academicLevel: AcademicLevel = .universityStudent
    var hasChosenAcademicLevel: Bool = false
    var university: Division?
    var uniSpecialization: KeyValue?
    var uniBatch: KeyValue?

    // MARK: - Avatar

    var avatar: Avatar?
}
