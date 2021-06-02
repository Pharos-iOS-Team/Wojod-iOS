// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol ProfileChangePasswordDelegate: class {
    func changePasswordHandler()
}

class ProfileEditAndLogoutTableViewCell: UITableViewCell {
    @IBOutlet private var changePasswordStackView: UIStackView!
    @IBOutlet private var changePasswordButton: UIButton! {
        didSet {
            changePasswordButton.layer.cornerRadius = 8

        }
    }
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            logoutButton.layer.cornerRadius = 8
        }
    }

    private weak var delegate: ProfileChangePasswordDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(delegate: ProfileChangePasswordDelegate?) {
        self.delegate = delegate
    }

    @IBAction private func changePasswordPressed(_ sender: Any) {
        delegate?.changePasswordHandler()
    }
    @IBAction private func logoutPressed(_ sender: Any) {
        User.shared.logout { _, error in
            if error == nil {
                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
            }
        }
    }
}
