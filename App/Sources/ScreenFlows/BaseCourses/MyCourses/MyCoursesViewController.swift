// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftyUserDefaults
import UIKit

final class MyCoursesViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var notificationButton: UIButton! {
        didSet {
            notificationButton.isHidden = Defaults[\.isGuestModeEnabled]
        }
    }
    @IBOutlet private var helpCenterButton: UIButton! {
        didSet {
            helpCenterButton.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
    @IBOutlet private var helpCenterLabel: UILabel! {
        didSet {
            helpCenterLabel.text = L10n.Home.helpCenter
        }
    }

    private var viewModel: MyCoursesViewModel
    private let navigationCoordinator: CoursesNavigationCoordinating
    private let loadingIndicatorPresenter: LoadingIndicatorPresenter
    private let searchDebouncer: SearchDebouncer
    private var receiptPresenter: ReceiptPresenter?
    private var tableController: CourseListTableController?
    private var isFirstScreenLoad: Bool = true
    private let refreshControl = UIRefreshControl()

    init(
        viewModel: MyCoursesViewModel = MyCoursesViewModel(),
        navigationCoordinator: CoursesNavigationCoordinating = CoursesNavigationCoordinator()
    ) {
        self.viewModel = viewModel
        self.navigationCoordinator = navigationCoordinator
        self.loadingIndicatorPresenter = LoadingIndicatorPresenter(view: UIView())
        self.searchDebouncer = SearchDebouncer()
        super.init(nibName: "MyCoursesViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorPresenter.view = view
        receiptPresenter = ReceiptPresenter(viewController: self)
        configureTableView()
        configureRefreshControl()
        configureInfiniteScrolling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingIndicatorPresenter.show()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserProfile { [weak self] in
            self?.loadCourses()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllPlayingVideos()
        loadingIndicatorPresenter.hide()
    }

    @IBAction private func didTapNotificationsButton(_ sender: UIButton) {
        navigationCoordinator.showNotifications(from: self)
    }

    @IBAction private func didTapHelpCenterButton(_ sender: UIButton) {
        navigationCoordinator.showHelpCenter(from: self)
    }

    // MARK: - Private

    private func configureTableView() {
        tableController = CourseListTableController(
            tableView: tableView,
            viewModel: viewModel,
            isMyCourses: true,
            headerProvider: { [weak self] in self?.tableViewHeader() },
            courseDetailsDelegate: self,
            selectCellDelegate: self,
            receiptDelegate: self,
            navigationCoordinator: navigationCoordinator
        )
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func configureInfiniteScrolling() {
        tableController?.configureInfiniteScrolling { [weak self] in
            self?.loadCourses()
        }
    }

    private func tableViewHeader() -> UIView? {
        let headerView = tableView.dequeueHeaderFooterView(ofType: HomeTableViewHeader.self)
        headerView?.delegate = self
        headerView?.setSubjects(viewModel.subjects)
        headerView?.selectedSubjectIndexPath = viewModel.selectedSubjectIndexPath

        if isFirstScreenLoad {
            isFirstScreenLoad = false
            headerView?.selectRelatedCoursesButton()
        }

        headerView?.setButtonsVisibility(true)
        headerView?.setSubjectsVisibility(viewModel.mode == .relatedCourses)
        headerView?.setAdvertisementsVisibility(false)
        return headerView
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        loadUserProfile()
        viewModel.resetPagination()
        loadCourses()
    }

    private func loadUserProfile(completion: (() -> Void)? = nil) {
        // Profile loading is handled by the service, but we can add completion here if needed
        completion?()
    }

    private func loadCourses() {
        loadingIndicatorPresenter.show()
        viewModel.loadCourses { [weak self] in
            self?.loadingIndicatorPresenter.hide()
            self?.tableController?.finishInfiniteScroll()
        }
    }

    private func stopAllPlayingVideos() {
        for cell in tableView.visibleCells {
            if let courseCell = cell as? CourseTableViewCell {
                courseCell.stopAnyPlayingVideoIfAny()
            }
        }
    }
}

extension MyCoursesViewController: ViewReceiptDelegate {
    func displayReceipt(_ receipt: Receipt) {
        receiptPresenter?.showReceipt(receipt)
    }
}

extension MyCoursesViewController: HomeTableViewHeaderDelegate {
    func didSelectSubject(at indexPath: IndexPath) {
        viewModel.selectedSubjectIndexPath = indexPath
        if indexPath.row < viewModel.subjects.count {
            viewModel.selectSubject(viewModel.subjects[indexPath.row])
            loadCourses()
        }
    }

    func didSelectRelatedCourses() {
        viewModel.selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .relatedCourses)
        tableView.reloadData()
        loadCourses()
    }

    func didSelectExploreMore() {
        viewModel.selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .exploreMore)
        tableView.reloadData()
        loadCourses()
    }

    func textDidChange(in searchBar: UISearchBar) {
        viewModel.updateSearchText(searchBar.text ?? "")
        searchDebouncer.debounce { [weak self, weak searchBar] in
            searchBar?.endEditing(true)
            self?.loadCourses()
        }
    }
}

extension MyCoursesViewController: ViewCourseDetailsDelegate, SelectCourseCellDelegate {
    func showCourseDetails(for course: Course?, with teacherNameIndex: Int) {
        guard teacherNameIndex < viewModel.courses.count else { return }
        let subjectCourse = viewModel.courses[teacherNameIndex]
        let teacherName = subjectCourse.teacher?.name
        let teacherID = subjectCourse.teacher?.id
        navigationCoordinator.showCourseDetails(
            course: course,
            teacherName: teacherName,
            teacherID: teacherID,
            from: self
        )
    }
}
