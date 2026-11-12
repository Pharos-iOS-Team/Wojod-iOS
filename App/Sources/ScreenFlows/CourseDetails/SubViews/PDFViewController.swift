// Copyright © 2026 Pharos Solutions. All rights reserved.

import PDFKit
import UIKit

// MARK: - PDFViewController

/// Displays a non-downloadable PDF using PDFView.
final class PDFViewController: UIViewController {
    private let itemURL: URL
    private let onDismiss: () -> Void
    private let pdfView = PDFView()

    init(itemURL: URL, title: String, onDismiss: @escaping () -> Void) {
        self.itemURL = itemURL
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCloseButton()
        setupPDFView()
    }

    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePreview)
        )
    }

    @objc
    private func closePreview() {
        onDismiss()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.disableTextSelection()
    }

    private func setupPDFView() {
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        view.addSubview(pdfView)

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let document = PDFDocument(url: itemURL) {
            pdfView.document = document
        }
        pdfView.disableTextSelection()
    }
}
