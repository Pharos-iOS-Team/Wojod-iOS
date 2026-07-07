// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class ReceiptPresenter: ReceiptDoneButtonDelegate {
    private weak var viewController: UIViewController?
    private var blurredView: UIVisualEffectView?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showReceipt(_ receiptData: Receipt) {
        guard let viewController = viewController else { return }
        blurView()
        let receiptViewCtrl = ReceiptViewController(nibName: "ReceiptViewController", bundle: nil)
        receiptViewCtrl.myCourseReceipt = receiptData
        receiptViewCtrl.delegate = self
        receiptViewCtrl.modalPresentationStyle = .overFullScreen
        receiptViewCtrl.modalTransitionStyle = .crossDissolve
        viewController.present(receiptViewCtrl, animated: true)
    }

    private func blurView() {
        guard let viewController = viewController else { return }
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewController.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        viewController.view.addSubview(blurEffectView)
    }

    private func removeBlur() {
        blurredView?.removeFromSuperview()
        blurredView = nil
    }

    func didTapDone() {
        removeBlur()
    }
}
