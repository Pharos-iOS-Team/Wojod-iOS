// Copyright © 2021 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import HandySwift
import JGProgressHUD
import UIKit
import UIScrollView_InfiniteScroll

enum HomeMode {
    case relatedCourses
    case exploreMore
}

class HomeViewController: UIViewController {
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
    @IBOutlet private var tableView: UITableView!

    // MARK: - Private Properties

    private let viewModel = HomeViewModel()
    private var selectedSubjectIndexPath: IndexPath = .zero
    private var mode: HomeMode = .relatedCourses
    private var loadingHud: JGProgressHUD?
    private var isFirstScreenLoad: Bool = true
    private let refreshControl = UIRefreshControl()
    private var blurredView: UIVisualEffectView?
    private var isFiltersSelected: Bool = false
    private var advertisements: [Advertisement] = []
    private var emptyStateDelegator: HomeEmptyStateDelegate!
    private(set) var isLoading: Bool = true
    var isMyCourses: Bool {
        return viewModel.isMyCourses
    }
    var isInSearchMode: Bool {
        return searchText.isValid
    }
    var courses: [SubjectCourses] {
        return viewModel.courses
    }
    private var searchText: String = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfiniteScrolling()
        configureTableView()
        configureRefreshControl()
        observeInternetConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserProfile()
        loadAndConfigureAdvertisements()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.isMyCourses = tabBarController?.selectedIndex == TabBarItems.courses.rawValue
        configureFilterButton()
        viewModel.page = 1
        loadCourses()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in tableView.visibleCells {
            if let courseCell = cell as? CourseTableViewCell {
                courseCell.stopAnyPlayingVideoIfAny()
            }
        }
    }

    // MARK: - IBActions

    @IBAction private func didTapNotificationsButton(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Notifications.initialScene.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        present(viewCtrl, animated: true)
    }

    @IBAction private func didTapHelpCenterButton(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate()
        viewCtrl.chatType = .customerSupport
        viewCtrl.modalPresentationStyle = .fullScreen
        present(viewCtrl, animated: true)
    }

    @IBAction private func didTapFiltersButton(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Filters.initialScene.instantiate()
        viewCtrl.delegate = self
        present(viewCtrl, animated: true)
    }

    @IBAction private func didTapClearFiltersButton(_ sender: UIButton) {
        loadCourses()
        clearPreviouslyChosenFilters()
        configureFiltersButtonWhenNoFilterSelected()
    }

    // MARK: - Private Functions

    private func configureFilterButton() {
        if !isMyCourses && mode == .exploreMore {
            filtersButton.isHidden = false
            filtersButtonHeightConstraint.constant = 50
            filtersButton.setTitle(L10n.Filters.showFilters)
        } else {
            filtersButton.isHidden = true
            filtersButtonHeightConstraint.constant = 0
        }
    }

    private func loadAndConfigureAdvertisements() {
        viewModel.loadAds { ads in
            self.advertisements = ads?.advertisements ?? []
            self.tableView.reloadData()
        }
    }

    private func showReceipt(_ receiptData: Receipt) {
        let view = UINib(nibName: "ReceiptView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ReceiptView
        view?.center = CGPoint(
            x: self.view.frame.size.width / 2,
            y: self.view.frame.size.height / 2
        )
        view?.configureInMyCourses(with: receiptData)
        view?.receiptDoneButtonDelegate = self
        view?.addShadow()
        self.view.addSubview(view ?? UIView())
    }

    private func blurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        self.view.addSubview(blurredView ?? blurEffectView)
    }

    private func configureInfiniteScrolling() {
        if !isFiltersSelected {
            tableView.addInfiniteScroll { [unowned self]  _ in
                self.loadCourses()
            }
        }
    }

    private func hideInfiniteScrolling() {
        tableView.finishInfiniteScroll()
        tableView.reloadData()
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        loadUserProfile()
        loadAndConfigureAdvertisements()
        viewModel.page = 1
        loadCourses()
        tableView.refreshControl?.endRefreshing()
    }

    private func configureTableView() {
        emptyStateDelegator = HomeEmptyStateDelegate(sourceViewCtrl: self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = emptyStateDelegator
        tableView.emptyDataSetDelegate = emptyStateDelegator
        tableView.registerCell(ofType: CourseTableViewCell.self)
        tableView.registerHeaderFooterView(ofType: HomeTableViewHeader.self)
    }

    private func loadUserProfile() {
        viewModel.fetchUserProfile(id: User.shared.id ?? 0)
    }

    @objc
    private func loadCourses() {
        showLoadingIndicator()
        if isInSearchMode {
            viewModel.searchCourses(value: searchText) { [unowned self] in
                hideLoadingIndicator()
                hideInfiniteScrolling()
            }
        } else {
            viewModel.loadCourses(mode: mode) { [unowned self] in
                hideLoadingIndicator()
                hideInfiniteScrolling()
            }
        }
    }

    private func showLoadingIndicator() {
        guard viewModel.page == 1 else { return }
        isLoading = true
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        isLoading = false
        loadingHud?.dismiss()
    }

    private func appropriateSubjectCourse(index: Int) -> SubjectCourses? {
        return viewModel.courses[index]
    }

    private func configureFiltersButtonWhenFiltersAreSelected() {
        isFiltersSelected = true
        clearFiltersButton.isHidden = false
        filtersButton.layer.backgroundColor = Colors.green.color.cgColor
        filtersButton.setTitle(L10n.Filters._4filters)
    }

    private func configureFiltersButtonWhenNoFilterSelected() {
        isFiltersSelected = false
        clearFiltersButton.isHidden = true
        filtersButton.layer.backgroundColor = Colors.sendButtonColor.color.cgColor
        filtersButton.setTitle(L10n.Filters.showFilters)
    }

    private func clearPreviouslyChosenFilters() {
        Filters.shared.academicLevel = nil
        Filters.shared.academicType = nil
        Filters.shared.academicDivision = nil
        Filters.shared.academicYear = nil
        Filters.shared.field = nil
        Filters.shared.subject = nil
    }
}

