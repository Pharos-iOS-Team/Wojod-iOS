//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation

protocol AttachmentDownloaderDelegate: class {
    func didDownloadAttachment(at url: URL, attachmentID: Int?)
    func didUpdateProgress(_ progress: Double, for attachmentID: Int?)
}

class AttachmentDownloader: NSObject {
    private weak var delegate: AttachmentDownloaderDelegate?
    private var attachmentID: Int?

    init(attachmentID: Int?, delegate: AttachmentDownloaderDelegate) {
        self.attachmentID = attachmentID
        self.delegate = delegate
    }
}

// MARK: - URLSessionDownloadDelegate
extension AttachmentDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let lastPathComponent = downloadTask.originalRequest?.url?.lastPathComponent,
            let destinationUrl = try? FileManager.default.moveItem(lastPathComponent, at: location)
        else { return }

        delegate?.didDownloadAttachment(at: destinationUrl, attachmentID: attachmentID)
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let percentDownloaded = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.delegate?.didUpdateProgress(percentDownloaded, for: self.attachmentID)
        }
    }
}
