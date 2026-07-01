// Copyright © 2026 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import UIKit

class CoursesEmptyStateDelegate: NSObject {
    private weak var viewModel: BaseCoursesViewModel?
    private weak var navigationCoordinator: CoursesNavigationCoordinating?

    init(viewModel: BaseCoursesViewModel, navigationCoordinator: CoursesNavigationCoordinating? = nil) {
        self.viewModel = viewModel
        self.navigationCoordinator = navigationCoordinator
        super.init()
    }
}

extension CoursesEmptyStateDelegate: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard let viewModel = viewModel else { return nil }
        return NSAttributedString(string: viewModel.emptyStateType.title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard let viewModel = viewModel else { return nil }
        return NSAttributedString(string: viewModel.emptyStateType.description)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        guard let viewModel = viewModel, let buttonTitle = viewModel.emptyStateType.buttonTitle
        else { return nil }
        return NSAttributedString(string: buttonTitle)
    }
}

extension CoursesEmptyStateDelegate: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        guard let viewModel = viewModel else { return false }
        if case .loading = viewModel.emptyStateType {
            return false
        }
        return viewModel.courses.isEmpty || User.shared.organizations.isEmpty
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        guard let baseViewCtrl = scrollView.findViewController() else { return }
        if let coordinator = navigationCoordinator {
            coordinator.showOrganizationsList(from: baseViewCtrl)
        } else {
            let organizationsListViewCtrl = StoryboardScene.OrganizationsList.organizationsListViewController.instantiate()
            organizationsListViewCtrl.modalPresentationStyle = .fullScreen
            baseViewCtrl.present(organizationsListViewCtrl, animated: true)
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.emptyStateType.verticalOffset
    }

    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
