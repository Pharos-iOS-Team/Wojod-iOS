// Copyright © 2026 Pharos Solutions. All rights reserved.

import HandySwift
import SwiftyUserDefaults
import UIKit

final class HomeViewController: BaseCoursesViewController<HomeViewModel>, UITableViewDataSource {
    @IBOutlet private var notifiationButton: UIButton! {
        didSet {
            notifiationButton.isHidden = Defaults[\.isGuestModeEnabled]
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

    private var selectedSubjectIndexPath: IndexPath = .zero
    private var mode: HomeMode = .relatedCourses
    private var isFirstScreenLoad: Bool = true
    private var isFiltersSelected: Bool = false
    private var currentFilterSelection = FilterSelection()

    convenience init(viewModel: HomeViewModel) {
        self.init(nibName: "BaseCoursesViewController", bundle: nil)
        self.viewModel = viewModel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoadingIndicator()
        loadAndConfigureAdvertisements()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureFilterButton()
        viewModel.page = 1
        loadUserProfile { [weak self] in
            self?.loadCourses()
        }
    }

    override func configureTableView() {
        super.configureTableView()
        tableView.dataSource = self
        tableView.registerHeaderFooterView(ofType: HomeTableViewHeader.self)
    }

    override func configureInfiniteScrolling() {
        if !isFiltersSelected {
            super.configureInfiniteScrolling()
        }
    }

    override func refresh(_ sender: AnyObject) {
        super.refresh(sender)
        loadAndConfigureAdvertisements()
    }

    override func tableViewHeader() -> UIView? {
        let headerView = tableView.dequeueHeaderFooterView(ofType: HomeTableViewHeader.self)
        headerView?.delegate = self
        headerView?.setSubjects(viewModel.subjects)
        headerView?.selectedSubjectIndexPath = selectedSubjectIndexPath
        headerView?.setAdvertisements(viewModel.advertisements)

        if isFirstScreenLoad {
            isFirstScreenLoad = false
            headerView?.selectRelatedCoursesButton()
        }

        headerView?.setButtonsVisibility(!viewModel.isInSearchMode)
        headerView?.setSubjectsVisibility(!viewModel.isInSearchMode && mode == .relatedCourses)
        headerView?.setAdvertisementsVisibility(!viewModel.advertisements.isEmpty && !viewModel.isInSearchMode)
        return headerView
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
        viewModel.page = 1
        forceReloadCourses()
    }

    private func configureFilterButton() {
        if mode == .exploreMore {
            filtersButton.isHidden = false
            filtersButtonHeightConstraint.constant = 50
            filtersButton.setTitle(L10n.Filters.showFilters)
        } else {
            filtersButton.isHidden = true
            filtersButtonHeightConstraint.constant = 0
        }
    }

    private func loadAndConfigureAdvertisements() {
        viewModel.loadAdvertisements { [weak self] _ in
            self?.tableView.reloadData()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: CourseTableViewCell.self, for: indexPath)
        let subjectCourse = appropriateSubjectCourse(index: indexPath.row)

        cell?.configure(
            courses: subjectCourse?.courses,
            isMyCourses: false,
            teacherName: subjectCourse?.teacher?.name,
            teacherNameIndex: indexPath.row,
            courseDetailsDelegate: self,
            selectCellDelegate: self
        )

        return cell ?? UITableViewCell()
    }
}

extension HomeViewController: HomeTableViewHeaderDelegate {
    func textDidChange(in searchBar: UISearchBar) {
        viewModel.updateSearchText(searchBar.text ?? "")
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
        viewModel.selectSubject(viewModel.subjects[indexPath.item])
        loadCourses()
    }

    func didSelectRelatedCourses() {
        mode = .relatedCourses
        selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .relatedCourses)
        tableView.reloadData()
        configureFilterButton()
        forceReloadCourses()
    }

    func didSelectExploreMore() {
        mode = .exploreMore
        selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .exploreMore)
        tableView.reloadData()
        configureFilterButton()
        forceReloadCourses()
    }
}

extension HomeViewController: FiltersDelegate {
    func didApplyFilters(_ selection: FilterSelection, courses: CoursesResponse?) {
        self.currentFilterSelection = selection
        configureFiltersButtonWhenFiltersAreSelected()
        viewModel.courses = courses?.teachersCourses ?? []
        tableView.reloadData()
    }
}
