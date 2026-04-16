// Copyright © 2025 Pharos Solutions. All rights reserved.

import HandyUIKit
import PDFKit
import UIKit

final class PDFViewController: UIViewController {
    private var itemUrl: URL!
    var dismissAction: () -> Void = {}

    convenience init(itemUrl: URL, dismissAction: @escaping () -> Void) {
        self.init(nibName: nil, bundle: nil)
        self.itemUrl = itemUrl
        self.dismissAction = dismissAction
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationView()
        setupPDFView()
    }

    private func setupNavigationView() {
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePreview(_:))
        )
        navigationItem.leftBarButtonItem = closeButton
    }

    @objc
    func closePreview(_ sender: Any?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            dismissAction()
        }
    }

    private func setupPDFView() {
        let pdfView = PDFView()
        view.addSubview(pdfView)
        pdfView.bindEdgesToSuperview()

        if let document = PDFDocument(url: itemUrl) {
            pdfView.document = document
            pdfView.autoScales = true
        }
    }
}
