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
    var nameEn: String?
    var nameAr: String?
    var email: String?
    var mobileNumber: String?
    var avatar: Avatar?
    var parentNumber: String?
    var parentNumber2: String?
    var academicType: Int?
    var batch: Int?
    var divisionId: Int?
    var batchName: String?
    var divisionName: String?
    var specializationName: String?
    var specializationId: Int?
    var educationLevel: Int?
    var educationType: Int?
    var educationLevelName: String?
    var educationTypeName: String?
    var country: String?
    var city: String?
    var region: String?
    var address: String?
    var homeNumber: String?
    let logoutApiClient = LogoutApiClient()

    private init() {}

    func setLoggedIn(token: String, client: String, uid: String) {
        self.client = client
        self.uid = uid
        KeychainHandler.shared.saveUserToken(token)
    }

    // swiftlint:disable function_body_length
    func setUserData(
        user: LoginApiResponseModel?,
        student: StudentModel?
    ) {
        id = user != nil ? user?.data.id : student?.student.id
        nameEn = user != nil ? user?.data.nameEn : student?.student.nameEn
        nameAr = user != nil ? user?.data.nameAr : student?.student.nameAr
        email = user != nil ? user?.data.email : student?.student.email
        mobileNumber = user != nil ? user?.data.mobileNumber : student?.student.mobileNumber
        parentNumber = user != nil ? user?.data.parent1PhoneNumber : student?.student.parent1PhoneNumber
        parentNumber2 = user != nil ? user?.data.parent2PhoneNumber : student?.student.parent2PhoneNumber
        avatar = user != nil ? user?.data.avatar : student?.student.avatar
        divisionId = user != nil ? user?.data.divisionId : student?.student.divisionId
        academicType = user != nil ? user?.data.educationalType : student?.student.educationalType
        batch = user != nil ? user?.data.batchId : student?.student.batchId
        batchName = user != nil ? user?.data.batchName : student?.student.batchName
        divisionName = user != nil ? user?.data.divisionName : student?.student.divisionName
        specializationName = user != nil ? user?.data.specializationName : student?.student.specializationName
        educationLevel = user != nil ? user?.data.educationLevel : student?.student.educationLevel
        educationType = user != nil ? user?.data.educationType : student?.student.educationType
        educationLevelName = user != nil ? user?.data.educationLevelName : student?.student.educationLevelName
        educationTypeName = user != nil ? user?.data.educationTypeName : student?.student.educationTypeName
        specializationId = user != nil ? user?.data.specializationId : student?.student.specializationId
        country = user != nil ? user?.data.country : student?.student.country
        city = user != nil ? user?.data.city : student?.student.city
        region = user != nil ? user?.data.region : student?.student.region
        address = user != nil ? user?.data.address : student?.student.address
        homeNumber = user != nil ? user?.data.homeNumber : student?.student.homeNumber
    }

    func setLoggedOut() {
        isFirstHomeLoad = true
        KeychainHandler.shared.deleteUserToken()
    }

    func getAccessToken() -> String {
        if let accessToken = KeychainHandler.shared.userToken {
            return accessToken
        }
        return ""
    }

    internal func logout(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        self.logoutApiClient.logout(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "") { [weak self] response, error in
            self?.setLoggedOut()
            completionHandler(response, error)
        }
    }

    func isCurrentlySelectedLanguageArabic() -> Bool {
        return Language.currentLanguage == .arabic
    }

    private func isIphoneLanguageArabic() -> Bool {
        let preferredLanguage = NSLocale.preferredLanguages[0]
        return preferredLanguage == "ar-US" ? true : false
    }
}
