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
                    granted ? successHandler(): self?.showMissingPhotoLibraryPermissionAlert(pickImageFrom: .camera)
                }
            }
        }
    }

    func checkPhotoLibraryAuthoriztion(successHandler: @escaping () -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            successHandler()

        default:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    status == .authorized ? successHandler(): self?.showMissingPhotoLibraryPermissionAlert(pickImageFrom: .photoLibrary)
                }
            }
        }
    }

    func showMissingAudioAutorization(successHandler: @escaping () -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            successHandler()
        case AVAudioSessionRecordPermission.denied:
            showMissingAudioPermissionAlert()
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        successHandler()
                    } else {
                        showMissingAudioPermissionAlert()
                    }
                }
            }
        default:
            break
        }
    }

    private func showMissingPhotoLibraryPermissionAlert(pickImageFrom: UIImagePickerController.SourceType) {
        let errorPopup = ErrorView()
        errorPopup.configureTexts(pickImageFrom: pickImageFrom)
        SwiftEntryKit.display(entry: errorPopup, using: configureAttributes())
    }

    private func showMissingAudioPermissionAlert() {
        let errorPopup = ErrorView()
        errorPopup.configureAudioTexts()
        SwiftEntryKit.display(entry: errorPopup, using: configureAttributes())
    }

    private func configureAttributes() -> EKAttributes {
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
        return attributes
    }
}
