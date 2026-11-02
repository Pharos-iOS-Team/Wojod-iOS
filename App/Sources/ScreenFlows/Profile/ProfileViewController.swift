// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

class ProfileViewController: UIViewController {
    enum Constants {
        static let tableViewCellHeight: CGFloat = 70
        static let tableViewHeaderHeight: CGFloat = 225
        static let tableViewLogoutCellHeight: CGFloat = 200
    }

    @IBOutlet private var profileTableView: UITableView! {
        didSet {
            profileTableView.dataSource = self
            profileTableView.delegate = self
        }
    }
    private let viewModel = ProfileViewModel()
    private var loadingHud: JGProgressHUD?
    var avatars: [Avatar]?
    var user: UserModel?
    private var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        registerNib()
        avatarsSuccessHandler()
        editSuccessHandler()
        editErrorHandler()
        fetchAcademicInfo()
        configureAcademicInfoSuccessHandler()
        viewModel.loadCountries()
        reloadCountriesCell()
        reloadCitiesCell()
        observeInternetConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAvatars()
    }

    private func configureNavigationBar() {
        let backItem = UIBarButtonItem(
            image: Images.localizedBackButton,
            style: .plain,
            target: self,
            action: #selector(dismissProfile)
        )
        navigationItem.leftBarButtonItem = backItem
        let saveItem = UIBarButtonItem(
            title: L10n.Profile.save,
            style: .done,
            target: self,
            action: #selector(saveProfile)
        )
        saveItem.tintColor = Colors.sendButtonColor.color
        navigationItem.rightBarButtonItem = saveItem
    }

    @objc private func dismissProfile() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func saveProfile() {
        editProfile()
    }

    private func registerNib() {
        profileTableView.registerCell(ofType: ProfileTableViewCell.self)
        profileTableView.registerCell(ofType: ProfileEditAndLogoutTableViewCell.self)
        profileTableView.registerHeaderFooterView(ofType: ProfileTableViewHeader.self)
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    private func editProfile() {
        viewModel.editProfile(id: String(User.shared.id ?? 0))
    }

    private func fetchAvatars() {
        viewModel.fetchAvatars()
    }

    private func avatarsSuccessHandler() {
        viewModel.avatarSuccessHandler = { [weak self] avatars in
            self?.avatars = avatars
        }
    }

    private func editSuccessHandler() {
        viewModel.successHandler = { [weak self] _ in
            self?.showSuccessAlert()
            self?.profileTableView.reloadData()
        }
    }

    private func editErrorHandler() {
        viewModel.errorHandler = { [weak self] error in
            guard let self = self else { return }
            let alert = AlertHandler(presentingViewCtrl: self)
            alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message)
        }
    }

    private func reloadCountriesCell() {
        viewModel.reloadCountriesCell = { [weak self] in
            self?.profileTableView.reloadData()
        }
    }

    private func reloadCitiesCell() {
        viewModel.reloadCitiesCell = { [weak self] index in
            self?.profileTableView.beginUpdates()
            self?.profileTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            self?.profileTableView.endUpdates()
        }
    }

    private func showSuccessAlert() {
        let alertHandler = AlertHandler(presentingViewCtrl: self)
        alertHandler.showInformationAlert(title: L10n.Global.Titles.warning, message: L10n.Profile.editedSuccessfully)
    }

    private func configureAcademicInfoSuccessHandler() {
        viewModel.academicInfoSuccessHandler = { [unowned self] in
            profileTableView.reloadData()
        }
    }

    private func fetchAcademicInfo() {
        viewModel.fetchEducationalTypes()
        viewModel.fetchDivisions()
        viewModel.fetchBatches(id: String(User.shared.divisionId ?? 0))
        viewModel.fetchSpecializations(id: String(User.shared.divisionId ?? 0))
    }

    private func navigateToAvatarsList() {
        showLoadingIndicator()
        guard let avatars = avatars else { return }
        let avatarsListViewCtrl = StoryboardScene.AvatarsList.avatarsListViewController.instantiate()
        avatarsListViewCtrl.avatars = avatars
        avatarsListViewCtrl.delegate = self
        present(avatarsListViewCtrl, animated: true, completion: nil)
        hideLoadingIndicator()
    }

    private func getImage(from avatar: Avatar) -> UIImage {
        guard let link = avatar.thumbnailUrl else { return UIImage() }
        let url = AppEnvironment.baseURL.appendingPathComponent(link)
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return UIImage() }
        return image
    }

    private func fetchPickerViewItems(forIndex index: Int) -> [String] {
        switch viewModel.validFields[index] {
        case .academicType:
            return AcademicInfo.shared.educationalTypes?.compactMap { $0.value } ?? []
        case .division:
            return AcademicInfo.shared.divisions?.compactMap { $0.value } ?? []
        case .batch:
            return AcademicInfo.shared.batches?.compactMap { $0.value } ?? []
        case .specialization:
            return AcademicInfo.shared.specializations?.compactMap { $0.value } ?? []
        case .country:
            return viewModel.countries.compactMap { $0.name }
        case .city:
            return viewModel.cities.compactMap { $0.name }
        default:
            return []
        }
    }

    private func changePassword() {
        let alertHandler = AlertHandler(presentingViewCtrl: self)
        alertHandler.showNewPasswordAlert(
            title: L10n.Profile.changePassword,
            sourceView: self.profileTableView
        ) { oldPassword, newPassword, passwordConfirmation in
            self.viewModel.setNewPassword(oldPassword: oldPassword, newPassword: newPassword, passwordConfirmation: passwordConfirmation)
            self.editProfile()
        }
    }

    private func createLogoutCell(indexPath: IndexPath, tableView: UITableView) -> ProfileEditAndLogoutTableViewCell {
        let cell: ProfileEditAndLogoutTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.configure(delegate: self)
        cell.showError = { [weak self] error in
            self?.showAlert(imageName: Images.danger.name, title: L10n.Global.Titles.error, message: error)
        }
        return cell
    }

    private func createProfileFields(indexPath: IndexPath, tableView: UITableView) -> ProfileTableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueCell(for: indexPath)
        let currentField = viewModel.validFields[indexPath.row]
        let text = viewModel.setTextFieldInfo(forIndexPath: indexPath.row) ?? ""
        let fieldLabel = viewModel.setTextfieldLabel(forIndexPath: indexPath.row)

        if currentField == .mobileNumber {
            cell.configureAsPhoneInput(
                fieldLabel: fieldLabel,
                phoneNumber: text,
                countryCode: User.shared.countryCode ?? PhoneNumberValidator.egyptCountryCode
            )
            return cell
        }

        let shouldDisableTextField = viewModel.shouldMakeTextFieldDisabled(forIndexPath: indexPath.row)
        let dataModel = ProfileTableViewCellDataModel(
            text: text,
            items: fetchPickerViewItems(forIndex: indexPath.row),
            indexPath: indexPath.row,
            fields: viewModel.validFields,
            fieldLabel: fieldLabel,
            shouldDisableTextField: !shouldDisableTextField
        )
        cell.configure(
            dataModel: dataModel,
            delegate: self
        )
        return cell
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.validFields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.validFields[indexPath.row] == .logout {
            return createLogoutCell(indexPath: indexPath, tableView: tableView)
        } else {
            return createProfileFields(indexPath: indexPath, tableView: tableView)
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.validFields[indexPath.row] == .logout ? Constants.tableViewLogoutCellHeight : Constants.tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.tableViewHeaderHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerModel = ProfileHeaderModel(imageURL: User.shared.avatar?.fileUrl, name: User.shared.name ?? "", type: User.shared.educationLevelName ?? "")
        let headerView = tableView.dequeueHeaderFooterView(ofType: ProfileTableViewHeader.self)
        headerView?.configure(model: headerModel, delegate: self)
        return headerView
    }
}

extension ProfileViewController: ProfileTableViwCellProtocol {
    func didFieldChange(text: String, cell: UITableViewCell, field: ProfileFields?) {
        guard let index = profileTableView.indexPath(for: cell) else { return }
        viewModel.editProfileFields(forIndexPath: index.row, withText: text)
        if field == .country {
            let cityCell = profileTableView.cellForRow(at: IndexPath(row: index.row + 1, section: index.section)) as? ProfileTableViewCell
            cityCell?.configureDefaultSelectionForCity()
        }
    }
}

extension ProfileViewController: AvatarsListDelegate {
    func setAvatar(avatar: Avatar?) {
        User.shared.avatar = avatar
        viewModel.setNewAvatar(avatarId: avatar?.id)
        profileTableView.reloadData()
    }
}

extension ProfileViewController: ProfileChangePasswordDelegate {
    func changePasswordHandler() {
        changePassword()
    }
}

extension ProfileViewController: ProfileTableViewHeaderDelegate {
    func changeProfileImage() {
        navigateToAvatarsList()
    }
}
