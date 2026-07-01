// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class DocumentService: NSObject {
    // MARK: - Properties

    private var documentInteractionController = UIDocumentInteractionController()
    private weak var presentingViewController: UIViewController?
    private var activeDownloadTask: URLSessionDownloadTask?
    private var downloadSession: URLSession?
    private var pendingMode: DownloadMode = .share
    private var progressHandler: ((Float) -> Void)?
    private var completionHandler: ((URL) -> Void)?

    private enum DownloadMode {
        case share
        case pdf
    }

    // MARK: - Init

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
        documentInteractionController.delegate = self
    }

    // MARK: - Public Interface

    func storeAndShare(urlString: String, progressHandler: @escaping (Float) -> Void, onOpen: @escaping () -> Void) {
        guard let url = URL(string: urlString) else { return }
        let fileName = url.lastPathComponent.isEmpty ? "file" : url.lastPathComponent
        if let cached = cachedFileURL(for: fileName) {
            onOpen()
            share(url: cached)
            return
        }
        self.pendingMode = .share
        self.progressHandler = progressHandler
        self.completionHandler = { [weak self] localURL in
            onOpen()
            self?.share(url: localURL)
        }
        startDownload(from: url)
        DispatchQueue.main.async { progressHandler(0) }
    }

    func presentPDF(from urlString: String, progressHandler: @escaping (Float) -> Void, onOpen: @escaping () -> Void) {
        guard let url = URL(string: urlString) else { return }
        let fileName = url.lastPathComponent.isEmpty ? "document.pdf" : url.lastPathComponent
        if let cached = cachedFileURL(for: fileName) {
            onOpen()
            openPDF(at: cached)
            return
        }
        self.pendingMode = .pdf
        self.progressHandler = progressHandler
        self.completionHandler = { [weak self] localURL in
            onOpen()
            self?.openPDF(at: localURL)
        }
        startDownload(from: url)
        DispatchQueue.main.async { progressHandler(0) }
    }

    func cancelDownload() {
        activeDownloadTask?.cancel()
        activeDownloadTask = nil
        downloadSession?.invalidateAndCancel()
        downloadSession = nil
        progressHandler = nil
        completionHandler = nil
    }

    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }

    // MARK: - Private Helpers

    private func startDownload(from url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        downloadSession = session
        let task = session.downloadTask(with: url)
        activeDownloadTask = task
        task.resume()
    }

    private func cachedFileURL(for fileName: String) -> URL? {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = cacheDir.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    private func saveToCache(from location: URL, suggestedFileName: String?) -> URL? {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileName = suggestedFileName ?? location.lastPathComponent
        let destination = cacheDir.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: destination)
        do {
            try FileManager.default.copyItem(at: location, to: destination)
            return destination
        } catch {
            return nil
        }
    }

    private func openPDF(at url: URL) {
        let pdfVC = PDFViewController(itemUrl: url, dismissAction: { [weak self] in
            self?.presentingViewController?.dismiss(animated: true)
        })
        let navController = UINavigationController(rootViewController: pdfVC)
        navController.modalPresentationStyle = .fullScreen
        presentingViewController?.present(navController, animated: true)
    }
}

// MARK: - URLSessionDownloadDelegate

extension DocumentService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress: Float
        if totalBytesExpectedToWrite > 0 {
            progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        } else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.progressHandler?(progress)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let suggestedName = downloadTask.response?.suggestedFilename
            ?? downloadTask.originalRequest?.url?.lastPathComponent
        let savedURL = saveToCache(from: location, suggestedFileName: suggestedName)
        guard let savedURL else { return }
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(savedURL)
            self?.activeDownloadTask = nil
            self?.downloadSession = nil
            self?.progressHandler = nil
            self?.completionHandler = nil
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error, (error as NSError).code != NSURLErrorCancelled else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, let vc = self.presentingViewController else { return }
            AlertHandler(presentingViewCtrl: vc).showConfirmAlert(
                title: L10n.Global.Titles.error,
                message: L10n.Global.Alerts.somethingWentWrong
            )
            self.progressHandler = nil
            self.completionHandler = nil
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate

extension DocumentService: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return presentingViewController ?? UIViewController()
    }
}
