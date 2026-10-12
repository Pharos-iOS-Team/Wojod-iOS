// Copyright © 2026 Pharos Solutions. All rights reserved.

import QuickLook
import UIKit

class DocumentQLPreviewController: QLPreviewController {
    private let itemURL: URL
    private let docTitle: String
    private let onDismiss: () -> Void

    init(url: URL, title: String, onDismiss: @escaping () -> Void) {
        self.itemURL = url
        self.docTitle = title
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }

    @objc
    private func closeTapped() {
        onDismiss()
    }
}

extension DocumentQLPreviewController: QLPreviewControllerDataSource {
    // MARK: - QLPreviewItemBox
    private final class QLPreviewItemBox: NSObject, QLPreviewItem {
        let previewItemURL: URL?
        let previewItemTitle: String?

        init(url: URL, title: String?) {
            previewItemURL = url
            previewItemTitle = title
        }
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        QLPreviewItemBox(url: itemURL, title: docTitle.isEmpty ? nil : docTitle)
    }
}
