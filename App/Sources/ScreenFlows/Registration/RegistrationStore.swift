// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class RegistrationStore {
    // MARK: - Singleton

    static let shared = RegistrationStore()

    // MARK: - State

    private(set) var state: RegistrationFormState = .initial

    private init() {}

    // MARK: - Mutation

    func update(_ mutation: (inout RegistrationFormState) -> Void) {
        mutation(&state)
    }

    func reset() {
        state = .initial
    }

    // MARK: - API Request Builder

    func buildSignupRequest() -> UserSignupRequest {
        let isSchool = state.academicTrack == .school
        let formattedMobile = PhoneNumberValidator.formattedEgyptianPhone(state.mobileNumber, countryCode: state.mobileCountryCode)
        return UserSignupRequest(
            name: state.name,
            mobileNumber: formattedMobile,
            mobileNumber2: state.mobileNumber2,
            homeNumber: state.homeNumber,
            email: state.email,
            password: state.password,
            passwordConfirmation: state.password,
            country: state.country?.key,
            city: state.city?.key,
            region: state.region,
            address: state.address,
            parent1PhoneNumber: state.parentNumber,
            parent2PhoneNumber: state.parentNumber2,
            schoolName: state.schoolName,
            batchId: isSchool ? state.schoolBatch?.key : state.uniBatch?.key,
            specializationId: isSchool ? state.schoolSpecialization?.key : state.uniSpecialization?.key,
            avatarId: state.avatar?.id,
            isRoyalMedicineStudent: AppEnvironment.appName == .royalMedicine,
            loginOrganization: AppEnvironment.appName.loginOrganization,
            countryCode: state.mobileCountryCode
        )
    }
}
