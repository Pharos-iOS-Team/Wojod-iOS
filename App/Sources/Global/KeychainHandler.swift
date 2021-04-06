// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import KeychainAccess

struct KeychainHandler {
    private enum KeychainKey {
        static let userToken: String = "userToken"
    }

    static var shared = KeychainHandler()
    private var keychain: Keychain

    var userToken: String? {
        return keychain[KeychainKey.userToken]
    }

    init() {
        guard let bundleID = Bundle.main.bundleIdentifier else { preconditionFailure("Invalid Bundle") }
        keychain = Keychain(service: bundleID)
    }

    func saveUserToken(_ token: String) {
        keychain[KeychainKey.userToken] = token
    }

    func deleteUserToken() {
        try? keychain.remove(KeychainKey.userToken)
    }
}
