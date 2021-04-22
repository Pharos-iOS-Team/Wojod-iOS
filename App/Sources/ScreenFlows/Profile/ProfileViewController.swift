// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class ProfileViewController: UIViewController {
    enum Constants {
        static let tableViewCellHeight: CGFloat = 70
    }

    @IBOutlet private var profileTableView: UITableView! {
        didSet {
            profileTableView.dataSource = self
            profileTableView.delegate = self
        }
    }
    @IBOutlet private var nameLabel: UILabel! {
        didSet {
            nameLabel.text = Language.currentLanguage == .arabic ? User.shared.nameAr : User.shared.nameEn
        }
    }
    @IBOutlet private var schoolLabel: UILabel! {
        didSet {
            schoolLabel.text = User.shared.educationLevelName
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
            saveButton.isEnabled = false
        }
    }
    @IBOutlet private var avatarButton: UIButton! {
        didSet {
            guard let link = User.shared.avatar?.thumbnailUrl else { return }
            let url = Environment.baseURL.appendingPathComponent(link)
            avatarButton.kf.setImage(with: url, for: .normal)
        }
    }
    @IBOutlet private var logoutButton: UIButton! {
        didSet {
            logoutButton.setTitle(L10n.Profile.logout)
            logoutButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var changePasswordButton: UIButton! {
        didSet {
            changePasswordButton.layer.cornerRadius = 5
            changePasswordButton.setTitle(L10n.Profile.changePassword)
        }
    }

    let viewModel = ProfileViewModel()
    var avatars: AvatarsModel?
    var user: StudentModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        avatarsSuccessHandler()
        editSuccessHandler()
        editErrorHandler()
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
    @IBAction private func changeAvatar(_ sender: Any) {
        navigateToAvatarsList()
    }
    @IBAction private func logout(_ sender: Any) {
        User.shared.logout { _, error in
            if error == nil {
                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
            }
        }
    }
    @IBAction private func changePasswordPressed(_ sender: Any) {
        changePassword()
    }
    private func registerNib() {
        let profileTableViewCellNib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        profileTableView.register(profileTableViewCellNib, forCellReuseIdentifier: "ProfileTableViewCell")
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

    private func showSuccessAlert() {
        let alertHandler = AlertHandler(presentingViewCtrl: self)
        alertHandler.showInformationAlert(title: L10n.Global.Titles.warning, message: L10n.Profile.editedSuccessfully)
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

    private func fetchEducationalItems(forIndex index: Int) -> [String] {
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
}

private let viewModel = ProfileViewModel()

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.validFields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProfileTableViewCell",
            for: indexPath
        ) as? ProfileTableViewCell else { return UITableViewCell() }
        let text = viewModel.setTextFieldInfo(forIndexPath: indexPath.row) ?? ""
        let fieldLabel = viewModel.setTextfieldLabel(forIndexPath: indexPath.row)
        let shouldDisableTextField = viewModel.shouldMakeTextFieldDisabled(forIndexPath: indexPath.row)
        let dataModel = ProfileTableViewCellDataModel(
            text: text,
            items: fetchEducationalItems(forIndex: indexPath.row),
            indexPath: indexPath.row,
            fields: viewModel.validFields,
            fieldLabel: fieldLabel,
            shouldDisableTextField: !shouldDisableTextField
        )
        cell.configure(
            dataModel: dataModel
        )
        cell.delegate = self
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ProfileViewController: ProfileTableViwCellProtocol {
    func didFieldChange(text: String, cell: UITableViewCell) {
        guard let index = profileTableView.indexPath(for: cell) else { return }
        guard !text.isValid else {
            saveButton.isEnabled = true
            viewModel.editProfileFields(forIndexPath: index.row, withText: text)
            return
        }
    }
}

extension ProfileViewController: AvatarsListDelegate {
    func setAvatar(avatar: Avatar) {
        guard let id = avatar.id else { return }
        let image = getImage(from: avatar)
        avatarButton.setImage(image)
        viewModel.setNewAvatar(avatarId: id)
    }
}
