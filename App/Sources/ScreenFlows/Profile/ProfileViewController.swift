// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class ProfileViewController: UIViewController {
    enum Constants {
        static let tableViewCellHeight: CGFloat = 70
        static let tableViewHeaderHeight: CGFloat = 225
        static let tableViewLogoutCellHeight: CGFloat = 130
    }

    @IBOutlet private var profileTableView: UITableView! {
        didSet {
            profileTableView.dataSource = self
            profileTableView.delegate = self
        }
    }
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.contentHorizontalAlignment = Language.contentHorizontalAlignment
            backButton.semanticContentAttribute = Language.semanticContent
        }
    }
    @IBOutlet private var saveButton: UIButton! {
        didSet {
            saveButton.setTitle(L10n.Profile.save)
        }
    }

    private let viewModel = ProfileViewModel()
    var avatars: AvatarsModel?
    var user: StudentModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        avatarsSuccessHandler()
        editSuccessHandler()
        editErrorHandler()
        fetchAcademicInfo()
        viewModel.loadCountries()
        reloadCountriesCell()
        reloadCitiesCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAvatars()
    }

    @IBAction private func editProfile(_ sender: Any) {
        editProfile()
    }
    @IBAction private func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func registerNib() {
        profileTableView.registerCell(ofType: ProfileTableViewCell.self)
        profileTableView.registerCell(ofType: ProfileEditAndLogoutTableViewCell.self)
        profileTableView.registerHeaderFooterView(ofType: ProfileTableViewHeader.self)
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

    private func fetchAcademicInfo() {
        viewModel.fetchEducationalTypes()
        viewModel.fetchDivisions()
        viewModel.fetchBatches(id: String(User.shared.divisionId ?? 0))
        viewModel.fetchSpecializations(id: String(User.shared.divisionId ?? 0))
    }

    private func navigateToAvatarsList() {
        guard let avatars = avatars?.avatars else { return }
        let avatarsListViewCtrl = StoryboardScene.AvatarsList.avatarsListViewController.instantiate()
        avatarsListViewCtrl.avatars = avatars
        avatarsListViewCtrl.delegate = self
        present(avatarsListViewCtrl, animated: true, completion: nil)
    }

    private func getImage(from avatar: Avatar) -> UIImage {
        guard let link = avatar.thumbnailUrl else { return UIImage() }
        let url = Environment.baseURL.appendingPathComponent(link)
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return UIImage() }
        return image
    }

    private func fetchPickerViewItems(forIndex index: Int) -> [String] {
        switch viewModel.validFields[index] {
        case .academicType:
            return AcademicInfo.shared.educationalTypes?.educationTypes.compactMap({
                $0.value
            }) ?? []
        case .division:
            return AcademicInfo.shared.divisions?.divisions.compactMap({
                $0.value
            }) ?? []
        case .batch:
            return AcademicInfo.shared.batches?.batches.compactMap({
                $0.value
            }) ?? []
        case .specialization:
            return AcademicInfo.shared.specializations?.specializations.compactMap({
                $0.value
            }) ?? []
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
        }
    }

    private func createLogoutCell(indexPath: IndexPath, tableView: UITableView) -> ProfileEditAndLogoutTableViewCell {
        let cell: ProfileEditAndLogoutTableViewCell =
            tableView.dequeueCell(for: indexPath)
        cell.configure(delegate: self)
        return cell
    }

    private func createProfileFields(indexPath: IndexPath, tableView: UITableView) -> ProfileTableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueCell(for: indexPath)
        let text = viewModel.setTextFieldInfo(forIndexPath: indexPath.row) ?? ""
        let fieldLabel = viewModel.setTextfieldLabel(forIndexPath: indexPath.row)
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
        if  viewModel.validFields[indexPath.row] == .logout {
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
    func didFieldChange(text: String, cell: UITableViewCell) {
        guard let index = profileTableView.indexPath(for: cell) else { return }
        viewModel.editProfileFields(forIndexPath: index.row, withText: text)
    }
}

extension ProfileViewController: AvatarsListDelegate {
    func setAvatar(avatar: Avatar) {
        guard let id = avatar.id else { return }
        viewModel.setNewAvatar(avatarId: id)
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
