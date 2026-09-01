// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

struct SchoolFieldValues {
    var parentNumber: String
    var parentNumber2: String
    var schoolName: String
}

struct UniversityFieldValues {
    var universityName: String
    var uniFieldName: String
    var uniYearName: String
}

enum AcademicInfoField {
    case parentNumber
    case schoolName
}

enum AcademicPickerType {
    case academicTypes, divisions, academicYears, schoolFields
    case universities, uniFields, uniYears
}

final class AcademicInfoViewModel {
    @Dependency(\.apiProvider)
    private var apiProvider: ApiProvider

    var academicTrack: AcademicTrack = .school
    var hasChosenTrack: Bool = false
    var hasChosenAcademicLevel: Bool = false
    var academicLevel: AcademicLevel = .universityStudent
    var needsStateRestore: Bool = false
    var selectedAcademicType: KeyValue?
    var academicTypesList: [KeyValue]?
    var divisionsList: [Division] = []
    var academicYears: [KeyValue] = []
    var schoolFields: [KeyValue] = []
    var selectedDivision: Division?
    var selectedSchoolField: KeyValue?
    var selectedYearIndex: Int = 0

    var universities: [Division] = []
    var uniFields: [KeyValue] = []
    var uniYears: [KeyValue] = []
    var selectedUniIndex: Int = 0
    var selectedUniFieldIndex: Int = 0
    var selectedUniYearIndex: Int = 0

    var isRoyalMedicine: Bool { AppEnvironment.appName == .royalMedicine }

    var onFormDidChange: (() -> Void)?
    var onRequestContainerResize: ((CGFloat, @escaping () -> Void) -> Void)?

    init() {}

    func resetUniSelection() {
        selectedUniIndex = 0
        selectedUniFieldIndex = 0
        selectedUniYearIndex = 0
    }

    func restoreInitialLayoutState() {
        let state = RegistrationStore.shared.state
        hasChosenTrack = state.hasChosenTrack
        academicTrack = state.academicTrack
        academicLevel = state.academicLevel
        hasChosenAcademicLevel = state.hasChosenAcademicLevel
        needsStateRestore = hasChosenTrack
    }

    func pickerItems(for pickerType: AcademicPickerType) -> [String] {
        switch pickerType {
        case .academicTypes:
            return academicTypesList?.compactMap { $0.value } ?? [""]
        case .divisions:
            return divisionsList.compactMap { $0.value }
        case .academicYears:
            return academicYears.compactMap { $0.value }
        case .schoolFields:
            return schoolFields.compactMap { $0.value }
        case .universities:
            return universities.compactMap { $0.value }
        case .uniFields:
            return uniFields.compactMap { $0.value }
        case .uniYears:
            return uniYears.compactMap { $0.value }
        }
    }

    func loadAcademicTypes() async -> [KeyValue] {
        let requestModel = AcademicRequestModel(educationLevel: AcademicLevel.schoolStudent.rawValue)
        let types = (try? await apiProvider.request(.registration(.academicTypes(requestModel)), decodeTo: ApiResponse<[KeyValue]>.self).data) ?? []
        academicTypesList = types
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.academicType,
            let idx = types.firstIndex(where: { $0.key == saved.key }) {
            selectedAcademicType = types[idx]
        } else {
            selectedAcademicType = types.first
        }
        return types
    }

    func loadAcademicDivisions() async -> [Division] {
        let divisionRequest = AcademicRequestModel(
            educationLevel: AcademicLevel.schoolStudent.rawValue,
            educationType: selectedAcademicType?.key,
            loginOrganization: nil
        )
        let divisions = (try? await apiProvider.request(.registration(.academicDivisions(divisionRequest)), decodeTo: ApiResponse<[Division]>.self).data) ?? []
        divisionsList = divisions
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.schoolDivision,
            let idx = divisions.firstIndex(where: { $0.key == saved.key }) {
            selectedDivision = divisions[idx]
        } else {
            selectedDivision = divisions.first
        }
        return divisions
    }

