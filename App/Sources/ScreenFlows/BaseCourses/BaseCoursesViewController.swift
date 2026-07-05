// Copyright © 2026 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import HandyUIKit
import JGProgressHUD
import UIKit
import UIScrollView_InfiniteScroll

class BaseCoursesViewController<ViewModel: BaseCoursesViewModel>: UIViewController, UITableViewDelegate {
    // MARK: - Outlets
    // swiftlint:disable:next private_outlet
    @IBOutlet private(set) var tableView: UITableView!

    // MARK: - Properties
    var viewModel: ViewModel!
    var navigationCoordinator: CoursesNavigationCoordinating = CoursesNavigationCoordinator()
    private(set) var loadingHud: JGProgressHUD?
    private(set) var isLoading: Bool = false
    let refreshControl = UIRefreshControl()
    private var emptyStateDelegator: CoursesEmptyStateDelegate!

    var courses: [SubjectCourses] {
        return viewModel.courses
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureRefreshControl()
        configureInfiniteScrolling()
        observeInternetConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllPlayingVideos()
        hideLoadingIndicator()
    }

    func configureTableView() {
        emptyStateDelegator = CoursesEmptyStateDelegate(viewModel: viewModel, navigationCoordinator: navigationCoordinator)
        tableView.delegate = self
        tableView.emptyDataSetSource = emptyStateDelegator
        tableView.emptyDataSetDelegate = emptyStateDelegator
        tableView.registerCell(ofType: CourseTableViewCell.self)
    }

    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func configureInfiniteScrolling() {
        tableView.addInfiniteScroll { [weak self] _ in
            self?.loadCourses()
        }
    }

    @objc
    func refresh(_ sender: AnyObject) {
        loadUserProfile()
        viewModel.page = 1
        loadCourses()
    }

    func loadUserProfile(completion: (() -> Void)? = nil) {
        viewModel.fetchUserProfile(completion: completion)
    }

    func loadCourses() {
        guard !isLoading else { return }
        isLoading = true
        if viewModel.page == 1 {
            showLoadingIndicator()
        }
        viewModel.loadCourses { [weak self] in
            self?.hideLoadingIndicator()
            self?.hideInfiniteScrolling()
        }
    }

    func showLoadingIndicator() {
        guard loadingHud == nil else { return }
        loadingHud = JGProgressHUD(style: .light).with {
            $0.interactionType = .blockNoTouches
            $0.textLabel.text = L10n.Global.Alerts.loading
            $0.hudView.backgroundColor = .white
            $0.show(in: self.view, animated: true)
        }
    }

    func hideLoadingIndicator() {
        isLoading = false
        loadingHud?.dismiss()
        loadingHud = nil
    }

    func forceReloadCourses() {
        isLoading = false
        loadCourses()
    }

    func hideInfiniteScrolling() {
        tableView.finishInfiniteScroll()
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    private func stopAllPlayingVideos() {
        for cell in tableView.visibleCells {
            if let courseCell = cell as? CourseTableViewCell {
                courseCell.stopAnyPlayingVideoIfAny()
            }
        }
    }

    func appropriateSubjectCourse(index: Int) -> SubjectCourses? {
        guard index < viewModel.courses.count else { return nil }
        return viewModel.courses[index]
    }

    func tableViewHeader() -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewHeader()
    }

    // MARK: - UITableViewDelegate
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

extension BaseCoursesViewController: ViewCourseDetailsDelegate, SelectCourseCellDelegate {
    func showCourseDetails(for course: Course?, with teacherNameIndex: Int) {
        let subjectCourse = appropriateSubjectCourse(index: teacherNameIndex)
        let teacherName = subjectCourse?.teacher?.name
        let teacherID = subjectCourse?.teacher?.id
        navigationCoordinator.showCourseDetails(
            course: course,
            teacherName: teacherName,
            teacherID: teacherID,
            from: self
        )
    }
}
