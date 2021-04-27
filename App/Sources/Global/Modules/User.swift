// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import LanguageManager_iOS
import SwiftyUserDefaults

internal class User {
    internal static let shared = User()
    private let LOGIN_STATE_KEY = "login_state"
    private let FIRST_LAUNCH_KEY = "first_launch"
    private let UID_KEY = "uid"
    private let CLIENT_KEY = "client"
    private let ID_KEY = "id"
    private let defaults = UserDefaults.standard
    internal private(set) var id: Int? {
        get {
            return defaults.integer(forKey: ID_KEY)
        }
        set {
            defaults.set(newValue, forKey: ID_KEY)
        }
    }

    internal private(set) var uid: String? {
        get {
            return defaults.string(forKey: UID_KEY)
        }
        set {
            DefaultsKeys[\.uid] = uid
            defaults.set(newValue, forKey: UID_KEY)
        }
    }
    internal private(set) var client: String? {
        get {
            return defaults.string(forKey: CLIENT_KEY)
        }
        set {
            defaults.set(newValue, forKey: CLIENT_KEY)
        }
    }
    internal private(set) var isAppUsedBefore: Bool {
        get {
            return defaults.bool(forKey: FIRST_LAUNCH_KEY)
        }
        set {
            defaults.set(newValue, forKey: FIRST_LAUNCH_KEY)
        }
    }
    private var loginInState: Bool {
        get {
            return defaults.bool(forKey: LOGIN_STATE_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGIN_STATE_KEY)
        }
    }
    internal var isFirstHomeLoad = true

    private init() {}

    internal func setAppUsedBefore() {
        self.isAppUsedBefore = true
    }

    internal func setAppNotUsedBefore() {
        self.isAppUsedBefore = false
    }

    internal func isLoggedIn() -> Bool {
        return loginInState
    }

    internal func setLoggedIn(token: String, client: String, uid: String) {
        self.loginInState = true
        self.client = client
        self.uid = uid
        KeychainHandler.shared.saveUserToken(token)
    }

    internal func setUserData(
        id: Int?,
        name: String?,
        email: String?,
        mobileNumber: String?,
        avatar: Avatar?
        ) {
        self.id = id
    }

    internal func setLoggedOut() {
        loginInState = false
        isFirstHomeLoad = true
        KeychainHandler.shared.deleteUserToken()
    }

    internal func getAccessToken() -> String {
        if let accessToken = KeychainHandler.shared.userToken {
            return accessToken
        }
        return ""
    }

//    internal func logout(completionHandler: @escaping (Error?) -> Void) {
//        DispatchQueue.global().async {
//            APIClient.shared.logout { [weak self] response in
//                self?.setLoggedOut()
//                self?.defaults.subdomain = ""
//                completionHandler(response.error)
//            }
//        }
//    }

    internal func isCurrentlySelectedLanguageArabic() -> Bool {
        return Language.currentLanguage == .arabic
    }

    private func isIphoneLanguageArabic() -> Bool {
        let preferredLanguage = NSLocale.preferredLanguages[0]
        return preferredLanguage == "ar-US" ? true : false
    }
}

