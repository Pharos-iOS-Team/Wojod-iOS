// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import HandyUIKit
import SwiftEntryKit

class ErrorView: UIView, NibLoadable {
    @IBOutlet private var errorTitle: UILabel!
    @IBOutlet private var view: UIView!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var settingsButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }

    private func initWithNib() {
        try? loadFromNib()
        setupLayout()
    }

    @IBAction private func tapOnCancel(_ sender: UIButton) {
        SwiftEntryKit.dismiss()
    }

    @IBAction private func tapOnSettings(_ sender: UIButton) {
        SwiftEntryKit.dismiss()
        UIApplication.shared.open(UIApplication.openSettingsURL)
    }

    private func setupLayout() {
        view.setTopCornerRadius(radius: 20)
    }

    func configureTexts(pickImageFrom: UIImagePickerController.SourceType) {
        switch pickImageFrom {
        case .camera:
            errorTitle.text = L10n.Shared.Alerts.Camera.message
        default:
            errorTitle.text = L10n.Shared.Alerts.Photos.message
        }
        settingsButton.setTitle(L10n.Global.Titles.settings, for: .normal)
        cancelButton.setTitle(L10n.Shared.Action.cancel, for: .normal)
    }

    func configureAudioTexts() {
        errorTitle.text = L10n.Shared.Alerts.Microphone.message
        settingsButton.setTitle(L10n.Global.Titles.settings, for: .normal)
        cancelButton.setTitle(L10n.Shared.Action.cancel, for: .normal)
    }
}
