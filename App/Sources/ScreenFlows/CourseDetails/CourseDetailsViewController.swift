// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import AVFoundation
import AVKit
import DZNEmptyDataSet
import HandySwift
import JGProgressHUD
import UIKit
import VdoFramework

class CourseDetailsViewController: UIViewController, CourseDetailsTableViewManagerHost {
    @IBOutlet var tableView: UITableView!
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.setTitle(L10n.CourseDetails.Main.contactUs)
        }
    }
    @IBOutlet private var bookByQRButton: UIButton! {
        didSet {
            bookByQRButton.setTitle(L10n.CourseDetails.Main.bookByQR)
        }
    }

    // MARK: - Properties

    let detailsRowHeight: CGFloat = 50
    let reviewsRowHeight: CGFloat = 90
    let refreshControl = UIRefreshControl()
    var loadingHud: JGProgressHUD?
    @IBOutlet var contentLoadingView: UIView?
    @IBOutlet var contentLoadingTopConstraint: NSLayoutConstraint?
    var isContentLoading = false
    var loadedTabs: Set<ActiveScreen> = []
    var courseHeaderView: CourseDetailsInfoHeaderView?
    private var headerTopConstraint: NSLayoutConstraint?
    private var didSetInitialContentOffset = false
    var blurredView: UIVisualEffectView?
    var activeSubscreen: CourseDetailsActiveSubScreen = .details

    lazy var alertHandler = AlertHandler(presentingViewCtrl: self)

    // MARK: - MVVM Components

    var viewModel: CourseDetailsViewModel!
    var coordinator: CourseDetailsNavigationCoordinating!
    lazy var videoPlaybackService: VideoPlaybackService = VideoPlaybackService(alertHandler: alertHandler)
    lazy var tableViewManager: CourseDetailsTableViewManager = CourseDetailsTableViewManager(viewModel: viewModel, host: self)

    // MARK: - Factory

    static func make(viewModel: CourseDetailsViewModel, coordinator: CourseDetailsNavigationCoordinating) -> CourseDetailsViewController {
        let viewController = StoryboardScene.CourseDetails.initialScene.instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupDependencies()
        setupTableView()
        setupRefreshControl()
        bindViewModel()
        observeInternetConnection()
        applyScreenshotPreventingView()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayerMuteState), name: UIScreen.capturedDidChangeNotification, object: nil)
        setHeader()
        configureActionButtonAccordingToState()
        configureQRButtonVisibility()
        loadCourseDetails()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.autoResizeTableHeaderView()
        contentLoadingTopConstraint?.constant = tableView.tableHeaderView?.frame.height ?? 0
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let topInset = view.safeAreaInsets.top
        tableView.contentInset.top = topInset
        tableView.verticalScrollIndicatorInsets.top = topInset
        headerTopConstraint?.constant = -topInset
        if !didSetInitialContentOffset {
            didSetInitialContentOffset = true
            tableView.contentOffset.y = -topInset
        }
        tableView.autoResizeTableHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard viewModel.course != nil else { return }
        switch viewModel.activeScreen {
        case .materials:
            let isFirstLoad = !loadedTabs.contains(.materials)
            if isFirstLoad {
                showContentSpinner()
            } else {
                reloadTablePreservingOffset()
            }
            Task { [weak self] in
                guard let self else { return }
                await self.viewModel.handleRefreshingAccordingToOpenedTab()
                await MainActor.run {
                    self.loadedTabs.insert(.materials)
                    if isFirstLoad { self.hideContentSpinner() }
                    self.reloadTablePreservingOffset()
                }
            }
        case .details:
            loadCourseLessons(preservingOffset: true)
        case .reviews:
            break
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent || isBeingDismissed else { return }
        removeScreenshotPreventingView()
        viewModel.expandedSections.removeAll()
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - IBActions

    @IBAction private func didTapOnActionButton(_ sender: UIButton) {
        if viewModel.isGuestModeEnabled() {
            showLoadingIndicator()
            coordinator.logout()
        } else {
            switch viewModel.courseState {
            case .normal:
                guard viewModel.isContactInfoAvailable,
                      let info = viewModel.course?.contactUsInfo else { return }
                coordinator.showContactUs(info: info, from: self)
            case .booked:
                blurView()
                coordinator.showReviewCourse(
                    from: self,
                    sendReview: { [weak self] review in
                        await self?.viewModel.sendReview(courseID: self?.viewModel.course?.id ?? 0, courseReview: review) ?? false
                    },
                    onComplete: { [weak self] success in
                        if success { self?.dismissBlurView() }
                    },
                    onSkip: { [weak self] in
                        self?.dismissBlurView()
                    }
                )
            default:
                return
            }
        }
    }

    @IBAction private func didTapOnQRCodeBooking(_ sender: UIButton) {
        if viewModel.isGuestModeEnabled() {
            showLoadingIndicator()
            coordinator.logout()
        } else {
            showQRCodeActionSheet()
        }
    }

    // MARK: - Setup

    private func setupDependencies() {
        videoPlaybackService.onUpdateVideo = { [weak self] videoId, updateObject in
            Task { await self?.viewModel.updateVideo(videoId: videoId, updateObject: updateObject) }
        }
        VdoCipher.setPlaybackDelegate(delegate: videoPlaybackService)
    }

    private func setupNavigationController() {
        let backButton = UIBarButtonItem(
            image: Images.localizedBackButton,
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func didTapBack() {
        removeScreenshotPreventingView()
        dismiss(animated: true)
    }

    private func setupTableView() {
        tableViewManager.setup(in: tableView)
    }

    private func setupRefreshControl() {
        refreshControl.tintColor = Colors.sendButtonColor.color
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // MARK: - ViewModel Bindings

    private func bindViewModel() {
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            alertHandler.showInformationAlert(title: L10n.Shared.Alerts.error, message: message)
        }
        viewModel.onShowQuizAlert = { [weak self] assessment in
            self?.showStartQuizAlert(assessment)
        }
        viewModel.onOpenAssessment = { [weak self] module, assessmentID, details in
            guard let self else { return }
            self.hideLoadingIndicator()
            self.coordinator.showAssessmentDetails(status: .open, module: module, assessmentID: assessmentID, assessmentDetails: details, onDidFinishAssessment: { [weak self] _ in
                self?.tableView.reloadData()
            }, from: self)
        }
        viewModel.onShowAssessmentResults = { [weak self] module, assessmentID, details in
            guard let self else { return }
            self.coordinator.showAssessmentDetails(status: .closed, module: module, assessmentID: assessmentID, assessmentDetails: details, onDidFinishAssessment: { [weak self] _ in
                self?.tableView.reloadData()
            }, from: self)
        }
    }

    // MARK: - Private Helpers

    private func loadCourseDetails() {
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.loadCourseDetails()
            await MainActor.run {
                self.setHeader()
                self.configureActionButtonAccordingToState()
                self.configureQRButtonVisibility()
                self.tableView.reloadData()
                self.tableView.autoResizeTableHeaderView()
            }
            await self.viewModel.handleRefreshingAccordingToOpenedTab()
            await MainActor.run {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                self.hideLoadingIndicator()
            }
        }
    }

    private func loadCourseLessons(preservingOffset: Bool = false) {
        showContentSpinner()
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.loadCourseLessonsWithDetails()
            await MainActor.run {
                self.hideContentSpinner()
                preservingOffset ? self.reloadTablePreservingOffset() : self.tableView.reloadData()
            }
        }
    }

    private func handleRefreshingAccordingToOpenedTab() {
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.handleRefreshingAccordingToOpenedTab()
            await MainActor.run {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                self.hideLoadingIndicator()
            }
        }
    }

    private func setHeader() {
        if courseHeaderView == nil {
            let detailsView = CourseDetailsInfoHeaderView()
            detailsView.prepareImmersiveStyle()
            courseHeaderView = detailsView
            tableView.tableHeaderView = makeHeaderWrapper(for: detailsView)
        }
        courseHeaderView?.configure(model: makeHeaderModel())
    }

    private func makeHeaderWrapper(for detailsView: CourseDetailsInfoHeaderView) -> UIView {
        let wrapper = UIView()
        wrapper.clipsToBounds = false
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(detailsView)
        let topConstraint = detailsView.topAnchor.constraint(
            equalTo: wrapper.topAnchor,
            constant: -view.safeAreaInsets.top
        )
        headerTopConstraint = topConstraint
        NSLayoutConstraint.activate([
            topConstraint,
            detailsView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            detailsView.widthAnchor.constraint(equalTo: wrapper.widthAnchor)
        ])
        return wrapper
    }

    private func makeHeaderModel() -> CourseDetailsInfoModel {
        CourseDetailsInfoModel(
            courseTitle: viewModel.course?.name,
            teacherName: viewModel.teacherName,
            batchName: viewModel.course?.batchName,
            image: viewModel.course?.media?.fileUrl,
            video: viewModel.course?.video,
            description: viewModel.course?.summary,
            price: viewModel.coursePrice,
            numberOfReviews: String(viewModel.course?.reviewsCount ?? .zero),
            rating: viewModel.course?.rating,
            shouldHideMaterials: viewModel.courseState != .booked,
            buttonSelected: viewModel.activeScreen,
            state: viewModel.courseState,
            lessonsUnreadCount: viewModel.course?.lessonsUnreadCount,
            materialsUnreadCount: viewModel.course?.materialsUnreadCount,
            delegate: self
        )
    }

    func loadActiveTab() {
        let isFirstLoad = !loadedTabs.contains(viewModel.activeScreen)
        if isFirstLoad {
            viewModel.clearTabData()
            viewModel.isLoadingTab = true
            tableView.reloadData()
            showContentSpinner()
        } else {
            tableView.reloadData()
        }
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.handleRefreshingAccordingToOpenedTab()
            await MainActor.run {
                self.loadedTabs.insert(self.viewModel.activeScreen)
                if isFirstLoad {
                    self.viewModel.isLoadingTab = false
                    self.hideContentSpinner()
                }
                self.tableView.reloadData()
            }
        }
    }

    private func configureActionButtonAccordingToState() {
        actionButton.isHidden = !viewModel.isContactInfoAvailable
        switch viewModel.courseState {
        case .normal:  actionButton.setTitle(L10n.CourseDetails.Main.contactUs)
        case .booked:  actionButton.setTitle(L10n.CourseDetails.Main.reviewCourse)
        default:       return
        }
    }

    private func configureQRButtonVisibility() {
        bookByQRButton.isHidden = !viewModel.shouldShowQRButton
    }

    func dismissBlurView() {
        guard let blurredView else { return }
        UIView.animate(withDuration: 0.3, animations: {
            blurredView.effect = nil
        }, completion: { _ in
            blurredView.removeFromSuperview()
            self.blurredView = nil
        })
    }

    private func blurView() {
        guard blurredView == nil else { return }
        let blurEffectView = UIVisualEffectView(effect: nil)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        view.addSubview(blurEffectView)
        UIView.animate(withDuration: 0.3) {
            blurEffectView.effect = UIBlurEffect(style: .light)
        }
    }

    func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: view, animated: true)
    }

    func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    func showContentSpinner() {
        guard let contentLoadingView else { return }
        isContentLoading = true
        tableView.reloadData()
        contentLoadingView.alpha = 0
        contentLoadingView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            contentLoadingView.alpha = 1
        }
    }

    func hideContentSpinner() {
        guard let contentLoadingView else { return }
        isContentLoading = false
        UIView.animate(withDuration: 0.25, animations: {
            contentLoadingView.alpha = 0
        }, completion: { _ in
            contentLoadingView.isHidden = true
        })
    }

    private func showQRCodeActionSheet() {
        alertHandler.showQRCodeActionSheet(
            sourceView: bookByQRButton,
            onScan: { [weak self] in
                guard let self else { return }
                self.coordinator.showQRCodeScanner(completion: { [weak self] code in self?.bookCourse(qrCode: code) }, from: self)
            },
            onManual: { [weak self] in
                guard let self else { return }
                self.blurView()
                self.coordinator.showQRCodeManually(from: self, completion: { [weak self] code in
                    self?.dismissBlurView()
                    if let code { self?.bookCourse(qrCode: code) }
                }, onDismiss: { [weak self] in self?.dismissBlurView() })
            }
        )
    }

    private func bookCourse(qrCode: String? = nil) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let bookingResponse = try await viewModel.bookCourse(qrCode: qrCode)
                let shouldShowReceipt = self.viewModel.handleBookingSuccess(bookingResponse: bookingResponse, isQR: qrCode != nil)
                await self.viewModel.loadCourseDetails()
                await MainActor.run {
                    if shouldShowReceipt {
                        self.blurView()
                        self.coordinator.showReceipt(bookingResponse, coursePrice: self.viewModel.course?.price ?? "", from: self)
                    }
                }
            } catch let error as WJError {
                await MainActor.run {
                    self.alertHandler.showInformationAlert(title: L10n.Shared.Alerts.error, message: error.message)
                }
            } catch {
                await MainActor.run {
                    self.alertHandler.showInformationAlert(title: L10n.Shared.Alerts.error, message: error.localizedDescription)
                }
            }
        }
    }

    private func showStartQuizAlert(_ assessment: Assessment) {
        alertHandler.showConfirmAlert(
            title: L10n.Quizzes.alertTitle,
            message: L10n.Quizzes.alertSubTitle,
            confirmButtonTitle: L10n.Quizzes.start
        ) { [weak self] _ in
            self?.showLoadingIndicator()
            self?.viewModel.startAssessmentFromAlert(with: assessment)
        }
    }

    @objc private func refresh(_ sender: AnyObject) {
        loadCourseDetails()
    }

    @objc private func updatePlayerMuteState() {
        videoPlaybackService.updatePlayerMuteState()
    }

    private func reloadTablePreservingOffset() {
        let offset = tableView.contentOffset
        tableView.reloadData()
        tableView.setContentOffset(offset, animated: false)
    }
}
