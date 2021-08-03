// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import UIKit

extension UIViewController {
    var rootViewCtrl: UIViewController? {
        AppDelegate.getAppDelegate()?.window?.rootViewController
    }

    func getImage(from url: String) -> UIImage? {
        let imageURL = Environment.baseURLString + url
        guard let url = URL(string: imageURL), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    @objc func showAlert(
        imageName: String,
        title: String?,
        message: String?,
        notifyAlertHasBeenDismissed: @escaping () -> Void = {}
    ) {
        let vc = StoryboardScene.AppAlert.appAlertViewController.instantiate()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        _ = vc.view
        vc.configure(image: UIImage(named: imageName), title: title, subtitle: message)
        vc.configureOneButtonForDismiss()
        vc.notifyAlertHasBeenDismissed = notifyAlertHasBeenDismissed
    }

    @objc func showAlert(
        imageName: String,
        title: String?,
        message: String?,
        primaryButtonTitle: String,
        dismissButtonTitle: String,
        primaryButtonCompletionHandler: @escaping () -> Void
    ) {
        _ = showAndReturnAlert(
            imageName: imageName,
            title: title,
            message: message,
            primaryButtonTitle: primaryButtonTitle,
            dismissButtonTitle: dismissButtonTitle,
            primaryButtonCompletionHandler: primaryButtonCompletionHandler
        )
    }

    func showAndReturnAlert(
        imageName: String,
        title: String?,
        message: String?,
        primaryButtonTitle: String,
        dismissButtonTitle: String,
        shouldHideCloseButton: Bool? = nil,
        secondryButtonCompletionHandler: (() -> Void)? = nil,
        primaryButtonCompletionHandler: @escaping () -> Void
    ) -> AppAlertViewController {
        let appAlertViewController = StoryboardScene.AppAlert.appAlertViewController.instantiate()
        appAlertViewController.modalPresentationStyle = .overFullScreen
        appAlertViewController.view.layoutIfNeeded()
        present(appAlertViewController, animated: true)
        appAlertViewController.configure(image: UIImage(named: imageName), title: title, subtitle: message, shouldCloseButtonAppear: shouldHideCloseButton)
        appAlertViewController.configureButtons(
            primaryButtonTitle: primaryButtonTitle,
            dismissButtonTitle: dismissButtonTitle,
            secondryButtonCompletionHandler: secondryButtonCompletionHandler,
            primaryButtonCompletionHandler: primaryButtonCompletionHandler
        )
        return appAlertViewController
    }
}
