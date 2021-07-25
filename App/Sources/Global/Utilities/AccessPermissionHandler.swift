// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import Foundation
import Photos
import UIKit
import SwiftEntryKit

final class AccessPermissionHandler {
    private unowned var presentingViewCtrl: UIViewController

    init(presentingViewCtrl: UIViewController) {
        self.presentingViewCtrl = presentingViewCtrl
    }

    func checkCameraAuthoriztion(successHandler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            successHandler()

        default:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? successHandler(): self?.showMissingCameraPermissionAlert()
                }
            }
        }
    }

    private func showMissingCameraPermissionAlert() {
        let alertHandler = AlertHandler(presentingViewCtrl: presentingViewCtrl)
        alertHandler.showMissingPermissionAlert(
            title: L10n.Shared.Alerts.Camera.title,
            message: L10n.Shared.Alerts.Camera.message
        )
    }

    func checkPhotoLibraryAuthoriztion(successHandler: @escaping () -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            successHandler()

        default:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    status == .authorized ? successHandler(): self?.showMissingPhotoLibraryPermissionAlert()
                }
            }
        }
    }

    private func showMissingPhotoLibraryPermissionAlert() {
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.positionConstraints = .float
        attributes.positionConstraints.verticalOffset = .zero
        attributes.positionConstraints.safeArea = .overridden
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        let errorPopup = ErrorView()
        SwiftEntryKit.display(entry: errorPopup, using: attributes)
    }
}
