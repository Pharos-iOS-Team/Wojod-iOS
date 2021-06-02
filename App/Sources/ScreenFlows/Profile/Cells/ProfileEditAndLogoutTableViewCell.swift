// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol ProfileChangePasswordDelegate: AnyObject {
    func changePasswordHandler()
}

class ProfileEditAndLogoutTableViewCell: UITableViewCell {
    enum Constants {
        static var buttonsCornerRadius: CGFloat = 8
    }
    @IBOutlet private var changePasswordStackView: UIStackView!
    @IBOutlet private var changePasswordButton: UIButton! {
        didSet {
            changePasswordButton.layer.cornerRadius = Constants.buttonsCornerRadius
        }
    }
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            logoutButton.layer.cornerRadius = Constants.buttonsCornerRadius
        }
    }

    private weak var delegate: ProfileChangePasswordDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
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

    func configure(delegate: ProfileChangePasswordDelegate?) {
        self.delegate = delegate
    }
}
