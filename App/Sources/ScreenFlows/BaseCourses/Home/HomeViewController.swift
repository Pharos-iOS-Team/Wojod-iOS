// Copyright © 2026 Pharos Solutions. All rights reserved.

import HandySwift
import SwiftyUserDefaults
import UIKit

final class HomeViewController: UIViewController {
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
    @IBOutlet private var clearFiltersButton: UIButton! {
        didSet {
            clearFiltersButton.isHidden = true
            clearFiltersButton.setTitle(L10n.Filters.clear)
        }
    }
    @IBOutlet private var filtersButton: UIButton!
    @IBOutlet private var filtersButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: HomeViewModel
    private let navigationCoordinator: CoursesNavigationCoordinating
    private let loadingIndicatorPresenter: LoadingIndicatorPresenter
    private let searchDebouncer: SearchDebouncer
    private var tableController: CourseListTableController?
    private var isFirstScreenLoad: Bool = true
    private var isFiltersSelected: Bool = false
    private var currentFilterSelection = FilterSelection()
    private let refreshControl = UIRefreshControl()

    init(
        viewModel: HomeViewModel = HomeViewModel(),
        navigationCoordinator: CoursesNavigationCoordinating = CoursesNavigationCoordinator()
    ) {
        self.viewModel = viewModel
        self.navigationCoordinator = navigationCoordinator
        self.loadingIndicatorPresenter = LoadingIndicatorPresenter(view: UIView())
        self.searchDebouncer = SearchDebouncer()
        super.init(nibName: "HomeViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction private func didTapNotificationsButton(_ sender: UIButton) {
        navigationCoordinator.showNotifications(from: self)
    }

    @IBAction private func didTapHelpCenterButton(_ sender: UIButton) {
        navigationCoordinator.showHelpCenter(from: self)
    }

    @IBAction private func didTapFiltersButton(_ sender: UIButton) {
        navigationCoordinator.showFilters(delegate: self, currentSelection: currentFilterSelection, from: self)
    }

    @IBAction private func didTapClearFiltersButton(_ sender: UIButton) {
        currentFilterSelection.reset()
        configureFiltersButtonWhenNoFilterSelected()
        viewModel.resetPagination()
        loadCourses()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorPresenter.view = view
        configureTableView()
        configureRefreshControl()
        configureInfiniteScrolling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingIndicatorPresenter.show()
        loadAndConfigureAdvertisements()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureFilterButton()
        loadUserProfile { [weak self] in
            self?.loadCourses()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllPlayingVideos()
        loadingIndicatorPresenter.hide()
    }

    // MARK: - Private

    private func configureTableView() {
        tableController = CourseListTableController(
            tableView: tableView,
            viewModel: viewModel,
            isMyCourses: false,
            headerProvider: { [weak self] in self?.tableViewHeader() },
            courseDetailsDelegate: self,
            selectCellDelegate: self,
            receiptDelegate: nil,
            navigationCoordinator: navigationCoordinator
        )
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func configureInfiniteScrolling() {
        tableController?.configureInfiniteScrolling { [weak self] in
            guard self?.isFiltersSelected == false else { return }
            self?.loadCourses()
        }
    }

    private func tableViewHeader() -> UIView? {
        let headerView = tableView.dequeueHeaderFooterView(ofType: HomeTableViewHeader.self)
        headerView?.delegate = self
        headerView?.setSubjects(viewModel.subjects)
        headerView?.selectedSubjectIndexPath = viewModel.selectedSubjectIndexPath
        headerView?.setAdvertisements(viewModel.advertisements)

        if isFirstScreenLoad {
            isFirstScreenLoad = false
            headerView?.selectRelatedCoursesButton()
        }

        headerView?.setButtonsVisibility(!viewModel.isInSearchMode)
        headerView?.setSubjectsVisibility(!viewModel.isInSearchMode && viewModel.mode == .relatedCourses)
        headerView?.setAdvertisementsVisibility(!viewModel.advertisements.isEmpty && !viewModel.isInSearchMode)
        return headerView
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        loadUserProfile()
        viewModel.resetPagination()
        loadCourses()
        loadAndConfigureAdvertisements()
    }

    private func loadUserProfile(completion: (() -> Void)? = nil) {
        completion?()
    }

    private func loadCourses() {
        loadingIndicatorPresenter.show()
        viewModel.loadCourses { [weak self] in
            self?.loadingIndicatorPresenter.hide()
            self?.tableController?.finishInfiniteScroll()
        }
    }

    private func loadAndConfigureAdvertisements() {
        viewModel.loadAdvertisements { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    private func stopAllPlayingVideos() {
        for cell in tableView.visibleCells {
            if let courseCell = cell as? CourseTableViewCell {
                courseCell.stopAnyPlayingVideoIfAny()
            }
        }
    }

    private func configureFilterButton() {
        if viewModel.mode == .exploreMore {
            filtersButton.isHidden = false
            filtersButtonHeightConstraint.constant = 50
            filtersButton.setTitle(L10n.Filters.showFilters)
        } else {
            filtersButton.isHidden = true
            filtersButtonHeightConstraint.constant = 0
        }
    }

    private func configureFiltersButtonWhenFiltersAreSelected() {
        isFiltersSelected = true
        clearFiltersButton.isHidden = false
        filtersButton.layer.backgroundColor = Colors.green.color.cgColor
        filtersButton.setTitle(AppEnvironment.shouldHideOrganization ? L10n.Filters._2filters : L10n.Filters._4filters)
    }

    private func configureFiltersButtonWhenNoFilterSelected() {
        isFiltersSelected = false
        clearFiltersButton.isHidden = true
        filtersButton.layer.backgroundColor = Colors.sendButtonColor.color.cgColor
        filtersButton.setTitle(L10n.Filters.showFilters)
    }
}

extension HomeViewController: HomeTableViewHeaderDelegate {
    func textDidChange(in searchBar: UISearchBar) {
        viewModel.updateSearchText(searchBar.text ?? "")
        searchDebouncer.debounce { [weak self, weak searchBar] in
            searchBar?.endEditing(true)
            self?.loadCourses()
        }
    }

    func didSelectSubject(at indexPath: IndexPath) {
        viewModel.selectedSubjectIndexPath = indexPath
        guard indexPath.item < viewModel.subjects.count else { return }
        viewModel.selectSubject(viewModel.subjects[indexPath.item])
        loadCourses()
    }

    func didSelectRelatedCourses() {
        viewModel.selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .relatedCourses)
        tableView.reloadData()
        configureFilterButton()
        loadCourses()
    }

    func didSelectExploreMore() {
        viewModel.selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .exploreMore)
        tableView.reloadData()
        configureFilterButton()
        loadCourses()
    }
}

extension HomeViewController: FiltersDelegate {
    func didApplyFilters(_ selection: FilterSelection, courses: CoursesResponse?) {
        self.currentFilterSelection = selection
        configureFiltersButtonWhenFiltersAreSelected()
        viewModel.courses = courses?.teachersCourses ?? []
        viewModel.updateEmptyState()
        tableView.reloadData()
    }
}

extension HomeViewController: ViewCourseDetailsDelegate, SelectCourseCellDelegate {
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
