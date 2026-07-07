// Copyright © 2026 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import UIKit
import UIScrollView_InfiniteScroll

final class CourseListTableController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private weak var tableView: UITableView?
    private weak var viewModel: CourseListViewModeling?
    private let isMyCourses: Bool
    private let headerProvider: () -> UIView?
    private let courseDetailsDelegate: ViewCourseDetailsDelegate?
    private let selectCellDelegate: SelectCourseCellDelegate?
    private let receiptDelegate: ViewReceiptDelegate?
    private let emptyStateDelegator: CoursesEmptyStateDelegate

    init(
        tableView: UITableView,
        viewModel: CourseListViewModeling,
        isMyCourses: Bool,
        headerProvider: @escaping () -> UIView?,
        courseDetailsDelegate: ViewCourseDetailsDelegate?,
        selectCellDelegate: SelectCourseCellDelegate?,
        receiptDelegate: ViewReceiptDelegate?,
        navigationCoordinator: CoursesNavigationCoordinating
    ) {
        self.tableView = tableView
        self.viewModel = viewModel
        self.isMyCourses = isMyCourses
        self.headerProvider = headerProvider
        self.courseDetailsDelegate = courseDetailsDelegate
        self.selectCellDelegate = selectCellDelegate
        self.receiptDelegate = receiptDelegate
        self.emptyStateDelegator = CoursesEmptyStateDelegate(
            viewModel: viewModel,
            navigationCoordinator: navigationCoordinator
        )
        super.init()

        configureTableView()
    }

    private func configureTableView() {
        guard let tableView = tableView else { return }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(ofType: CourseTableViewCell.self)
        tableView.registerHeaderFooterView(ofType: HomeTableViewHeader.self)
        tableView.emptyDataSetSource = emptyStateDelegator
        tableView.emptyDataSetDelegate = emptyStateDelegator
    }

    func configureRefreshControl(_ refreshControl: UIRefreshControl) {
        guard let tableView = tableView else { return }
        tableView.refreshControl = refreshControl
    }

    func configureInfiniteScrolling(loadMoreHandler: @escaping () -> Void) {
        guard let tableView = tableView else { return }
        tableView.addInfiniteScroll { [weak self] _ in
            loadMoreHandler()
        }
    }

    func finishInfiniteScroll() {
        tableView?.finishInfiniteScroll()
        tableView?.refreshControl?.endRefreshing()
        tableView?.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.courses.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: CourseTableViewCell.self, for: indexPath)
        guard let viewModel = viewModel else { return cell ?? UITableViewCell() }

        let subjectCourse = appropriateSubjectCourse(index: indexPath.row)

        cell?.configure(
            courses: subjectCourse?.courses,
            isMyCourses: isMyCourses,
            teacherName: subjectCourse?.teacher?.name,
            teacherNameIndex: indexPath.row,
            courseDetailsDelegate: courseDetailsDelegate,
            selectCellDelegate: selectCellDelegate,
            viewReceiptDelegate: receiptDelegate
        )

        return cell ?? UITableViewCell()
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerProvider()
    }

    // MARK: - Helpers

    private func appropriateSubjectCourse(index: Int) -> SubjectCourses? {
        guard let viewModel = viewModel, index < viewModel.courses.count else { return nil }
        return viewModel.courses[index]
    }
}
