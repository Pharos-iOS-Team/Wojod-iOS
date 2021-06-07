// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import JGProgressHUD
import UIKit

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
        }
    }
    @IBOutlet private var exploreMoreButton: UIButton! {
        didSet {
            exploreMoreButton.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
    @IBOutlet private var helpCenterButton: UIButton! {
        didSet {
            helpCenterButton.layer.cornerRadius = UIConstants.slightCornerRadius
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViews()
        configureTableView()
        configureSearchBar()
        loadUserProfile()
        selectRelatedCoursesButton()
    }

    // MARK: - IBActions

    @IBAction private func didTapRelatedCourses(_ sender: UIButton) {
        mode = .relatedCourses
        selectRelatedCoursesButton()
        configureVisibilityOfSubjectsAndAds()
    }

    @IBAction private func didTapExploreMore(_ sender: UIButton) {
        mode = .exploreMore
        selectExploreMoreButton()
        configureVisibilityOfSubjectsAndAds()
        loadExploreMoreCourses()
    }

    // MARK: - Private Functions

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

    private func loadRelatedCourses() {
        showLoadingIndicator()
        viewModel.loadRelatedCourses(isMyCourses: false, subjectID: selectedSubject?.id ?? 0) { [unowned self] relatedCourses in
            hideLoadingIndicator()
            subjectRelatedCourses = relatedCourses?.teachersCourses[selectedSubject?.name ?? ""]
            coursesTableView.reloadData()
        }
    }

    private func loadExploreMoreCourses() {
        showLoadingIndicator()
        viewModel.loadExploreMoreCourses(isMyCourses: false) { [unowned self] courses in
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
        cell?.configureCourses(subjectCourse?.courses)
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
