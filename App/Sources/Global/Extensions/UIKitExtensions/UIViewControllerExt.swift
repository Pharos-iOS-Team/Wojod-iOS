// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import UIKit
import Reachability
import SwiftEntryKit

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

    func preventScreenshot() -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            self.handleSendingScreenshotAlert()
        }
    }

    private func handleSendingScreenshotAlert() {
        if ReachabilityAppDelegate.connectionState == .connected {
            User.shared.screenshotAlert(screenName: String(describing: self)) { _ in }
        }
        handleCrashingTheApp()
    }

    private func handleCrashingTheApp() {
        self.showAlert(
            imageName: Images.danger.name,
            title: L10n.Shared.Alerts.screenshotsNotAllowed,
            message: L10n.Shared.Alerts.appWillTerminate
        ) {
            exit(-1)
        }
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            exit(-1)
        }
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
