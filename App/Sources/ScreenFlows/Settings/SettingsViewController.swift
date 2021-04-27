// Copyright © 2021 Pharos Solutions. All rights reserved.

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
    let viewModel = SettingsViewModel()
    var user: LoginApiResponseModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
    }

    private func registerNib() {
        let settingsTableViewCellNib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        settingsTableView.register(settingsTableViewCellNib, forCellReuseIdentifier: "SettingsTableViewCell")
    }

    private func configureSettingsCell(forCell cell: SettingsTableViewCell, atIndexPath indexPath: IndexPath) {
        let cellModel = viewModel.getCellModel(forSettings: indexPath.row)
        cell.configure(withCellModel: cellModel)
    }

    private func changeLanguage(action: UIAlertAction) {
        Language.currentLanguage = action.title == L10n.Settings.english ? .english : .arabic
        let initialViewCtrl = StoryboardScene.CoursesTabBar.initialScene.instantiate()
        AppDelegate.getAppDelegate()?.window?.switchRootViewController(initialViewCtrl)
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
        switch indexPath.row {
        case Settings.languages.rawValue:
            let alertHandler = AlertHandler(presentingViewCtrl: self)
            alertHandler.showLanguageActionSheet(title: L10n.Settings.chooseALanguage, sourceView: self.view) { action in
                self.changeLanguage(action: action)
            }
        case Settings.privacyPolicy.rawValue:
            guard let linkURL = viewModel.getUrl(forIndex: indexPath.row) else { return }
            let safariViewCtrl = SFSafariViewController(url: linkURL)
            self.present(safariViewCtrl, animated: true)
        case Settings.termsOfService.rawValue:
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

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableViewFooter
    }
}
