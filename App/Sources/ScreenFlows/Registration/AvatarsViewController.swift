// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AvatarsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var avatarsCollectionView: UICollectionView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidesWhenStopped = true
        }
    }

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var avatars: [Avatar] = []
    private var previouslySelectedAvatarIndexPath: IndexPath?
    private var sharedUser = User.shared.self

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        configureCollectionView()
        loadAvatars()
    }

    // MARK: - IBBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }

    @IBAction private func didTapOnSubmitButton(_ sender: UIButton) {
        guard previouslySelectedAvatarIndexPath != nil else {
            AlertHandler(presentingViewCtrl: self).showInformationAlert(title: "Error", message: "Please choose an avatar first.")
            return
        }
        sharedUser.avatar = self.avatars[previouslySelectedAvatarIndexPath?.item ?? 0]
        signup()
    }

    @IBAction private func didTapOnSkipButton(_ sender: UIButton) {
        signup()
    }

    // MARK: - Private Functions

    private func configureCollectionView() {
        avatarsCollectionView.dataSource = self
        avatarsCollectionView.delegate = self
    }

    private func loadAvatars() {
        loadingIndicator.startAnimating()
        viewModel?.loadAvatars { avatars in
            self.loadingIndicator.stopAnimating()
            self.avatars = avatars
            self.avatarsCollectionView.reloadData()
        }
    }

    private func getImage(from url: String) -> UIImage? {
        let imageURL = Environment.baseURLString + url
        guard let url = URL(string: imageURL), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    // swiftlint:disable function_body_length
    private func signup() {
        loadingIndicator.startAnimating()
        let user = UserSignupRequest(
            name: sharedUser.nameEn,
            mobileNumber: sharedUser.mobileNumber,
            mobileNumber2: nil,
            homeNumber: sharedUser.homeNumber,
            email: sharedUser.email,
            password: sharedUser.password,
            confirmPassword: sharedUser.password,
            country: sharedUser.country,
            city: sharedUser.city,
            region: sharedUser.region,
            address: sharedUser.address,
            firstParentNumber: sharedUser.parentNumber,
            secondParentNumber: sharedUser.parentNumber2,
            schoolName: sharedUser.schoolName,
            batchID: sharedUser.batch,
            specializationID: sharedUser.specializationId,
            avatarID: sharedUser.avatar?.id
        )
        viewModel?.signUp(user: user) { _, error in
            self.loadingIndicator.stopAnimating()
            if error == nil {
                ScreensFlowConfigurationAppDelegate().navigateToMainScreen()
            } else {
                let alertHandler = AlertHandler(presentingViewCtrl: self)
                alertHandler.showInformationAlert(
                    title: L10n.Global.Titles.error, message: error?.localizedDescription ?? L10n.Global.Alerts.somethingWentWrong
                )
            }
        }
    }
}

// MARK: - Collection View Data Source

extension AvatarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AvatarCell = collectionView.dequeCell(indexPath: indexPath)
        if let image = getImage(from: avatars[indexPath.row].thumbnailUrl ?? "") {
            cell.setImageView(with: image)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previousSelectedIndexPath = previouslySelectedAvatarIndexPath {
            let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? AvatarCell
            previousCell?.unselectImage()
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AvatarCell
        previouslySelectedAvatarIndexPath = indexPath
        cell?.selectImage()
    }
}

// MARK: - Collection View Delegate Flow Layout

extension AvatarsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }
}
