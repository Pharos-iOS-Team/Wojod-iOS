// Copyright © 2021 Pharos Solutions. All rights reserved.

import LanguageManager_iOS
import SwiftyUserDefaults
import UIKit

final class User {
    static let shared = User()
    private(set) var id: Int? {
        get {
            return Defaults[\.userId]
        }
        set {
            Defaults[\.userId] = newValue
        }
    }

    private(set) var uid: String? {
        get {
            return Defaults[\.uidKey]
        }
        set {
            Defaults[\.uidKey] = newValue
        }
    }
    private(set) var client: String? {
        get {
            return Defaults[\.clientKey]
        }
        set {
            Defaults[\.clientKey] = newValue
        }
    }

    var isFirstHomeLoad: Bool = true
    var name: String?
    var email: String?
    var mobileNumber: String?
    var mobileNumber2: String?
    var password: String = ""
    var avatar: Avatar?
    var parentNumber: String?
    var parentNumber2: String?
    var academicType: Int?
    var academicTypeName: String?
    var batch: Int?
    var divisionId: Int?
    var batchName: String?
    var divisionName: String?
    var specializationName: String?
    var specializationId: Int?
    var educationLevel: Int = 0
    var educationType: Int = 0
    var educationLevelName: String?
    var educationTypeName: String?
    var schoolName: String?
    var country: String?
    var countryName: String?
    var city: String?
    var cityName: String?
    var region: String?
    var address: String?
    var homeNumber: String?
    var isSchoolStudent: Bool?
    var organizations: [Organization] = []

    private init() {}

    func setLoggedIn(token: String, client: String, uid: String) {
        self.client = client
        self.uid = uid
        KeychainHandler.shared.saveUserToken(token)
    }

    // swiftlint:disable function_body_length
    func setUserData(
        user: UserModel?
    ) {
        id = user?.id
        name = user?.name
        email = user?.email
        mobileNumber = user?.mobileNumber
        mobileNumber2 = user?.mobileNumber2
        parentNumber = user?.parent1PhoneNumber
        parentNumber2 = user?.parent2PhoneNumber
        avatar = user?.avatar
        divisionId = user?.divisionId
        academicType = user?.educationalType
        batch = user?.batchId
        batchName = user?.batchName
        divisionName = user?.divisionName
        specializationName = user?.specializationName
        specializationId = user?.specializationId
        educationLevel = user?.educationLevel ?? 0
        educationType = user?.educationalType ?? 0
        educationLevelName = user?.educationLevelName
        educationTypeName = user?.educationTypeName
        country = user?.countryName
        city = user?.cityName
        region = user?.region
        address = user?.address
        homeNumber = user?.homeNumber
        organizations = user?.organizations ?? []
    }
    // swiftlint:enable function_body_length

    func deleteUserLocationData() {
        User.shared.country = nil
        User.shared.countryName = nil
        User.shared.city = nil
        User.shared.cityName = nil
        User.shared.address = nil
        User.shared.region = nil
    }

    func setLoggedOut() {
        isFirstHomeLoad = true
        deleteUserLocationData()
        KeychainHandler.shared.deleteUserToken()
    }

    func getAccessToken() -> String {
        return KeychainHandler.shared.userToken ?? ""
    }

    func logout(completionHandler: @escaping (Swift.Result<Bool, Error>) -> Void) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let requestModel = LogoutRequestModel(deviceId: deviceId)
        ApiProvider.shared.request(.auth(.logout(requestModel))) { [weak self] result in
            switch result {
            case .success:
                self?.setLoggedOut()
                completionHandler(.success(true))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    func deleteAccount(completionHandler: @escaping (Swift.Result<Bool, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.deleteAccount)) { [weak self] result in
            switch result {
            case .success:
                self?.setLoggedOut()
                completionHandler(.success(true))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}
