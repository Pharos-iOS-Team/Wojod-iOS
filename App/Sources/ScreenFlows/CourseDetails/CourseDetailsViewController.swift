// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import AVKit
import Combine
import DZNEmptyDataSet
import HandySwift
import JGProgressHUD
import UIKit
import VdoFramework

class CourseDetailsViewController: UIViewController, CourseDetailsTableViewManagerHost {
    // MARK: - Factory

    static func make(viewModel: CourseDetailsViewModel, coordinator: CourseDetailsCoordinator) -> CourseDetailsViewController {
        let courseDetailsViewCtrl = StoryboardScene.CourseDetails.initialScene.instantiate()
        courseDetailsViewCtrl.viewModel = viewModel
        courseDetailsViewCtrl.coordinator = coordinator
        return courseDetailsViewCtrl
    }

    // MARK: - IBOutlets

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var contentLoadingView: UIView?
    @IBOutlet private var contentLoadingTopConstraint: NSLayoutConstraint?
    @IBOutlet private var actionButton: UIButton! {
        didSet { actionButton.setTitle(L10n.CourseDetails.Main.contactUs) }
    }
    @IBOutlet private var bookByQRButton: UIButton! {
        didSet { bookByQRButton.setTitle(L10n.CourseDetails.Main.bookByQR) }
    }

    // MARK: - Properties

    lazy var tableViewManager: CourseDetailsTableViewManager = CourseDetailsTableViewManager(viewModel: viewModel, host: self)
    let refreshControl = UIRefreshControl()
    var loadingHud: JGProgressHUD?
    var courseHeaderView: CourseDetailsInfoHeaderView?
    var headerTopConstraint: NSLayoutConstraint?
    lazy var videoPlaybackService: VideoPlaybackService = VideoPlaybackService(alertHandler: alertHandler)
    private lazy var alertHandler = AlertHandler(presentingViewCtrl: self)
    private var blurredView: UIVisualEffectView?
    private var cancellables: Set<AnyCancellable> = []

    var viewModel: CourseDetailsViewModel!
    var coordinator: CourseDetailsCoordinator!

    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupVideoPlayback()
        setupAudioSession()
        setupTableView()
        setupRefreshControl()
        bindViewModel()
        coordinator.bind(to: viewModel, presentingFrom: self)
        observeInternetConnection()
        applyScreenshotPreventingView()
        loadInitialData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.autoResizeTableHeaderView()
        contentLoadingTopConstraint?.constant = tableView.tableHeaderView?.frame.height ?? 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent || isBeingDismissed else { return }
        removeScreenshotPreventingView()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnActionButton(_ sender: UIButton) {
        viewModel.handleActionButtonTapped()
    }

    @IBAction private func didTapOnQRCodeBooking(_ sender: UIButton) {
        viewModel.handleQRBookingTapped()
    }

    // MARK: - Setup

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let topInset = view.safeAreaInsets.top
        tableView.contentInset.top = topInset
        tableView.verticalScrollIndicatorInsets.top = topInset
        headerTopConstraint?.constant = -topInset
        if !viewModel.state.didSetInitialContentOffset {
            viewModel.state.didSetInitialContentOffset = true
            tableView.contentOffset.y = -topInset
        }
        tableView.autoResizeTableHeaderView()
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

    @objc
    private func didTapBack() {
        viewModel.dismissTapped()
    }

    private func setupTableView() {
        tableViewManager.setup(in: tableView)
    }

