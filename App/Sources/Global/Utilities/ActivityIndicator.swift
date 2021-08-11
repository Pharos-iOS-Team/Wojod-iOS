// Copyright © 2020 Pharos Solutions. All rights reserved.

import JGProgressHUD

class ActivityIndicator {
    var progressHud: JGProgressHUD

    init(text: String? = nil) {
        progressHud = JGProgressHUD(style: .dark)
        progressHud.textLabel.text = text
        progressHud.textLabel.font = FontFamily.Inter.regular.font(size: 12.5)
    }

    func displayForSubmitting(in view: UIView) {
        progressHud.textLabel.text = L10n.Global.Alerts.loading
        progressHud.show(in: view)
    }

    func displayForLoading(in view: UIView) {
        progressHud.textLabel.text = L10n.Global.Alerts.loading
        progressHud.show(in: view)
    }

    func dismiss() {
        progressHud.dismiss(animated: true)
    }
}
