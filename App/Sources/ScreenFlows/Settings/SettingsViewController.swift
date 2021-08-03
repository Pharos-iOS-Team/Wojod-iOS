// Copyright © 2021 Pharos Solutions. All rights reserved.

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
    var user: LoginApiResponseModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        setUserAvatar()
        navigateToProfileHandler()
        preventScreenshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserAvatar()
    }

    private func registerNib() {
        let settingsTableViewCellNib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        settingsTableView.register(settingsTableViewCellNib, forCellReuseIdentifier: "SettingsTableViewCell")
    }

    private func setUserAvatar() {
        if User.shared.avatar?.thumbnailUrl != nil {
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
        let profileViewCtrl = StoryboardScene.Profile.profileViewController.instantiate()
        profileViewCtrl.modalPresentationStyle = .fullScreen
        present(profileViewCtrl, animated: true, completion: nil)
    }

    private func configureSettingsCell(forCell cell: SettingsTableViewCell, atIndexPath indexPath: IndexPath) {
        let cellModel = viewModel.getCellModel(forSettings: indexPath.row)
        cell.configure(withCellModel: cellModel)
    }

    private func changeLanguage(action: UIAlertAction) {
        Language.currentLanguage = action.title == L10n.Settings.english ? .english : .arabic
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.allCases.count
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
        switch Settings(rawValue: indexPath.row) {
        case .languages:
            let alertHandler = AlertHandler(presentingViewCtrl: self)
            let cell = tableView.cellForRow(at: indexPath)
            alertHandler.showLanguageActionSheet(title: L10n.Settings.chooseALanguage, sourceView: cell?.contentView ?? UIView()) { action in
                self.changeLanguage(action: action)
            }
        case .privacyPolicy:
            guard let linkURL = viewModel.getUrl(forIndex: indexPath.row) else { return }
            let safariViewCtrl = SFSafariViewController(url: linkURL)
            self.present(safariViewCtrl, animated: true)
        case .termsOfService:
            guard let linkURL = viewModel.getUrl(forIndex: indexPath.row) else { return }
            let safariViewCtrl = SFSafariViewController(url: linkURL)
            self.present(safariViewCtrl, animated: true)
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