// MARK: - Table View Data Source

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: CourseTableViewCell.self, for: indexPath)
        let subjectCourse = appropriateSubjectCourse(index: indexPath.row)
        cell?.setTeacherName(subjectCourse?.teacher?.name ?? "")
        cell?.configureCourses(subjectCourse?.courses, isMyCourses: isMyCourses)
        cell?.teacherNameIndex = indexPath.row
        cell?.delegate = self
        cell?.selectCellDelegate = self
        cell?.viewReceiptDelegate = self
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueHeaderFooterView(ofType: HomeTableViewHeader.self)
        headerView?.delegate = self
        headerView?.setSubjects(viewModel.subjects)
        headerView?.selectedSubjectIndexPath = selectedSubjectIndexPath
        headerView?.setAdvertisements(self.advertisements)
        if isFirstScreenLoad {
            isFirstScreenLoad = false
            headerView?.selectRelatedCoursesButton()
        }

        headerView?.setButtonsVisibility(!isInSearchMode)
        headerView?.setSubjectsVisibility(!isInSearchMode && mode == .relatedCourses && !isMyCourses)
        headerView?.setAdvertisementsVisibility(!advertisements.isEmpty && !isMyCourses && !isInSearchMode)
        return headerView
    }
}

// MARK: - Table View Delegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 125
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - View Course Details Delegate

extension HomeViewController: ViewCourseDetailsDelegate, SelectCourseCellDelegate {
    func showCourseDetails(for course: Course?, with teacherNameIndex: Int) {
        showLoadingIndicator()
        let viewCtrl = StoryboardScene.CourseDetails.initialScene.instantiate()
        let subjectCourse = appropriateSubjectCourse(index: teacherNameIndex)
        let teacherName = subjectCourse?.teacher?.name
        viewCtrl.course = course
        viewCtrl.teacherName = teacherName
        viewCtrl.teacherID = subjectCourse?.teacher?.id
        let navigationCtrl = UINavigationController(rootViewController: viewCtrl).with {
            $0.modalPresentationStyle = .fullScreen
            $0.navigationBar.isHidden = true
        }
        let backButton = UIBarButtonItem()
        backButton.title = L10n.Navigation.back
        navigationCtrl.navigationBar.topItem?.backBarButtonItem = backButton
        present(navigationCtrl, animated: true)
        hideLoadingIndicator()
    }
}

// MARK: - Receipt Delegate

extension HomeViewController: ViewReceiptDelegate, ReceiptDoneButtonDelegate {
    func displayReceipt(_ receipt: Receipt) {
        self.blurView()
        self.showReceipt(receipt)
    }

    func didTapDone() {
        blurredView?.removeFromSuperview()
    }
}

extension HomeViewController: HomeTableViewHeaderDelegate {
    func textDidChange(in searchBar: UISearchBar) {
        if !searchBar.text.isValid {
            viewModel.page = 1
        }

        self.searchText = searchBar.text ?? ""
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchCourses(_:)), with: searchBar, afterDelay: 0.75)
    }

    @objc
    private func searchCourses(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        loadCourses()
    }

    func didSelectSubject(at indexPath: IndexPath) {
        selectedSubjectIndexPath = indexPath
        viewModel.courses.removeAll()
        viewModel.page = 1
        viewModel.selectedSubject = viewModel.subjects[indexPath.item]
        loadCourses()
    }

    func didSelectRelatedCourses() {
        mode = .relatedCourses
        viewModel.courses.removeAll()
        tableView.reloadData()
        viewModel.page = 1
        configureFilterButton()
        loadCourses()
    }

    func didSelectExploreMore() {
        mode = .exploreMore
        viewModel.courses.removeAll()
        tableView.reloadData()
        viewModel.page = 1
        configureFilterButton()
        loadCourses()
    }
}

// MARK: - Filters Delegate
extension HomeViewController: FiltersDelegate {
    func loadFilteredCourses(_ courses: CoursesResponse?) {
        configureFiltersButtonWhenFiltersAreSelected()
        viewModel.courses = courses?.teachersCourses ?? []
        tableView.reloadData()
    }
}
