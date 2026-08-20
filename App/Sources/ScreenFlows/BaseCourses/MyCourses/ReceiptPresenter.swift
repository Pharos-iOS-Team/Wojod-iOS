// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class ReceiptPresenter {
    private weak var viewCtrl: UIViewController?
    private var blurredView: UIVisualEffectView?

    init(viewCtrl: UIViewController) {
        self.viewCtrl = viewCtrl
    }

    func showReceipt(_ receiptData: Receipt) {
        guard let viewCtrl = viewCtrl else { return }
        blurView()
        let receiptViewCtrl = ReceiptViewController(nibName: "ReceiptViewController", bundle: nil)
        receiptViewCtrl.myCourseReceipt = receiptData
        receiptViewCtrl.onDone = { [weak self] in self?.removeBlur() }
        receiptViewCtrl.modalPresentationStyle = .overFullScreen
        receiptViewCtrl.modalTransitionStyle = .crossDissolve
        viewCtrl.present(receiptViewCtrl, animated: true)
    }

    private func blurView() {
        guard let viewCtrl = viewCtrl else { return }
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewCtrl.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        viewCtrl.view.addSubview(blurEffectView)
    }

    private func removeBlur() {
        blurredView?.removeFromSuperview()
        blurredView = nil
    }
}
