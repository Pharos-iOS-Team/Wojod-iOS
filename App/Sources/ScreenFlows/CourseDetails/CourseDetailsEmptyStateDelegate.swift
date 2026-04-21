// Copyright © 2026 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import UIKit

final class CourseDetailsEmptyStateDelegate: NSObject {
    private weak var viewModel: CourseDetailsViewModel?

    init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}

// MARK: - DZNEmptyDataSetSource

extension CourseDetailsEmptyStateDelegate: DZNEmptyDataSetSource {
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard let viewModel else { return nil }
        switch viewModel.activeScreen {
        case .details:
            return NSAttributedString(string: L10n.CourseDetails.CourseReview.emptyDetails)
        case .materials:
            return NSAttributedString(string: L10n.CourseDetails.CourseReview.emptyMaterials)
        case .reviews:
            return NSAttributedString(string: L10n.CourseDetails.CourseReview.emptyReviews)
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate

extension CourseDetailsEmptyStateDelegate: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        guard let tableView = scrollView as? UITableView, let headerView = tableView.tableHeaderView
        else { return 200 }
        return headerView.frame.size.height / 2
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        guard let viewModel else { return false }
        if viewModel.isLoadingTab { return false }
        switch viewModel.activeScreen {
        case .details:
            return viewModel.lessonsList.isEmpty
        case .materials:
            return (viewModel.materials?.assignments?.isEmpty ?? true)
            && (viewModel.materials?.documents?.isEmpty ?? true)
            && (viewModel.materials?.quizzes?.isEmpty ?? true)
            && (viewModel.materials?.videos?.isEmpty ?? true)
        case .reviews:
            return viewModel.reviewsList.isEmpty
        }
    }
}
