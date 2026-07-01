// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import AVFoundation
import AVKit
import DZNEmptyDataSet
import HandySwift
import JGProgressHUD
import UIKit
import VdoFramework

class CourseDetailsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = UIConstants.cornerRadius
            actionButton.setTitle(L10n.CourseDetails.Main.contactUs)
        }
    }
    @IBOutlet private var bookByQRButton: UIButton! {
        didSet {
            bookByQRButton.layer.cornerRadius = UIConstants.cornerRadius
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
    var loadedTabs: Set<ActiveScreen> = []
    @IBOutlet var floatingBackBubble: UIVisualEffectView?
    var downloadHud: JGProgressHUD?
    var courseHeaderView: CourseDetailsInfoHeaderView?
    var blurredView: UIVisualEffectView?
    var activeSubscreen: CourseDetailsActiveSubScreen = .details
    lazy var alertHandler = AlertHandler(presentingViewCtrl: self)
    var course: Course!
    var hideViews: Bool = false
    var teacherName: String?
    var teacherID: Int?

    // MARK: - MVVM Components

    lazy var viewModel: CourseDetailsViewModel = {
        return CourseDetailsViewModel().with {
            $0.course = course
            $0.hideViews = hideViews
            $0.courseState = course.getReservationState()
        }
    }()
    lazy var coordinator: CourseDetailsNavigationCoordinating = CourseDetailsCoordinator()
    lazy var videoPlaybackService: VideoPlaybackService = VideoPlaybackService(alertHandler: alertHandler)
    lazy var documentService: DocumentService = DocumentService(presentingViewController: self)
    lazy var dataSource: CourseDetailsDataSource = CourseDetailsDataSource(viewModel: viewModel)
    lazy var emptyStateDelegate: CourseDetailsEmptyStateDelegate = CourseDetailsEmptyStateDelegate(viewModel: viewModel)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDependencies()
        setupTableView()
        setupRefreshControl()
        bindViewModel()
        observeInternetConnection()
        applyScreenshotPreventingView()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayerMuteState), name: UIScreen.capturedDidChangeNotification, object: nil)
        setHeader()
        floatingBackBubble?.layer.cornerRadius = 18
        floatingBackBubble?.clipsToBounds = true
        configureActionButtonAccordingToState()
        configureQRButtonVisibility()
        loadCourseDetails()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.contentInset.top == 0 {
            tableView.contentInset.top = view.safeAreaInsets.top
        }
        tableView.autoResizeTableHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        guard viewModel.course != nil else { return }
        switch viewModel.activeScreen {
        case .materials:
            let isFirstLoad = !loadedTabs.contains(.materials)
            if isFirstLoad {
                showContentSpinner()
            } else {
                reloadTablePreservingOffset()
            }
            viewModel.handleRefreshingAccordingToOpenedTab { [weak self] in
                guard let self else { return }
                self.loadedTabs.insert(.materials)
                if isFirstLoad { self.hideContentSpinner() }
                self.reloadTablePreservingOffset()
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
                      let info = viewModel.course.contactUsInfo else { return }
                coordinator.showContactUs(info: info, from: self)
            case .booked:
                blurView()
                coordinator.showReviewCourse(delegate: self, from: self)
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
            self?.viewModel.updateVideo(videoId: videoId, updateObject: updateObject)
        }
        VdoCipher.setPlaybackDelegate(delegate: videoPlaybackService)
    }

    private func setupTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        if let existingTopConstraint = view.constraints.first(where: {
            ($0.firstItem as? UITableView == tableView || $0.secondItem as? UITableView == tableView)
            && ($0.firstAttribute == .top || $0.secondAttribute == .top)
        }) {
            existingTopConstraint.isActive = false
            tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        tableView.registerCell(ofType: AttachmentTableViewCell.self)
        tableView.registerCell(ofType: ReviewTableViewCell.self)
        tableView.registerCell(ofType: MaterialTableViewCell.self)
        tableView.registerHeaderFooterView(ofType: CourseDetailsHeaderView.self)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.emptyDataSetSource = emptyStateDelegate
        tableView.emptyDataSetDelegate = emptyStateDelegate
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
            self.coordinator.showAssessmentDetails(status: .open, module: module, assessmentID: assessmentID, assessmentDetails: details, delegate: self, from: self)
        }
        viewModel.onShowAssessmentResults = { [weak self] module, assessmentID, details in
            guard let self else { return }
            self.coordinator.showAssessmentDetails(status: .closed, module: module, assessmentID: assessmentID, assessmentDetails: details, delegate: self, from: self)
        }
    }

    // MARK: - Private Helpers

    private func loadCourseDetails() {
        viewModel.loadCourseDetails { [weak self] in
            guard let self else { return }
            self.setHeader()
            self.configureActionButtonAccordingToState()
            self.configureQRButtonVisibility()
            self.tableView.reloadData()
            self.handleRefreshingAccordingToOpenedTab()
        }
    }

    private func loadCourseLessons(preservingOffset: Bool = false) {
        viewModel.loadCourseLessons { [weak self] in
            guard let self else { return }
            let reload: () -> Void = { [weak self] in
                preservingOffset ? self?.reloadTablePreservingOffset() : self?.tableView.reloadData()
            }
            let sectionsToCheck = (self.viewModel.lessonNumbersList ?? [])
                .map { $0 - 1 }
                .filter { !self.viewModel.expandedSections.contains($0) }
            guard !sectionsToCheck.isEmpty else {
                reload()
                return
            }
            let group = DispatchGroup()
            sectionsToCheck.forEach { section in
                group.enter()
                self.viewModel.checkAttachmentPresence(section: section) {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                reload()
            }
        }
    }

    private func handleRefreshingAccordingToOpenedTab() {
        viewModel.handleRefreshingAccordingToOpenedTab { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.hideLoadingIndicator()
        }
    }

    private func setHeader() {
        if courseHeaderView == nil {
            let detailsView = CourseDetailsInfoHeaderView()
            detailsView.prepareImmersiveStyle()
            courseHeaderView = detailsView
            tableView.tableHeaderView = detailsView
        }
        courseHeaderView?.configure(model: makeHeaderModel())
    }

    private func makeHeaderModel() -> CourseDetailsInfoModel {
        CourseDetailsInfoModel(
            courseTitle: viewModel.course?.name,
            teacherName: teacherName,
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

    @IBAction private func didTapFloatingBackButton(_ sender: UIButton) {
        removeScreenshotPreventingView()
        coordinator.dismiss(from: self)
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
        blurredView?.removeFromSuperview()
        blurredView = nil
    }

    private func blurView() {
        guard blurredView == nil else { return }
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        view.addSubview(blurEffectView)
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
        contentLoadingTopConstraint?.constant = tableView.tableHeaderView?.frame.height ?? 0
        contentLoadingView?.isHidden = false
    }

    func hideContentSpinner() {
        contentLoadingView?.isHidden = true
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
        viewModel.bookCourse(qrCode: qrCode) { [weak self] bookingResponse, error in
            guard let self else { return }
            if error == nil {
                let shouldShowReceipt = self.viewModel.handleBookingSuccess(bookingResponse: bookingResponse, isQR: qrCode != nil)
                self.loadCourseDetails()
                if shouldShowReceipt, let response = bookingResponse {
                    self.blurView()
                    self.coordinator.showReceipt(response, coursePrice: self.viewModel.course?.price ?? "", from: self)
                }
            } else if let error = error as? WJError {
                alertHandler.showInformationAlert(title: L10n.Shared.Alerts.error, message:error.message)
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
