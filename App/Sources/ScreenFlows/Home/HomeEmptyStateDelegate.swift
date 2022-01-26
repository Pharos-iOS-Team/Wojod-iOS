// Copyright © 2022 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet

class HomeEmptyStateDelegate: NSObject {
    unowned var sourceViewCtrl: HomeViewController

    init(sourceViewCtrl: HomeViewController) {
        self.sourceViewCtrl = sourceViewCtrl
    }
}

// MARK: - DZN Empty State Data Source

extension HomeEmptyStateDelegate: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: L10n.Home.Search.emptyStateTitle)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if User.shared.organizations.isEmpty {
            return NSAttributedString(string: L10n.Organizations.emptyDescription)
        } else if sourceViewCtrl.isInSearchMode {
            return NSAttributedString(string: L10n.Home.Search.emptyStateDescription)
        } else {
            return NSAttributedString(string: L10n.Home.defaultEmptyState)
        }
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        guard User.shared.organizations.isEmpty else { return nil }
        return NSAttributedString(string: L10n.Organizations.firstApply)
    }
}

// MARK: - DZN Empty State Delegate

extension HomeEmptyStateDelegate: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        guard !sourceViewCtrl.isLoading else { return false }
        return sourceViewCtrl.courses.isEmpty || User.shared.organizations.isEmpty
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        let organizationsListViewCtrl = StoryboardScene.OrganizationsList.organizationsListViewController.instantiate()
        organizationsListViewCtrl.modalPresentationStyle = .fullScreen
        sourceViewCtrl.present(organizationsListViewCtrl, animated: true)
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return sourceViewCtrl.isMyCourses ? 0 : 200
    }

    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        true
    }
}
