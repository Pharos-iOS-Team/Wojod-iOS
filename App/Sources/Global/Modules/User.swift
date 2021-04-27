// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import LanguageManager_iOS
import SwiftyUserDefaults

final class User {
    internal static let shared = User()
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
    var avatar: Avatar?
    var parentNumber: String?
    var academicType: String?
    var batch: String?

    private init() {}

    func setLoggedIn(token: String, client: String, uid: String) {
        self.client = client
        self.uid = uid
        KeychainHandler.shared.saveUserToken(token)
    }

    func setUserData(
        user: LoginApiResponseModel?,
        student: StudentModel?
    ) {
        self.id = user != nil ? user?.data.id : student?.student.id
        self.name = user != nil ? user?.data.name : student?.student.name
        self.email = user != nil ? user?.data.email : student?.student.email
        self.mobileNumber = user != nil ? user?.data.mobileNumber : student?.student.mobileNumber
        self.parentNumber = user != nil ? user?.data.parent1PhoneNumber : student?.student.parent1PhoneNumber
        self.avatar = user != nil ? user?.data.avatar : student?.student.avatar
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

    //        internal func logout(completionHandler: @escaping (Error?) -> Void) {
    //            DispatchQueue.global().async {
    //                APIClient.shared.logout { [weak self] response in
    //                    self?.setLoggedOut()
    //                    self?.defaults.subdomain = ""
    //                    completionHandler(response.error)
    //                }
    //            }
    //        }

    func isCurrentlySelectedLanguageArabic() -> Bool {
        return Language.currentLanguage == .arabic
    }

    private func isIphoneLanguageArabic() -> Bool {
        let preferredLanguage = NSLocale.preferredLanguages[0]
        return preferredLanguage == "ar-US" ? true : false
    }
}
