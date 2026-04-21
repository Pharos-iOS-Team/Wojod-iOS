// Copyright © 2026 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

final class LoadingIndicatorPresenter {
    weak var view: UIView?
    private var loadingHud: JGProgressHUD?

    init(view: UIView) {
        self.view = view
    }

    func show() {
        guard loadingHud == nil, let view = view else { return }
        loadingHud = JGProgressHUD(style: .light).with {
            $0.interactionType = .blockNoTouches
            $0.textLabel.text = L10n.Global.Alerts.loading
            $0.hudView.backgroundColor = .white
            $0.show(in: view, animated: true)
        }
    }

    func hide() {
        loadingHud?.dismiss()
        loadingHud = nil
    }
}
