// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

// MARK: - Validation Errors

enum RegistrationValidationError: Equatable {
    // Phase 1 – Personal
    case nameEmpty
    case phoneInvalid
    case emailInvalid
    case passwordTooShort
    case passwordMismatch
    // Phase 1 – Location
    case countryMissing
    case cityMissing
    case regionEmpty
    // Phase 2 – School
    case parentNumberInvalid
    case parentNumber2Invalid
    case parentNumber2SameAsParent1
    case schoolNameEmpty
    case academicTypeMissing
    case divisionMissing
    // Phase 1 – Phone 2 (optional)
    case phone2Invalid
    case phone2SameAsPhone1
    // Phase 2 – University
    case universityMissing
    case universityYearMissing

    var localizedMessage: String {
        switch self {
        case .nameEmpty:
            return L10n.Signup.Error.nameEmpty
        case .phoneInvalid:
            return L10n.Signup.Error.phoneInvalid
        case .emailInvalid:
            return L10n.Signup.Error.emailInvalid
        case .passwordTooShort:
            return L10n.Signup.Error.passwordTooShort
        case .passwordMismatch:
            return L10n.Signup.Error.passwordMismatch
        case .countryMissing:
            return L10n.Signup.Error.countryMissing
        case .cityMissing:
            return L10n.Signup.Error.cityMissing
        case .regionEmpty:
            return L10n.Signup.Error.regionEmpty
        case .parentNumberInvalid:
            return L10n.Signup.Error.parentNumberInvalid
        case .parentNumber2Invalid:
            return L10n.Signup.Error.parentNumber2Invalid
        case .parentNumber2SameAsParent1:
            return L10n.Signup.Error.parentNumber2SameAsParent1
        case .schoolNameEmpty:
            return L10n.Signup.Error.schoolNameEmpty
        case .academicTypeMissing:
            return L10n.Signup.Error.academicTypeMissing
        case .divisionMissing:
            return L10n.Signup.Error.divisionMissing
        case .universityMissing:
            return L10n.Signup.Error.universityMissing
        case .universityYearMissing:
            return L10n.Signup.Error.universityYearMissing
        case .phone2Invalid:
            return L10n.Signup.Error.phone2Invalid
        case .phone2SameAsPhone1:
            return L10n.Signup.Error.phone2SameAsPhone1
        }
    }
}

// MARK: - Validator

enum RegistrationValidator {
    // MARK: - Phase 1: Personal + Location

    static func validatePhase1(_ state: RegistrationFormState) -> [RegistrationValidationError] {
        var errors: [RegistrationValidationError] = []

        if !state.name.isValid {
            errors.append(.nameEmpty)
        }
        if !state.mobileNumber.isValidPhoneNumber {
            errors.append(.phoneInvalid)
        }
        if !state.email.isValidEmail {
            errors.append(.emailInvalid)
        }
        if !state.password.isValidPassword() {
            errors.append(.passwordTooShort)
        }
        if state.password != state.confirmPassword {
            errors.append(.passwordMismatch)
        }
        if state.country == nil {
            errors.append(.countryMissing)
        }
        if state.hasCities && state.city == nil {
            errors.append(.cityMissing)
        }
        if !state.region.isValid {
            errors.append(.regionEmpty)
        }
        let phone2 = state.mobileNumber2
        if phone2.isValid {
            if !phone2.isValidPhoneNumber {
                errors.append(.phone2Invalid)
            } else if phone2 == state.mobileNumber {
                errors.append(.phone2SameAsPhone1)
            }
        }

        return errors
    }

    // MARK: - Phase 2: Academic Profile

    static func validatePhase2(_ state: RegistrationFormState) -> [RegistrationValidationError] {
        var errors: [RegistrationValidationError] = []

        switch state.academicTrack {
        case .school:
            if !state.parentNumber.isValidPhoneNumber {
                errors.append(.parentNumberInvalid)
            }
            let parent2 = state.parentNumber2
            if parent2.isValid {
                if !parent2.isValidPhoneNumber {
                    errors.append(.parentNumber2Invalid)
                } else if parent2 == state.parentNumber {
                    errors.append(.parentNumber2SameAsParent1)
                }
            }
            if !state.schoolName.isValid {
                errors.append(.schoolNameEmpty)
            }
            if state.academicType == nil {
                errors.append(.academicTypeMissing)
            }
            if state.schoolDivision == nil {
                errors.append(.divisionMissing)
            }

        case .university:
            if state.university == nil {
                errors.append(.universityMissing)
            }
            if state.academicLevel == .universityStudent && state.uniBatch == nil {
                errors.append(.universityYearMissing)
            }
        }

        return errors
    }
}
