// Copyright © 2026 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import UIKit

protocol CourseDetailsTableViewManagerHost: AnyObject {
    var viewModel: CourseDetailsViewModel! { get }
    var courseHeaderView: CourseDetailsInfoHeaderView? { get }
    var isContentLoading: Bool { get }
    var detailsRowHeight: CGFloat { get }
    var reviewsRowHeight: CGFloat { get }
    var activeSubscreen: CourseDetailsActiveSubScreen { get set }
    func handleMaterialsSelection(at indexPath: IndexPath)
    func handleDetailsSelection(at indexPath: IndexPath)
}

final class CourseDetailsTableViewManager: NSObject {
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
        viewModel.activeScreen == .details ? (host?.detailsRowHeight ?? 50) : (host?.reviewsRowHeight ?? 90)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.activeScreen {
        case .details:
            return host?.detailsRowHeight ?? 50
        case .materials:
            return host?.reviewsRowHeight ?? 90
        case .reviews:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard viewModel.activeScreen == .details,
              !viewModel.lessonsList.isEmpty,
              !(host?.isContentLoading ?? false) else { return nil }
        let lesson = viewModel.lessonsList[section]
        let view = tableView.dequeueHeaderFooterView(ofType: CourseDetailsHeaderView.self)?.with {
            $0.tag = section
            $0.onCollapseExpand = { [weak self] section in
                guard let self else { return }
                let wasExpanded = self.viewModel.expandedSections.contains(section)
                let oldRowCount = self.viewModel.numberOfRowsForLesson(section: section)
                self.viewModel.toggleSectionExpansion(section) {
                    if wasExpanded {
                        let indexPaths = (0 ..< oldRowCount).map { IndexPath(row: $0, section: section) }
                        tableView.performBatchUpdates {
                            tableView.deleteRows(at: indexPaths, with: .fade)
                        }
                    } else {
                        let newRowCount = self.viewModel.numberOfRowsForLesson(section: section)
                        let indexPaths = (0 ..< newRowCount).map { IndexPath(row: $0, section: section) }
                        tableView.performBatchUpdates {
                            tableView.insertRows(at: indexPaths, with: .automatic)
                        }
                    }
                    if let header = tableView.headerView(forSection: section) as? CourseDetailsHeaderView {
                        header.animateExpandCollapse(isExpanded: !wasExpanded)
                    }
                }
            }
            $0.setLessonTitleLabel(lesson.name)
            $0.setNumberLabel(viewModel.lessonNumbersList?[section] ?? 0)
            $0.assignSectionTagToButton(section)
            $0.configureVisibilityOfExpandButton(
                state: viewModel.course?.parsedReservationState,
                doesContainAttachments: viewModel.doesLessonContainAttachments[section] ?? false
            )
        }
        if lesson.locked {
            view?.setImageOfButton(Images.lock.image)
        } else {
            view?.setImageOfButton(viewModel.expandedSections.contains(section) ? Images.collapse.image : Images.expand.image)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (viewModel.activeScreen == .details && !(host?.isContentLoading ?? false)) ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        (viewModel.activeScreen == .details && !(host?.isContentLoading ?? false)) ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.activeScreen == .details ? 5.0 : 0.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.activeScreen == .materials {
            host?.handleMaterialsSelection(at: indexPath)
        } else if viewModel.activeScreen == .details {
            host?.handleDetailsSelection(at: indexPath)
        }
    }
}
