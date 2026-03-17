// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya
import SwiftyUserDefaults
import UIKit

final class UnauthorizedResponseHandler {
    static let shared = UnauthorizedResponseHandler()

    private var isHandling = false

    private init() {}

    func handleUnauthorizedResponse() {
        guard !isHandling else { return }
        guard let token = KeychainHandler.shared.userToken, !token.isEmpty else { return }

        isHandling = true

        DispatchQueue.main.async { [weak self] in
            self?.showSessionExpiredAlert()
        }
    }

    private func showSessionExpiredAlert() {
        guard let topViewCtrl = UIViewController.topViewController() else {
            isHandling = false
            return
        }

        topViewCtrl.showAlert(
            imageName: Images.danger.name,
            title: L10n.Shared.Alerts.SessionExpired.title,
            message: L10n.Shared.Alerts.SessionExpired.message
        ) { [weak self] in
            self?.clearSessionAndNavigateToLogin()
        }
    }

    private func clearSessionAndNavigateToLogin() {
        User.shared.setLoggedOut()
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
        isHandling = false
    }
}
