// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

struct DocumentPreview: UIViewControllerRepresentable {
    let url: URL
    let title: String
    let contentType: DocumentContentType
    let allowShare: Bool
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        if !allowShare, contentType == .pdf {
            let viewCtrl = PDFViewController(itemURL: url, title: title, onDismiss: onDismiss)
            return UINavigationController(rootViewController: viewCtrl)
        } else {
            let viewCtrl = DocumentQLPreviewController(url: url, title: title, onDismiss: onDismiss)
            return UINavigationController(rootViewController: viewCtrl)
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
