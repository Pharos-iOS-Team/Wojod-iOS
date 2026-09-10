// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

class AvatarsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var avatarsCollectionView: UICollectionView!
    @IBOutlet private var addAvatarTitleImageView: UIImageView! {
        didSet {
            addAvatarTitleImageView.image = Images.addAvatarTitle
        }
    }
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var submitIconImageView: UIImageView! {
        didSet {
            submitIconImageView.image = Images.localizedNextButton
        }
    }
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.isUserInteractionEnabled = false
        }
    }
    @IBOutlet private var submitButtonLabel: UILabel! {
        didSet {
            submitButtonLabel.text = L10n.Signup.AddAvatar.submit
        }
    }
    @IBOutlet private var skipButton: UIButton! {
        didSet {
            skipButton.setTitle(L10n.Signup.AddAvatar.skip)
        }
    }

    // MARK: - Private Properties

    let viewModel: AvatarsViewModel
    var avatarImages: [Int: UIImage] = [:]
    private var loadingHud: JGProgressHUD?

    init(viewModel: AvatarsViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = AvatarsViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureSubmitButton()
        loadAvatars()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.cancelImageLoading()
    }

    // MARK: - IBBActions

    @IBAction private func didTapOnSubmitButton(_ sender: UIButton) {
        guard viewModel.selectedIndexPath != nil else { return }
        viewModel.saveAvatarSelection()
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

    private func configureSubmitButton() {
        submitButton.isEnabled = false
        submitButton.backgroundColor = .systemGray3
    }

    func updateSubmitButtonState() {
        let enabled = viewModel.selectedIndexPath != nil && !viewModel.avatars.isEmpty
        submitButton.isEnabled = enabled
        submitButton.backgroundColor = enabled ? Colors.sendButtonColor.color : .systemGray3
    }

    private func loadAvatars() {
        loadingIndicator.startAnimating()
        Task { [weak self] in
            guard let self = self else { return }
            _ = await self.viewModel.loadAvatars()
            let imageData = await self.viewModel.preloadAvatarImages()
            await MainActor.run {
                for (index, data) in imageData {
                    if let image = UIImage(data: data) {
                        self.avatarImages[index] = image
                    }
                }
                self.loadingIndicator.stopAnimating()
                self.avatarsCollectionView.reloadData()
                self.animateVisibleCellsIn()
            }
        }
    }

    private func animateVisibleCellsIn() {
        guard let visibleCells = avatarsCollectionView.visibleCells as? [AvatarCell] else { return }
        for (index, cell) in visibleCells.enumerated() {
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            cell.alpha = 0
            UIView.animate(
                withDuration: 0.4,
                delay: Double(index) * 0.05,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut]
            ) {
                cell.transform = .identity
                cell.alpha = 1
            }
        }
    }

    private func showSignupHud() {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        hud.show(in: navigationController?.view ?? view)
        loadingHud = hud
    }

    private func signup() {
        showSignupHud()
        let user = viewModel.buildSignupRequest()
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.signUp(user: user)
                await MainActor.run {
                    self.loadingHud?.dismiss()
                    let mobileNumber = RegistrationStore.shared.state.mobileNumber
                    RegistrationStore.shared.reset()
                    let verifyOtpViewCtrl = StoryboardScene.VerifyOtp.verifyOtpViewController.instantiate().with {
                        $0.viewModel = .init(
                            mobileNumber: mobileNumber,
                            otpProvider: .whatsapp,
                            verifyUserFromLogin: true,
                            hideBackButton: true,
                            successHandler: {
                                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
                            }
                        )
                    }
                    let navCtrl = UINavigationController(rootViewController: verifyOtpViewCtrl)
                    navCtrl.modalPresentationStyle = .fullScreen
                    self.present(navCtrl, animated: true, completion: nil)
                }
            } catch {
                await MainActor.run {
                    self.loadingHud?.dismiss()
                    self.updateSubmitButtonState()
                    AlertHandler(presentingViewCtrl: self).showInformationAlert(
                        title: L10n.Global.Titles.error, message: (error as? ApiError)?.errorDescription ?? L10n.Global.Alerts.somethingWentWrong
                    )
                }
            }
        }
    }
}

// MARK: - Navigation

extension AvatarsViewController {
    @objc
    func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    private func configureNavigationBar() {
        let backButton = UIBarButtonItem(image: Images.localizedBackButton, style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
}
