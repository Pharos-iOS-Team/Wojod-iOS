// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI
import UIKit

/// Owns the full document-preview flow for a single document.
final class DocumentPreviewCoordinator {
    // MARK: - State

    private enum LoadingState {
        case idle, loading, ready, failed
    }

    // MARK: - Properties

    private weak var presentingViewController: UIViewController?
    private var document: AttachmentDomain?
    private let documentService = DocumentService()
    private var previewState: DocumentPreviewState?
    private var state: LoadingState = .idle

    // MARK: - Public Interface

    func present(document: AttachmentDomain, from viewController: UIViewController) {
        guard state == .idle else { return }
        state = .loading

        self.document = document
        self.presentingViewController = viewController

        let previewState = DocumentPreviewState()
        self.previewState = previewState

        let previewView = DocumentPreviewView(
            state: previewState,
            title: document.title ?? document.fileName ?? "",
            contentType: document.mappedContentType ?? .pdf,
            allowShare: document.isDownloadable && AppEnvironment.appName != .squareCenter,
            watermarkText: formattedWatermarkText()
        ) { [weak self, weak viewController] in
            self?.documentService.cancelDownload()
            self?.state = .idle
            viewController?.dismiss(animated: true)
        }

        let hostingViewCtrl = UIHostingController(rootView: previewView)
        hostingViewCtrl.modalPresentationStyle = .overFullScreen
        viewController.present(hostingViewCtrl, animated: true)

        let urlString = AppEnvironment.baseURL
            .appendingPathComponent(document.fileUrl ?? "")
            .absoluteString

        if let cached = documentService.cachedFileURL(for: urlString) {
            state = .ready
            previewState.setReady(url: cached)
            return
        }

        documentService.downloadToCache(
            urlString: urlString,
            progressHandler: { [weak previewState] progress in
                DispatchQueue.main.async { previewState?.setProgress(progress) }
            },
            completion: { [weak self, weak previewState] localURL in
                DispatchQueue.main.async {
                    self?.state = .ready
                    previewState?.setReady(url: localURL)
                }
            },
            errorHandler: { [weak self, weak viewController] _ in
                DispatchQueue.main.async {
                    self?.state = .failed
                    viewController?.dismiss(animated: true) {
                        self?.showDownloadError()
                    }
                }
            }
        )
    }

    func cancel() {
        documentService.cancelDownload()
        state = .idle
    }

    // MARK: - Watermark Text

    private func formattedWatermarkText() -> String {
        guard document?.mappedContentType == .pdf  else { return "" }
        let formattedPhoneNumber = PhoneNumberValidator.formattedInternationalPhone(
            User.shared.mobileNumber ?? "",
            countryCode: User.shared.countryCode ?? ""
        )
        return "\(User.shared.name ?? "")\n\(formattedPhoneNumber)"
    }

    // MARK: - Error

    private func showDownloadError() {
        guard let presentingViewController else { return }
        let alert = UIAlertController(
            title: L10n.Global.Titles.error,
            message: L10n.Global.Alerts.somethingWentWrong,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Global.Actions.ok, style: .default))
        presentingViewController.present(alert, animated: true)
    }
}
