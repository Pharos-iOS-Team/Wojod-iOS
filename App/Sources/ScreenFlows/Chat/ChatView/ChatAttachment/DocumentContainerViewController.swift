// Copyright © 2020 Pharos Solutions. All rights reserved.

import UIKit

class DocumentContainerViewController: UIViewController {
    var url: URL?
    private var documentCtrl: UIDocumentInteractionController?
    private var canOpenDocumentCtrl = true

    override func viewDidLoad() {
        super.viewDidLoad()
        canOpenDocumentCtrl = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = url, canOpenDocumentCtrl else {
            dismiss(animated: true)
            return
        }
        showDocumentPreview(url: url)
    }

    func showDocumentPreview(url: URL) {
        documentCtrl = UIDocumentInteractionController(url: url)
        documentCtrl?.delegate = self
        documentCtrl?.presentPreview(animated: true)
        canOpenDocumentCtrl = false
    }
}

extension DocumentContainerViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        dismiss(animated: true)
    }
}