    private func setupRefreshControl() {
        refreshControl.tintColor = Colors.sendButtonColor.color
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupVideoPlayback() {
        videoPlaybackService.onUpdateVideo = { [weak self] videoId, updateObject in
            Task { await self?.viewModel.updateVideo(videoId: videoId, updateObject: updateObject) }
        }
        VdoCipher.setPlaybackDelegate(delegate: videoPlaybackService)
    }

    private func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlayerMuteState),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }

    private func loadInitialData() {
        Task { [weak self] in
            guard let self else { return }
            if await viewModel.loadCourseDetails() {
                viewModel.loadActiveTab()
            }
        }
    }

    // MARK: - Combine Bindings

    private func bindViewModel() {
        viewModel.state.$error
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.alertHandler.showInformationAlert(title: L10n.Shared.Alerts.error, message: message)
            }
            .store(in: &cancellables)

        viewModel.state.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading { self?.showLoadingIndicator() } else {
                    self?.hideLoadingIndicator()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.state.$isContentLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isContentLoading in
                if isContentLoading { self?.showContentSpinner() } else { self?.hideContentSpinner() }
            }
            .store(in: &cancellables)

        viewModel.state.$course
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                setHeader()
                configureActionButtonAccordingToState()
                configureQRButtonVisibility()
                reloadTablePreservingOffset()
                tableView.autoResizeTableHeaderView()
            }
            .store(in: &cancellables)

        Publishers.MergeMany(
            viewModel.state.$lessonsList.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$reviewsList.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$materialsDomain.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$attachmentsOfLessons.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$expandedSections.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$doesLessonContainAttachments.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$activeScreen.map { _ in () }.eraseToAnyPublisher(),
            viewModel.state.$isLoadingTab.map { _ in () }.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in self?.reloadTablePreservingOffset() }
        .store(in: &cancellables)

        viewModel.state.$assessmentLoadingIndexPath
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPath in
                guard let self else { return }
                if let indexPath {
                    let cell = tableView.cellForRow(at: indexPath) as? MaterialTableViewCell
                    cell?.startLoadingIndicator()
                    tableView.isUserInteractionEnabled = false
                } else {
                    tableView.isUserInteractionEnabled = true
                    tableView.visibleCells
                        .compactMap { $0 as? MaterialTableViewCell }
                        .forEach { $0.stopLoadingIndicator() }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Header

    private func setHeader() {
        if courseHeaderView == nil {
            let detailsView = CourseDetailsInfoHeaderView().with {
                $0.prepareImmersiveStyle()
                $0.delegate = self
            }
            courseHeaderView = detailsView
            tableView.tableHeaderView = makeHeaderWrapper(for: detailsView)
        }
        courseHeaderView?.configure(model: viewModel.courseHeaderModel())
    }

    private func makeHeaderWrapper(for detailsView: CourseDetailsInfoHeaderView) -> UIView {
        let wrapper = UIView()
        wrapper.clipsToBounds = false
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(detailsView)
        let topConstraint = detailsView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: -view.safeAreaInsets.top)
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

    // MARK: - Action Button

    private func configureActionButtonAccordingToState() {
        actionButton.isHidden = !viewModel.isContactInfoAvailable
        switch viewModel.state.course?.parsedState ?? .normal {
        case .normal:
            actionButton.setTitle(L10n.CourseDetails.Main.contactUs)
        case .booked:
            actionButton.setTitle(L10n.CourseDetails.Main.reviewCourse)
        default:
            return
        }
    }

    private func configureQRButtonVisibility() {
        bookByQRButton.isHidden = !viewModel.shouldShowQRButton
    }

    // MARK: - UI Helpers

    func blurView() {
        guard blurredView == nil else { return }
        let blurEffectView = UIVisualEffectView(effect: nil)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        view.addSubview(blurEffectView)
        UIView.animate(withDuration: 0.3) { blurEffectView.effect = UIBlurEffect(style: .light) }
    }

    func dismissBlurView() {
        guard let blurredView else { return }
        UIView.animate(withDuration: 0.3, animations: { blurredView.effect = nil }, completion: { _ in
            blurredView.removeFromSuperview()
            self.blurredView = nil
        })
    }

    func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: view, animated: true)
    }

    func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    private func showContentSpinner() {
        guard let contentLoadingView else { return }
        contentLoadingView.alpha = 0
        contentLoadingView.isHidden = false
        UIView.animate(withDuration: 0.25) { contentLoadingView.alpha = 1 }
    }

    private func hideContentSpinner() {
        guard let contentLoadingView else { return }
        UIView.animate(withDuration: 0.25, animations: { contentLoadingView.alpha = 0 }, completion: { _ in
            contentLoadingView.isHidden = true
        })
    }

    func showQRCodeActionSheet() {
        alertHandler.showQRCodeActionSheet(
            sourceView: bookByQRButton,
            onScan: { [weak self] in self?.viewModel.state.routeSubject = .showQRCodeScanner },
            onManual: { [weak self] in self?.viewModel.state.routeSubject = .showQRCodeManually }
        )
    }

    func reloadTablePreservingOffset() {
        let offset = tableView.contentOffset
        tableView.reloadData()
        tableView.setContentOffset(offset, animated: false)
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        Task { [weak self] in
            guard let self else { return }
            if await viewModel.loadCourseDetails() {
                viewModel.loadActiveTab()
            } else {
                tableView.refreshControl?.endRefreshing()
            }
        }
    }

    @objc
    private func updatePlayerMuteState() {
        videoPlaybackService.updatePlayerMuteState()
    }
}

// MARK: - CourseDetailsInfoHeaderDelegate
extension CourseDetailsViewController: CourseDetailsInfoHeaderDelegate {
    func showDetails() {
        viewModel.handleTabSelected(.details)
    }

    func showMaterials() {
        viewModel.handleTabSelected(.materials)
    }

    func showReviews() {
        viewModel.handleTabSelected(.reviews)
    }

    func goToChat() {
        viewModel.chatTapped()
    }

    func dismissView() {
        viewModel.dismissTapped()
    }

    func playCourseVideo(playerController: AVPlayerViewController) {
        addChild(playerController)
    }
}

// MARK: - AssetPlaybackDelegate + UIViewControllerTransitioningDelegate
extension CourseDetailsViewController: AssetPlaybackDelegate, UIViewControllerTransitioningDelegate {
    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        videoPlaybackService.streamPlaybackManager(playerReadyToPlay: player)
    }

    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        videoPlaybackService.streamPlaybackManager(playerCurrentItemDidChange: player)
    }

    func streamLoadError(error: VdoFramework.VdoError) {
        hideLoadingIndicator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        videoPlaybackService.invalidateTimer()
        return nil
    }
}
