// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import Kingfisher
import SafariServices
import UIKit

class SettingsViewController: UIViewController {
    enum Constants {
        static let tableViewCellHeight: CGFloat = 65
    }

    @IBOutlet private var settingsTableView: UITableView! {
        didSet {
            settingsTableView.delegate = self
            settingsTableView.dataSource = self
        }
    }
    @IBOutlet private var settingsLabel: UILabel! {
        didSet {
            settingsLabel.text = L10n.TabBar.settings
        }
    }
    @IBOutlet private var tableViewFooter: UIView!
    @IBOutlet private var profileThumbnail: UIImageView!

    let viewModel = SettingsViewModel()
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        setUserAvatar()
        navigateToProfileHandler()
        observeInternetConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserAvatar()
    }

    private func registerNib() {
        settingsTableView.registerCell(ofType: SettingsTableViewCell.self)
    }

    private func setUserAvatar() {
        if User.shared.avatar?.thumbnailUrl != nil, !viewModel.isGuestModeEnabled() {
            guard let link = User.shared.avatar?.thumbnailUrl else { return }
            guard let url = viewModel.getUserAvatar(avatarLink: link) else { return }
            profileThumbnail.kf.setImage(with: url)
        } else {
            profileThumbnail.image = Images.defaultAvatar.image
        }
    }

    private func navigateToProfileHandler() {
        profileThumbnail.isUserInteractionEnabled = true
        profileThumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigateToProfile)))
    }

    @objc
    private func navigateToProfile() {
        if viewModel.isGuestModeEnabled() {
            showLoadingIndicator()
            viewModel.logout()
        } else {
            let profileViewCtrl = StoryboardScene.Profile.profileViewController.instantiate()
            let navigationController = UINavigationController(rootViewController: profileViewCtrl)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func configureSettingsCell(forCell cell: SettingsTableViewCell, atIndexPath indexPath: IndexPath) {
        let setting = viewModel.availableSettings[indexPath.row]
        let cellModel = viewModel.getCellModel(forSettings: setting.rawValue)
        cell.configure(withCellModel: cellModel)
    }

    private func changeLanguage(action: UIAlertAction) {
        Language.currentLanguage = action.title == L10n.Settings.english ? .english : .arabic
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.availableSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingsTableViewCell",
            for: indexPath
        ) as? SettingsTableViewCell else { return UITableViewCell() }
        configureSettingsCell(forCell: cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.availableSettings[indexPath.row] {
        case .languages:
            let alertHandler = AlertHandler(presentingViewCtrl: self)
            let cell = tableView.cellForRow(at: indexPath)
            alertHandler.showLanguageActionSheet(
                title: L10n.Settings.chooseALanguage,
                sourceView: cell?.contentView ?? UIView(),
                selectedLanguage: Language.currentLanguage
            ) { action in
                self.changeLanguage(action: action)
            }
        case .privacyPolicy:
            guard let linkURL = viewModel.getUrl(forIndex: indexPath.row) else { return }
            let safariViewCtrl = SFSafariViewController(url: linkURL)
            self.present(safariViewCtrl, animated: true)
        case .organizations:
            let organizationsListViewCtrl = StoryboardScene.OrganizationsList.organizationsListViewController.instantiate()
            let navigationController = UINavigationController(rootViewController: organizationsListViewCtrl)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
        default:
            return
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableViewFooter
    }
}
