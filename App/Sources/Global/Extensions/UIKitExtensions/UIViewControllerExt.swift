// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import UIKit
import Reachability
import SwiftEntryKit

extension UIViewController {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let alert = base as? UIAlertController {
            if let presenting = alert.presentingViewController {
                return topViewController(base: presenting)
            }
        }
        if let presented = base?.presentedViewController, (presented.isKind(of: UIAlertController.self) == false) {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIViewController {
    var rootViewCtrl: UIViewController? {
        AppDelegate.getAppDelegate()?.window?.rootViewController
    }

    func getImage(from url: String) -> UIImage? {
        let imageURL = AppEnvironment.baseURLString + url
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
    
    func showConfirmAlert(title: String, message: String, confirmButtonTitle: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        alertController.addActions([confirmAction, cancelAction])
        present(alertController, animated: true)
    }
}

extension UIViewController {
    func observeInternetConnection() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayNoInternetBanner), name: .internetConnectionChangedNotification, object: nil)
    }

    // swiftlint:disable function_body_length
    @objc
    func displayNoInternetBanner() {
        var attributes = EKAttributes.topNote
        attributes.entryBackground = .color(color: EKColor(.red))
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = .infinity
        attributes.windowLevel = .statusBar
        let title = EKProperty.LabelContent(
            text: "No internet connection",
            style: .init(
                font: .systemFont(ofSize: 12),
                color: .white,
                alignment: .center,
                displayMode: .inferred,
                numberOfLines: 1
            )
        )
        let description = EKProperty.LabelContent(text: "", style: .init(font: .systemFont(ofSize: 12), color: .white))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        let contentView = EKNotificationMessageView(with: notificationMessage)
        if ReachabilityAppDelegate.connectionState == .notConnected {
            SwiftEntryKit.display(entry: contentView, using: attributes)
        } else {
            SwiftEntryKit.dismiss()
        }
    }
}

extension UIViewController {
    func applyScreenshotPreventingView() {
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        ScreenshotPreventingView.protect(window: window)
    }

    func removeScreenshotPreventingView() {
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        ScreenshotPreventingView.unprotect(window: window)
    }
}