    func loadAcademicYear() async -> [KeyValue] {
        let batches = (
            try? await apiProvider.request(
                .registration(.batches(divisionID: selectedDivision?.key ?? 0)),
                decodeTo: ApiResponse<[KeyValue]>.self
            ).data) ?? []
        academicYears = batches
        if batches.isEmpty { academicYears.append(KeyValue(key: nil, value: L10n.Signup.School.none)) }
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.schoolBatch,
            let idx = academicYears.firstIndex(where: { $0.key == saved.key }) {
            selectedYearIndex = idx
        } else {
            selectedYearIndex = 0
        }
        return batches
    }

    func loadSchoolFields() async -> [KeyValue] {
        let fields = (
            try? await apiProvider.request(
                .registration(.specializations(divisionID: selectedDivision?.key ?? 0)),
                decodeTo: ApiResponse<[KeyValue]>.self
            ).data) ?? []
        schoolFields = fields
        schoolFields.append(KeyValue(key: nil, value: L10n.Signup.School.none))
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.schoolSpecialization,
            let idx = schoolFields.firstIndex(where: { $0.key == saved.key }) {
            selectedSchoolField = schoolFields[idx]
        } else {
            selectedSchoolField = nil
        }
        needsStateRestore = false
        return fields
    }

    func loadUniversities() async -> [Division] {
        if isRoyalMedicine {
            return []
        }
        let uniRequest = AcademicRequestModel(
            educationLevel: AcademicLevel.universityStudent.rawValue,
            educationType: nil,
            loginOrganization: AppEnvironment.appName.loginOrganization
        )
        let unis = (try? await apiProvider.request(.registration(.academicDivisions(uniRequest)), decodeTo: ApiResponse<[Division]>.self).data) ?? []
        universities = unis
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.university,
            let idx = universities.firstIndex(where: { $0.key == saved.key }) {
            selectedUniIndex = idx
        } else {
            selectedUniIndex = 0
        }
        return unis
    }

    func loadUniFieldsAndYears() async -> (fields: [KeyValue], years: [KeyValue]) {
        let key = universities[safe: selectedUniIndex]?.key ?? 0
        async let fieldsResult = apiProvider.request(.registration(.specializations(divisionID: key)), decodeTo: ApiResponse<[KeyValue]>.self).data
        async let yearsResult = apiProvider.request(.registration(.batches(divisionID: key)), decodeTo: ApiResponse<[KeyValue]>.self).data
        let fields = (try? await fieldsResult) ?? []
        let years = (try? await yearsResult) ?? []
        uniFields = fields
        if !AppEnvironment.shouldHideOrganizationAndSchool && !uniFields.isEmpty {
            uniFields.insert(KeyValue(key: nil, value: L10n.Signup.School.none), at: 0)
        }
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.uniSpecialization,
            let idx = uniFields.firstIndex(where: { $0.key == saved.key }) {
            selectedUniFieldIndex = idx
        } else {
            selectedUniFieldIndex = 0
        }
        uniYears = years
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.uniBatch,
            let idx = uniYears.firstIndex(where: { $0.key == saved.key }) {
            selectedUniYearIndex = idx
        } else {
            selectedUniYearIndex = 0
        }
        needsStateRestore = false
        return (fields, years)
    }

    func loadUniYearsOnly() async -> [KeyValue] {
        let key = universities[safe: selectedUniIndex]?.key ?? 0
        let years = (try? await apiProvider.request(.registration(.batches(divisionID: key)), decodeTo: ApiResponse<[KeyValue]>.self).data) ?? []
        uniYears = years
        if
            needsStateRestore,
            let saved = RegistrationStore.shared.state.uniBatch,
            let idx = uniYears.firstIndex(where: { $0.key == saved.key }) {
            selectedUniYearIndex = idx
        } else {
            selectedUniYearIndex = 0
        }
        return years
    }

