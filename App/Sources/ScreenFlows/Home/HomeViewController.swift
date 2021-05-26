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

    @IBOutlet private var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    @IBOutlet private var relatedCoursesButton: UIButton! {
        didSet {
            relatedCoursesButton.layer.cornerRadius = UIConstants.slightCornerRadius
            relatedCoursesButton.setTitle(L10n.Home.relatedCourses)
        }
    }
    @IBOutlet private var exploreMoreButton: UIButton! {
        didSet {
            exploreMoreButton.layer.cornerRadius = UIConstants.slightCornerRadius
            exploreMoreButton.setTitle(L10n.Home.exploreMore)
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
    @IBOutlet private var subjectsCollectionView: UICollectionView!
    @IBOutlet private var adsCollectionView: UICollectionView!
    @IBOutlet private var coursesTableView: UITableView!
    @IBOutlet private var subjectsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var adsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var searchBar: UISearchBar!

    // MARK: - Private Properties

    private let viewModel = HomeViewModel()
    private var subjects: [Subject]?
    private var selectedSubjectIndexPath: IndexPath?
    private var selectedSubject: Subject?
    private var subjectRelatedCourses: [SubjectCourses]?
    private var exploreMoreCourses: [SubjectCourses]?
    private var searchResultsCourses: [SubjectCourses]?
    private var mode: HomeMode = .relatedCourses
    private var isInSearchMode: Bool = false
    private var loadingHud: JGProgressHUD?
    private var selectedTabBarItem: TabBarItems?
    private var isMyCourses: Bool = false
    private var isFirstScreenLoad: Bool = true
    private let refreshControl = UIRefreshControl()
    private var blurredView: UIVisualEffectView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfiniteScrolling()
        configureCollectionViews()
        configureTableView()
        configureRefreshControl()
        configureSearchBar()
        loadUserProfile()
        selectRelatedCoursesButton()
        fetchRelatedCourses()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isMyCourses = tabBarController?.selectedIndex == TabBarItems.courses.rawValue
        hideAdsCollectionViewIfNeeded()
    }

    // MARK: - IBActions

    @IBAction private func didTapRelatedCourses(_ sender: UIButton) {
        mode = .relatedCourses
        viewModel.exploreMorePage = 1
        selectRelatedCoursesButton()
        configureVisibilityOfSubjectsAndAds()
    }

    @IBAction private func didTapExploreMore(_ sender: UIButton) {
        mode = .exploreMore
        viewModel.relatedCoursesPage = 1
        selectExploreMoreButton()
        configureVisibilityOfSubjectsAndAds()
        loadExploreMoreCourses()
    }

    @IBAction private func didTapNotificationsButton(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Notifications.initialScene.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        present(viewCtrl, animated: true)
    }

    // MARK: - Private Functions

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
        coursesTableView.addInfiniteScroll { [weak self] _ in
            if self?.mode == .relatedCourses {
                self?.loadRelatedCourses()
            } else {
                self?.loadExploreMoreCourses()
            }
        }
    }

    private func hideInfiniteScrolling() {
        coursesTableView.finishInfiniteScroll()
        self.coursesTableView.reloadData()
    }

    private func configureRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        coursesTableView.addSubview(refreshControl)
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        coursesTableView.reloadData()
    }

    private func configureCollectionViews() {
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        adsCollectionView.dataSource = self
        adsCollectionView.delegate = self
    }

    private func configureTableView() {
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        coursesTableView.registerCell(ofType: CourseTableViewCell.self)
    }

    private func configureSearchBar() {
        searchBar.delegate = self
    }

    private func selectRelatedCoursesButton() {
        relatedCoursesButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        relatedCoursesButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        exploreMoreButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        exploreMoreButton.setTitleColor(UIColor.black, for: .normal)
    }

    private func selectExploreMoreButton() {
        relatedCoursesButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        relatedCoursesButton.setTitleColor(UIColor.black, for: .normal)
        exploreMoreButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        exploreMoreButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
    }

    private func loadUserProfile() {
        viewModel.fetchUserProfile(id: User.shared.id ?? 0) {
            self.loadSubjects()
        }
    }

    private func loadSubjects() {
        guard let batchID = User.shared.batch else { return }
        viewModel.loadSubjects(batchID: batchID) { subjectsList in
            self.subjects = subjectsList?.subjects
            self.subjectsCollectionView.reloadData()
        }
    }

    private func fetchRelatedCourses() {
        showLoadingIndicator()
        loadRelatedCourses()
    }

    private func loadRelatedCourses() {
        viewModel.loadRelatedCourses(isMyCourses: isMyCourses, subjectID: selectedSubject?.id ?? 0) { [unowned self] relatedCourses in
            hideLoadingIndicator()
            subjectRelatedCourses = relatedCourses?.teachersCourses[selectedSubject?.name ?? ""]
            hideInfiniteScrolling()
        }
    }

    private func loadExploreMoreCourses() {
        showLoadingIndicator()
        viewModel.loadExploreMoreCourses(isMyCourses: isMyCourses) { [unowned self] courses in
            hideLoadingIndicator()
            exploreMoreCourses = courses?.teachersCourses
            coursesTableView.reloadData()
        }
    }

    private func configureVisibilityOfSubjectsAndAds() {
        subjectsCollectionView.isHidden = mode == .exploreMore
        adsCollectionView.isHidden = mode == .exploreMore
        subjectsCollectionViewHeightConstraint.constant = mode == .exploreMore ? 0 : 50
        adsCollectionViewHeightConstraint.constant = mode == .exploreMore ? 0 : 150
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
            return isInSearchMode ? searchResultsCourses?[index] : subjectRelatedCourses?[index]
        case .exploreMore:
            return isInSearchMode ? searchResultsCourses?[index] : exploreMoreCourses?[index]
        }
    }

    private func hideAdsCollectionViewIfNeeded() {
        adsCollectionView.isHidden = isMyCourses
        adsCollectionViewHeightConstraint.constant = isMyCourses ? 0 : 150
    }
}

