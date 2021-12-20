// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import Moya

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
            changePasswordButton.setTitle(L10n.Profile.changePassword)
        }
    }
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            logoutButton.layer.cornerRadius = Constants.buttonsCornerRadius
            logoutButton.setTitle(L10n.Global.Actions.logout)
        }
    }

    private weak var delegate: ProfileChangePasswordDelegate?
    var showError: ((MoyaError) -> Void)?

    @IBAction private func changePasswordPressed(_ sender: Any) {
        delegate?.changePasswordHandler()
    }

    @IBAction private func logoutPressed(_ sender: Any) {
        User.shared.logout { [weak self] _, error in
            if let error = error {
                self?.showError?(error)
            } else {
                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(delegate: ProfileChangePasswordDelegate?) {
        self.delegate = delegate
    }
}
