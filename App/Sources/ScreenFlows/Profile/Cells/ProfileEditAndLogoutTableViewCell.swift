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
            changePasswordButton.setTitle(L10n.Profile.changePassword)
        }
    }
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            logoutButton.layer.cornerRadius = Constants.buttonsCornerRadius
            logoutButton.setTitle(L10n.Global.Actions.logout)
        }
    }

    @IBOutlet private var deleteButton: UIButton! {
        didSet {
            deleteButton.layer.cornerRadius = Constants.buttonsCornerRadius
            deleteButton.setTitle(L10n.Global.Actions.deleteAccount)
        }
    }

    private weak var delegate: ProfileChangePasswordDelegate?
    var showError: ((String) -> Void)?

    @IBAction private func changePasswordPressed(_ sender: Any) {
        delegate?.changePasswordHandler()
    }

    @IBAction private func logoutPressed(_ sender: Any) {
        User.shared.logout { [weak self] result in
            switch result {
            case .success:
                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
            case let .failure(error):
                self?.showError?(error.localizedDescription)
            }
        }
    }

    @IBAction private func deleteAccountPressed(_ sender: Any) {
        UIViewController.topViewController()?.showConfirmAlert(
            title: L10n.Global.Actions.confirm,
            message: L10n.Profile.deleteConfirmation,
            confirmButtonTitle: L10n.Global.Actions.delete
        ) { _ in
            User.shared.deleteAccount { [weak self] result in
                switch result {
                case .success:
                    ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
                case let .failure(error):
                    self?.showError?(error.localizedDescription)
                }
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