// MARK: - Collection View Data Source

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == subjectsCollectionView ? self.subjects?.count ?? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subjectsCollectionView {
            let subjectCell: SubjectCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
            let subject = subjects?[indexPath.row]
            subjectCell.setSubject(subject?.name ?? "")
            if isFirstScreenLoad {
                isFirstScreenLoad = false
                selectedSubjectIndexPath = indexPath
                selectedSubject = subjects?[indexPath.item]
                loadRelatedCourses()
                subjectCell.select()
            }
            return subjectCell
        } else {
            let adsCell: AdsCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
            return adsCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == subjectsCollectionView {
            if let selectedSubjectCell = collectionView.cellForItem(at: selectedSubjectIndexPath ?? indexPath) as? SubjectCollectionViewCell {
                selectedSubjectCell.unselect()
            }
            if let subjectCell = collectionView.cellForItem(at: indexPath) as? SubjectCollectionViewCell {
                selectedSubjectIndexPath = indexPath
                selectedSubject = subjects?[indexPath.item]
                loadRelatedCourses()
                subjectCell.select()
            }
        }
    }
}

// MARK: - Collection View Delegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard collectionView == subjectsCollectionView else { return 0 }
        return 5.0
    }
}

// MARK: - Table View Data Source

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .relatedCourses:
            return isInSearchMode ? searchResultsCourses?.count ?? 0: subjectRelatedCourses?.count ?? 0
        case .exploreMore:
            return isInSearchMode ? searchResultsCourses?.count ?? 0 : exploreMoreCourses?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: CourseTableViewCell.self, for: indexPath)
        let subjectCourse = appropriateSubjectCourse(index: indexPath.row)
        cell?.setTeacherName(subjectCourse?.teacher?.name ?? "")
        cell?.configureCourses(subjectCourse?.courses, isMyCourses: isMyCourses)
        cell?.delegate = self
        cell?.selectCellDelegate = self
        cell?.viewReceiptDelegate = self
        return cell ?? UITableViewCell()
    }
}

// MARK: - Table View Delegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
}

// MARK: - Search Bar Delegate

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isInSearchMode = true
        showLoadingIndicator()
        viewModel.searchCourses(value: searchBar.text ?? "") { resultCourses in
            self.hideLoadingIndicator()
            self.searchResultsCourses = resultCourses?.teachersCourses
            self.coursesTableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty ?? false {
            isInSearchMode = false
            coursesTableView.reloadData()
        }
    }
}

// MARK: - View Course Details Delegate

extension HomeViewController: ViewCourseDetailsDelegate, SelectCourseCellDelegate {
    func showCourseDetails(for course: Course?) {
        let viewCtrl = StoryboardScene.CourseDetails.initialScene.instantiate()
        viewCtrl.course = course
        present(viewCtrl, animated: true)
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

    // TODO: delete this part
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewCtrl = StoryboardScene.CourseDetails.initialScene.instantiate()
        self.present(viewCtrl, animated: true)
    }
}
