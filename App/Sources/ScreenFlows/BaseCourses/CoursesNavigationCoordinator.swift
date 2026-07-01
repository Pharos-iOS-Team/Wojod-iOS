// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

/// Protocol defining navigation actions for courses screens
protocol CoursesNavigationCoordinating: AnyObject {
    func showCourseDetails(course: Course?, teacherName: String?, teacherID: Int?, from viewController: UIViewController)
    func showNotifications(from viewController: UIViewController)
    func showHelpCenter(from viewController: UIViewController)
    func showFilters(delegate: FiltersDelegate?, currentSelection: FilterSelection, from viewController: UIViewController)
    func showOrganizationsList(from viewController: UIViewController)
}

/// Default implementation of courses navigation coordinator
final class CoursesNavigationCoordinator: CoursesNavigationCoordinating {
    func showCourseDetails(course: Course?, teacherName: String?, teacherID: Int?, from viewController: UIViewController) {
        let courseDetailsViewCtrl = StoryboardScene.CourseDetails.initialScene.instantiate()
        courseDetailsViewCtrl.course = course
        courseDetailsViewCtrl.teacherName = teacherName
        courseDetailsViewCtrl.teacherID = teacherID

        let navigationController = UINavigationController(rootViewController: courseDetailsViewCtrl)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true

        let backButton = UIBarButtonItem()
        backButton.title = L10n.Navigation.back
        navigationController.navigationBar.topItem?.backBarButtonItem = backButton

        viewController.present(navigationController, animated: true)
    }

    func showNotifications(from viewController: UIViewController) {
        let notificationsViewCtrl = StoryboardScene.Notifications.initialScene.instantiate()
        notificationsViewCtrl.modalPresentationStyle = .fullScreen
        viewController.present(notificationsViewCtrl, animated: true)
    }

    func showHelpCenter(from viewController: UIViewController) {
        let chatViewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate()
        chatViewCtrl.chatType = .customerSupport
        chatViewCtrl.modalPresentationStyle = .fullScreen
        viewController.present(chatViewCtrl, animated: true)
    }

    func showFilters(delegate: FiltersDelegate?, currentSelection: FilterSelection, from viewController: UIViewController) {
        let filtersViewCtrl = StoryboardScene.Filters.initialScene.instantiate()
        filtersViewCtrl.delegate = delegate
        filtersViewCtrl.currentSelection = currentSelection
        viewController.present(filtersViewCtrl, animated: true)
    }

    func showOrganizationsList(from viewController: UIViewController) {
        let organizationsViewCtrl = StoryboardScene.OrganizationsList.organizationsListViewController.instantiate()
        organizationsViewCtrl.modalPresentationStyle = .fullScreen
        viewController.present(organizationsViewCtrl, animated: true)
    }
}
