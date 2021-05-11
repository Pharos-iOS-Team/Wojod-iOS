// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet private var settingsImageView: UIImageView!
    @IBOutlet private var versionNumberLabel: UILabel!
    @IBOutlet private var settingsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    private func handleVersionNumberAppearance(versionNumber: String?) {
        if let versionNumber = versionNumber {
            versionNumberLabel.text = versionNumber
            versionNumberLabel.textAlignment = Language.currentLanguage == .english ? .right : .left
            accessoryType = .none
        } else {
            versionNumberLabel.isHidden = true
        }
    }

    func configure(withCellModel model: SettingsCellModel) {
        settingsImageView.image = model.image
        settingsLabel.text = model.title
        handleVersionNumberAppearance(versionNumber: model.versionNumber)
    }
}
