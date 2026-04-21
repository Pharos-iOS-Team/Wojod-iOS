// Copyright © 2026 Pharos Solutions. All rights reserved.
// swiftlint:disable private_outlet

import UIKit

final class AcademicInfoViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var academicInfoTitleImageView: UIImageView! {
        didSet { academicInfoTitleImageView.image = Images.academicInfoTitle }
    }
    @IBOutlet var letsKnowMoreTitleImageView: UIImageView! {
        didSet { letsKnowMoreTitleImageView.image = Images.letsKnowMoreTitle }
    }
    @IBOutlet var fourthMilestoneImageView: UIImageView!
    @IBOutlet var schoolButton: UIButton!
    @IBOutlet var schoolLabel: UILabel! {
        didSet { schoolLabel.text = L10n.Signup.AcademicInfo.school }
    }
    @IBOutlet var universityButton: UIButton!
    @IBOutlet var universityLabel: UILabel! {
        didSet { universityLabel.text = L10n.Signup.AcademicInfo.university }
    }
    @IBOutlet var wrongCredentialsImageView: UIImageView! {
        didSet { wrongCredentialsImageView.isHidden = true; wrongCredentialsImageView.image = Images.wrongCredentials }
    }
    @IBOutlet var wrongCredentialsImageViewHeight: NSLayoutConstraint! {
        didSet { wrongCredentialsImageViewHeight.constant = 0 }
    }
    @IBOutlet var nextButton: SendButton! {
        didSet { nextButton.isEnabled = false }
    }
    @IBOutlet var schoolContainerView: UIView!
    @IBOutlet var schoolContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var universityContainerView: UIView!
    @IBOutlet var universityContainerViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties

    let viewModel: AcademicInfoViewModel
    private(set) var schoolInfoVC: SchoolInfoViewController?
    private(set) var universityInfoVC: UniversityInfoViewController?

    init(viewModel: AcademicInfoViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = AcademicInfoViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSemanticAttribute()
        embedChildViewControllers()
        configureInitialLayout()
        scrollView.contentInset.bottom = 120
        fourthMilestoneImageView.image = StepIndicatorView.makeImage(currentStep: 2)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideWrongCredentials()
        updateNextButtonState()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnSchool(_ sender: UIButton) {
        if !viewModel.hasChosenTrack {
            animateButtonsToTop { [weak self] in
                guard let self else { return }
                viewModel.academicTrack = .school
                viewModel.hasChosenTrack = true
                configureSchoolView()
                if viewModel.divisionsList.isEmpty { schoolInfoVC?.loadAcademicTypes() }
                updateNextButtonState()
            }
        } else if viewModel.academicTrack != .school {
            viewModel.academicTrack = .school
            viewModel.hasChosenTrack = true
            configureSchoolView()
            if viewModel.divisionsList.isEmpty { schoolInfoVC?.loadAcademicTypes() }
            updateNextButtonState()
        }
    }

    @IBAction private func didTapOnUniversity(_ sender: UIButton) {
        if !viewModel.hasChosenTrack {
            animateButtonsToTop { [weak self] in
                guard let self else { return }
                viewModel.academicTrack = .university
                viewModel.hasChosenTrack = true
                configureUniversityView()
                updateNextButtonState()
            }
        } else if viewModel.academicTrack != .university {
            viewModel.academicTrack = .university
            viewModel.hasChosenTrack = true
            configureUniversityView()
            updateNextButtonState()
        }
    }

    @IBAction private func didTapOnNext(_ sender: SendButton) {
        saveStateToStore()
        let errors = viewModel.validationErrors()
        guard errors.isEmpty else { showValidationErrors(errors); return }
        viewModel.navigateToAvatars(from: self)
    }

    // MARK: - Child VC Embedding

    private func embedChildViewControllers() {
        viewModel.onFormDidChange = { [weak self] in self?.updateNextButtonState() }
        viewModel.onRequestContainerResize = { [weak self] height, completion in
            guard let self else { return }
            universityContainerViewHeightConstraint.constant = height
            completion()
        }

        let schoolViewCtrl = SchoolInfoViewController(viewModel: viewModel)
        embed(schoolViewCtrl, in: schoolContainerView)
        self.schoolInfoVC = schoolViewCtrl

        let universityViewCtrl = UniversityInfoViewController(viewModel: viewModel)
        embed(universityViewCtrl, in: universityContainerView)
        self.universityInfoVC = universityViewCtrl
    }

    private func embed(_ childVC: UIViewController, in container: UIView) {
        addChild(childVC)
        container.addSubview(childVC.view)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childVC.view.topAnchor.constraint(equalTo: container.topAnchor),
            childVC.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            childVC.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        childVC.didMove(toParent: self)
    }
}
