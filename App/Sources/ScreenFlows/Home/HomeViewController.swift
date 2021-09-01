// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import JGProgressHUD
import UIKit
import UIScrollView_InfiniteScroll

enum HomeMode {
    case relatedCourses
    case exploreMore
}

class HomeViewController: UIViewController {
    // MARK: - IBOutlets

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
    @IBOutlet private var filterSelectedLabel: UILabel! {
        didSet {
            filterSelectedLabel.isHidden = true
        }
    }
    @IBOutlet private var clearLabel: UILabel! {
        didSet {
            clearLabel.isHidden = true
        }
    }
    @IBOutlet private var filtersButton: UIButton!
    @IBOutlet private var filtersButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var coursesTableView: UITableView!

    // MARK: - Private Properties

    private let viewModel = HomeViewModel()
    private var subjects: [Subject]?
    private var selectedSubject: Subject?
    private var selectedSubjectIndexPath: IndexPath?
    private var subjectRelatedCourses: [SubjectCourses] = []
    private var exploreMoreCourses: [SubjectCourses] = []
    private var searchResultsCourses: [SubjectCourses]?
    private var filteredResultsCourses: [SubjectCourses] = []
    private var mode: HomeMode = .relatedCourses
    private var isInSearchMode = false
    private var loadingHud: JGProgressHUD?
    private var selectedTabBarItem: TabBarItems?
    private var isMyCourses = false
    private var isFirstScreenLoad = true
    private let refreshControl = UIRefreshControl()
    private var blurredView: UIVisualEffectView?
    private var isFiltersSelected: Bool = false
    private var advertisements: [Advertisement]?
    private var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfiniteScrolling()
        configureTableView()
        configureRefreshControl()
        loadUserProfile()
        preventScreenshot()
        preventScreenRecording()
        loadAndConfigureAdvertisements()
        observeInternetConnection()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isMyCourses = tabBarController?.selectedIndex == TabBarItems.courses.rawValue
        configureFilterButton()
        loadRelatedCourses(isBeingScrolled: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in coursesTableView.visibleCells {
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
        if isFiltersSelected {
            loadExploreMoreCourses(isBeingScrolled: false)
            configureFiltersButtonWhenNoFilterSelected()
        } else {
            let viewCtrl = StoryboardScene.Filters.initialScene.instantiate()
            viewCtrl.delegate = self
            present(viewCtrl, animated: true)
        }
    }

    // MARK: - Private Functions

    private func preventScreenRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideScreenIfBeingRecorded), name: UIScreen.capturedDidChangeNotification, object: nil)
    }

    @objc
    private func hideScreenIfBeingRecorded() {
        window?.isHidden = UIScreen.main.isCaptured
    }

    private func configureFilterButton() {
        if !isMyCourses && mode == .exploreMore {
            filtersButton.isHidden = false
            filtersButtonHeightConstraint.constant = 50
        } else {
            filtersButton.isHidden = true
            filtersButtonHeightConstraint.constant = 0
        }
    }

    private func loadAndConfigureAdvertisements() {
        viewModel.loadAds { ads in
            self.advertisements = ads?.advertisements
        }
    }

    private func showReceipt(_ receiptData: Receipt) {
        let view = UINib(nibName: "ReceiptView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ReceiptView
        view?.center = CGPoint(
            x: self.view.frame.size.width / 2,
            y: self.view.frame.size.height / 2
        )
        view?.configureInMyCourses(with: receiptData, coursePrice: "")
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
            coursesTableView.addInfiniteScroll { [unowned self]  _ in
                if self.mode == .relatedCourses {
                    self.loadRelatedCourses(isBeingScrolled: true)
                } else {
                    self.loadExploreMoreCourses(isBeingScrolled: true)
                }
            }
        }
    }

    private func hideInfiniteScrolling() {
        coursesTableView.finishInfiniteScroll()
        self.coursesTableView.reloadData()
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        coursesTableView.refreshControl = refreshControl
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        if self.mode == .relatedCourses {
            self.viewModel.relatedCoursesPage = 1
            self.loadRelatedCourses(isBeingScrolled: false)
            self.coursesTableView.refreshControl?.endRefreshing()
        } else {
            self.viewModel.exploreMorePage = 1
            self.loadExploreMoreCourses(isBeingScrolled: false)
            self.coursesTableView.refreshControl?.endRefreshing()
        }
    }

    private func configureTableView() {
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        coursesTableView.registerCell(ofType: CourseTableViewCell.self)
        coursesTableView.registerHeaderFooterView(ofType: HomeTableViewHeader.self)
    }

    private func loadUserProfile() {
        viewModel.fetchUserProfile(id: User.shared.id ?? 0)
    }

    private func loadRelatedCourses(isBeingScrolled: Bool) {
        showLoadingIndicator()
        viewModel.loadRelatedCourses(
            isBeingScrolled: isBeingScrolled,
            isMyCourses: isMyCourses,
            subjectID: selectedSubject?.id
        ) { [unowned self] relatedCourses in
            hideLoadingIndicator()
            subjects = relatedCourses?.subjects
            let defaultSubjectName = subjects?.first?.name ?? ""
            if !isBeingScrolled {
                subjectRelatedCourses.removeAll()
            }
            if let subjectCourses = relatedCourses?.teachersCourses[selectedSubject?.name ?? defaultSubjectName] {
                subjectRelatedCourses.append(contentsOf: subjectCourses)
            }
            hideInfiniteScrolling()
        }
    }

    private func loadExploreMoreCourses(isBeingScrolled: Bool) {
        showLoadingIndicator()
        viewModel.loadExploreMoreCourses(isBeingScrolled: isBeingScrolled, isMyCourses: isMyCourses) { [unowned self] courses in
            hideLoadingIndicator()
            if !isBeingScrolled {
                exploreMoreCourses.removeAll()
            }
            if let exploreCourses = courses?.teachersCourses {
                exploreMoreCourses.append(contentsOf: exploreCourses)
            }
            coursesTableView.reloadData()
            hideInfiniteScrolling()
        }
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    private func appropriateSubjectCourse(index: Int) -> SubjectCourses? {
        switch mode {
        case .relatedCourses:
            return isInSearchMode ? searchResultsCourses?[index] : subjectRelatedCourses[index]
        case .exploreMore:
            if isFiltersSelected && !isMyCourses {
                return filteredResultsCourses[index]
            } else {
                return isInSearchMode ? searchResultsCourses?[index] : exploreMoreCourses[index]
            }
        }
    }

    private func configureFiltersButtonWhenFiltersAreSelected() {
        isFiltersSelected = true
        filtersButton.layer.backgroundColor = Colors.green.color.cgColor
        filtersButton.setTitle("")
        filterSelectedLabel.isHidden = false
        clearLabel.isHidden = false
    }

    private func configureFiltersButtonWhenNoFilterSelected() {
        isFiltersSelected = false
        filtersButton.layer.backgroundColor = Colors.sendButtonColor.color.cgColor
        filtersButton.setTitle("Show Filters")
        filterSelectedLabel.isHidden = true
        clearLabel.isHidden = true
    }

    private func displayEmptyStateForSearch() {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: emptyView.bounds.size.width, height: emptyView.bounds.size.height))
        emptyLabel.text = L10n.Home.noResults
        emptyLabel.textColor = Colors.sendButtonColor.color
        emptyLabel.textAlignment = .center
        emptyView.center = coursesTableView.center
        emptyView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        emptyView.addSubview(emptyLabel)
        coursesTableView.backgroundView = emptyView
        coursesTableView.separatorStyle = .none
    }
}

