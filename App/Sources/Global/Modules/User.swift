// Copyright © 2021 Pharos Solutions. All rights reserved.

import LanguageManager_iOS
import Moya
import SwiftyUserDefaults
import UIKit

enum EducationLevel: Int, CaseIterable {
    case school
    case facutly
    case gradute
}

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
    let logoutApiClient = LogoutApiClient()

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
        educationLevel = user?.educationLevel ?? 0
        educationType = user?.educationalType ?? 0
        educationLevelName = user?.educationLevelName
        educationTypeName = user?.educationTypeName
        specializationId = user?.specializationId
        country = user?.countryName
        city = user?.cityName
        region = user?.region
        address = user?.address
        homeNumber = user?.homeNumber
    }

    func setLoggedOut() {
        isFirstHomeLoad = true
        KeychainHandler.shared.deleteUserToken()
    }

    func getAccessToken() -> String {
        return KeychainHandler.shared.userToken ?? ""
    }

    func logout(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        self.logoutApiClient.logout(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "") { [weak self] response, error in
            self?.setLoggedOut()
            completionHandler(response, error)
        }
    }
}