    func saveStateToStore(schoolValues: SchoolFieldValues? = nil) {
        RegistrationStore.shared.update { state in
            state.academicTrack = self.academicTrack
            state.hasChosenTrack = self.hasChosenTrack
            state.hasChosenAcademicLevel = self.hasChosenAcademicLevel
            if self.academicTrack == .school {
                if let schoolValues = schoolValues {
                    state.parentNumber = schoolValues.parentNumber
                    state.parentNumber2 = schoolValues.parentNumber2
                    state.schoolName = schoolValues.schoolName
                }
                state.academicType = self.selectedAcademicType
                state.schoolDivision = self.selectedDivision
                state.schoolBatch = self.academicYears[safe: self.selectedYearIndex]
                state.schoolSpecialization = self.selectedSchoolField?.value == L10n.Signup.School.none ? nil : self.selectedSchoolField
                state.university = nil
                state.uniSpecialization = nil
                state.uniBatch = nil
            } else {
                state.academicLevel = self.academicLevel
                state.university = self.universities[safe: self.selectedUniIndex]
                state.uniSpecialization =
                self.uniFields[safe: self.selectedUniFieldIndex]?.value == L10n.Signup.School.none
                ? nil : self.uniFields[safe: self.selectedUniFieldIndex]
                state.uniBatch = self.uniYears[safe: self.selectedUniYearIndex]
                state.parentNumber = ""
                state.parentNumber2 = ""
                state.schoolName = ""
                state.academicType = nil
                state.schoolDivision = nil
                state.schoolBatch = nil
                state.schoolSpecialization = nil
            }
        }
    }

    func restoreSchoolData() -> SchoolFieldValues {
        let state = RegistrationStore.shared.state
        return SchoolFieldValues(
            parentNumber: state.parentNumber,
            parentNumber2: state.parentNumber2,
            schoolName: state.schoolName
        )
    }

    func restoreUniversityData() -> UniversityFieldValues {
        let state = RegistrationStore.shared.state
        return UniversityFieldValues(
            universityName: state.university?.value ?? "",
            uniFieldName: state.uniSpecialization?.value ?? "",
            uniYearName: state.uniBatch?.value ?? ""
        )
    }

    func clearSchoolData() {
        selectedAcademicType = nil
        selectedDivision = nil
        selectedSchoolField = nil
        selectedYearIndex = 0
        academicTypesList = nil
        divisionsList = []
        academicYears = []
        schoolFields = []
        RegistrationStore.shared.update { state in
            state.parentNumber = ""
            state.parentNumber2 = ""
            state.schoolName = ""
            state.academicType = nil
            state.schoolDivision = nil
            state.schoolBatch = nil
            state.schoolSpecialization = nil
        }
    }

    func clearUniversityData() {
        universities = []
        uniFields = []
        uniYears = []
        hasChosenAcademicLevel = false
        selectedUniIndex = 0
        selectedUniFieldIndex = 0
        selectedUniYearIndex = 0
        RegistrationStore.shared.update { state in
            state.university = nil
            state.uniSpecialization = nil
            state.uniBatch = nil
            state.hasChosenAcademicLevel = false
        }
    }

    func isMandatoryFieldsFilled(schoolValues: SchoolFieldValues? = nil) -> Bool {
        switch academicTrack {
        case .school:
            guard let schoolValues = schoolValues else { return false }
            return schoolValues.parentNumber.isValid &&
            schoolValues.schoolName.isValid &&
            selectedAcademicType != nil &&
            selectedDivision != nil &&
            academicYears[safe: selectedYearIndex].flatMap(\.key) != nil
        case .university:
            guard hasChosenAcademicLevel else { return false }
            switch academicLevel {
            case .universityStudent:
                if uniFields.isEmpty {
                    return !universities.isEmpty && !uniYears.isEmpty
                } else {
                    return !universities.isEmpty &&
                    uniFields[safe: selectedUniFieldIndex].flatMap(\.key) != nil &&
                    !uniYears.isEmpty
                }
            default:
                return !universities.isEmpty &&
                uniFields[safe: selectedUniFieldIndex].flatMap(\.key) != nil
            }
        }
    }

    func validateField(_ field: AcademicInfoField, parentNumber: String, schoolName: String) -> RegistrationValidationError? {
        switch field {
        case .parentNumber:
            return parentNumber.isValid ? nil : .parentNumberInvalid
        case .schoolName:
            return schoolName.isValid ? nil : .schoolNameEmpty
        }
    }

    func validationErrors() -> [RegistrationValidationError] {
        RegistrationValidator.validatePhase2(RegistrationStore.shared.state)
    }

    func navigateToAvatars(from viewController: UIViewController) {
        let avatarsViewCtrl = StoryboardScene.Registration.avatars.instantiate()
        viewController.navigationController?.pushViewController(avatarsViewCtrl, animated: true)
    }

    func goBack(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