// MARK: - Table View Data Source

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .relatedCourses:
            if isInSearchMode {
                if searchResultsCourses?.isEmpty ?? true {
                    displayEmptyStateForSearch()
                }
            }
            return isInSearchMode ? searchResultsCourses?.count ?? 0: subjectRelatedCourses.count
        case .exploreMore:
            if isFiltersSelected && !isMyCourses {
                return filteredResultsCourses.count
            } else {
                if isInSearchMode {
                    if searchResultsCourses?.isEmpty ?? true {
                        displayEmptyStateForSearch()
                    }
                }
                return isInSearchMode ? searchResultsCourses?.count ?? 0 : exploreMoreCourses.count
            }
        }
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
        headerView?.configureCollectionViews()
        headerView?.configureSearchBar()
        headerView?.setSubjects(self.subjects)
        headerView?.selectedSubjectIndexPath = selectedSubjectIndexPath
        headerView?.setAdvertisements(self.advertisements)
        if isFirstScreenLoad && self.subjects != nil {
            isFirstScreenLoad = false
            headerView?.selectRelatedCoursesButton()
        }
        return headerView
    }
}

// MARK: - Table View Delegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return mode == .exploreMore ? 150 : 380
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
        let navigationCtrl = UINavigationController(rootViewController: viewCtrl)
        navigationCtrl.modalPresentationStyle = .fullScreen
        navigationCtrl.navigationBar.isHidden = true
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
        if searchBar.text?.isEmpty ?? false {
            isInSearchMode = false
            coursesTableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        isInSearchMode = true
        showLoadingIndicator()
        viewModel.searchCourses(value: searchBar.text ?? "") { resultCourses in
            self.hideLoadingIndicator()
            self.searchResultsCourses = resultCourses?.teachersCourses
            self.coursesTableView.reloadData()
        }
    }

    func didSelectSubject(in collectionView: UICollectionView, at indexPath: IndexPath) {
        if let subjectCell = collectionView.cellForItem(at: indexPath) as? SubjectCollectionViewCell {
            subjectCell.isSelected = true
        }
        selectedSubjectIndexPath = indexPath
        subjectRelatedCourses.removeAll()
        viewModel.relatedCoursesPage = 1
        selectedSubject = subjects?[indexPath.item]
        loadRelatedCourses(isBeingScrolled: false)
    }

    func didSelectRelatedCourses() {
        mode = .relatedCourses
        subjectRelatedCourses.removeAll()
        coursesTableView.reloadData()
        viewModel.exploreMorePage = 1
        configureFilterButton()
        loadRelatedCourses(isBeingScrolled: false)
    }

    func didSelectExploreMore() {
        mode = .exploreMore
        exploreMoreCourses.removeAll()
        coursesTableView.reloadData()
        viewModel.relatedCoursesPage = 1
        configureFilterButton()
        loadExploreMoreCourses(isBeingScrolled: false)
    }
}

// MARK: - Filters Delegate
extension HomeViewController: FiltersDelegate {
    func loadFilteredCourses(_ courses: ExploreMoreCoursesResponse?) {
        configureFiltersButtonWhenFiltersAreSelected()
        filteredResultsCourses = courses?.teachersCourses ?? []
        self.coursesTableView.reloadData()
    }
}
