// Copyright © 2026 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import UIKit

protocol CourseDetailsTableViewManagerHost: AnyObject {
    var viewModel: CourseDetailsViewModel! { get }
    var courseHeaderView: CourseDetailsInfoHeaderView? { get }
}

final class CourseDetailsTableViewManager: NSObject {
    enum Constants {
        static let detailsRowHeight: CGFloat = 50
        static let reviewsRowHeight: CGFloat = 90
        static let headerHeight: CGFloat = 60
        static let footerHeight: CGFloat = 5.0
    }
    // MARK: - Properties

    weak var host: CourseDetailsTableViewManagerHost?
    private weak var tableView: UITableView?
    private let viewModel: CourseDetailsViewModel
    private lazy var dataSource = CourseDetailsDataSource(viewModel: viewModel)
    private lazy var emptyStateDelegate = CourseDetailsEmptyStateDelegate(viewModel: viewModel)

    // MARK: - Init

    init(viewModel: CourseDetailsViewModel, host: CourseDetailsTableViewManagerHost) {
        self.viewModel = viewModel
        self.host = host
        super.init()
    }

    // MARK: - Setup

    func setup(in tableView: UITableView) {
        self.tableView = tableView
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.registerCell(ofType: AttachmentTableViewCell.self)
        tableView.registerCell(ofType: ReviewTableViewCell.self)
        tableView.registerCell(ofType: MaterialTableViewCell.self)
        tableView.registerHeaderFooterView(ofType: CourseDetailsHeaderView.self)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.emptyDataSetSource = emptyStateDelegate
        tableView.emptyDataSetDelegate = emptyStateDelegate
    }
}

// MARK: - UITableViewDelegate

extension CourseDetailsTableViewManager: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        host?.courseHeaderView?.applyStretchEffect(offset: scrollView.contentOffset.y + scrollView.contentInset.top)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.state.activeScreen == .details ? (Constants.detailsRowHeight) : (Constants.reviewsRowHeight)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.state.activeScreen {
        case .details:
            return Constants.detailsRowHeight
        case .materials:
            return Constants.reviewsRowHeight
        case .reviews:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            viewModel.state.activeScreen == .details,
            !viewModel.state.lessonsList.isEmpty,
            !viewModel.state.isContentLoading
        else { return nil }

        let view = tableView.dequeueHeaderFooterView(ofType: CourseDetailsHeaderView.self)
        view?.configure(viewModel.lessonHeaderModel(for: section)) { [weak self] section in
            self?.handleCollapseExpand(section: section, in: tableView)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (viewModel.state.activeScreen == .details && !viewModel.state.isContentLoading) ? Constants.headerHeight : 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        (viewModel.state.activeScreen == .details && !viewModel.state.isContentLoading) ? Constants.headerHeight : 0.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.state.activeScreen == .details ? Constants.footerHeight : 0.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }

    private func handleCollapseExpand(section: Int, in tableView: UITableView) {
        let wasExpanded = viewModel.state.expandedSections.contains(section)
        let oldRowCount = viewModel.numberOfRowsForLesson(section: section)
        viewModel.toggleSectionExpansion(section) { [weak self] in
            guard let self else { return }
            if wasExpanded {
                let indexPaths = (0 ..< oldRowCount).map { IndexPath(row: $0, section: section) }
                tableView.performBatchUpdates { tableView.deleteRows(at: indexPaths, with: .fade) }
            } else {
                let newRowCount = self.viewModel.numberOfRowsForLesson(section: section)
                let indexPaths = (0 ..< newRowCount).map { IndexPath(row: $0, section: section) }
                tableView.performBatchUpdates { tableView.insertRows(at: indexPaths, with: .automatic) }
            }
            if let header = tableView.headerView(forSection: section) as? CourseDetailsHeaderView {
                header.animateExpandCollapse(isExpanded: !wasExpanded)
            }
        }
    }
}
