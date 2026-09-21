// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class DocumentService: NSObject {
    // MARK: - Properties

    private var activeDownloadTask: URLSessionDownloadTask?
    private var downloadSession: URLSession?
    private var progressHandler: ((Float) -> Void)?
    private var completionHandler: ((URL) -> Void)?
    var errorHandler: ((Error) -> Void)?

    // MARK: - Init

    override init() {
        super.init()
    }

    // MARK: - Public Interface
    func downloadToCache(
        urlString: String,
        progressHandler: @escaping (Float) -> Void,
        completion: @escaping (URL) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        guard let url = URL(string: urlString) else { return }
        if let cached = cachedFileURL(for: urlString) {
            completion(cached)
            return
        }
        self.errorHandler = errorHandler
        self.progressHandler = progressHandler
        self.completionHandler = { localURL in completion(localURL) }
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
        errorHandler = nil
    }

    func cachedFileURL(for urlString: String) -> URL? {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = cacheDir.appendingPathComponent(cacheFileName(for: urlString))
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    private func cacheFileName(for urlString: String) -> String {
        let hash = "\(abs(urlString.hashValue))"
        let ext = URL(string: urlString)?.pathExtension ?? ""
        return ext.isEmpty ? hash : "\(hash).\(ext)"
    }

    // MARK: - Private Helpers
    private func startDownload(from url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        downloadSession = session
        let task = session.downloadTask(with: url)
        activeDownloadTask = task
        task.resume()
    }
}

// MARK: - URLSessionDownloadDelegate

extension DocumentService: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async { [weak self] in
                self?.progressHandler?(progress)
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let originalURLString = downloadTask.originalRequest?.url?.absoluteString,
            let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return }

        let fileName = cacheFileName(for: originalURLString)
        let destination = cacheDir.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: destination)
        guard (try? FileManager.default.copyItem(at: location, to: destination)) != nil else { return}
        let savedURL = destination
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(savedURL)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error, (error as NSError).code != NSURLErrorCancelled else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.errorHandler?(error)
        }
    }
}
