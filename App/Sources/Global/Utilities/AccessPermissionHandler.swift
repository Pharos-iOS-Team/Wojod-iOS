// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import Foundation
import Photos
import UIKit

final class AccessPermissionHandler {
    private unowned var presentingViewCtrl: UIViewController

    init(presentingViewCtrl: UIViewController) {
        self.presentingViewCtrl = presentingViewCtrl
    }

    func checkCameraAuthoriztion(successHandler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            successHandler()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? successHandler(): self?.showMissingCameraPermissionAlert()
                }
            }

        case .denied, .restricted:
            showMissingCameraPermissionAlert()

        @unknown default:
            showMissingCameraPermissionAlert()
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

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    status == .authorized ? successHandler(): self?.showMissingPhotoLibraryPermissionAlert()
                }
            }

        case .denied, .restricted:
            showMissingPhotoLibraryPermissionAlert()

        @unknown default:
            showMissingPhotoLibraryPermissionAlert()
        }
    }

    private func showMissingPhotoLibraryPermissionAlert() {
        let alertHandler = AlertHandler(presentingViewCtrl: presentingViewCtrl)
        alertHandler.showMissingPermissionAlert(
            title: L10n.Shared.Alerts.Photos.title,
            message: L10n.Shared.Alerts.Photos.message
        )
    }
}
