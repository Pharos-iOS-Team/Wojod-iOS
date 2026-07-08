// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

/// Protocol defining navigation actions for courses screens
protocol CoursesNavigationCoordinating: AnyObject {
    func showCourseDetails(course: Course?, teacherName: String?, teacherID: Int?, from viewController: UIViewController)
    func showNotifications(from viewController: UIViewController)
    func showHelpCenter(from viewController: UIViewController)
    func showFilters(currentSelection: FilterSelection, onApplyFilters: @escaping (FilterSelection, CoursesResponse?) -> Void, from viewController: UIViewController)
    func showOrganizationsList(from viewController: UIViewController)
}

/// Default implementation of courses navigation coordinator
final class CoursesNavigationCoordinator: CoursesNavigationCoordinating {
    func showCourseDetails(course: Course?, teacherName: String?, teacherID: Int?, from viewController: UIViewController) {
        let viewModel = CourseDetailsViewModel().with {
            $0.course = course
            $0.teacherName = teacherName
            $0.teacherID = teacherID
            $0.courseState = course?.parsedReservationState ?? .normal
        }

        let courseDetailsViewCtrl = CourseDetailsViewController.make(viewModel: viewModel, coordinator: CourseDetailsCoordinator())

        let navigationController = UINavigationController(rootViewController: courseDetailsViewCtrl)
        navigationController.modalPresentationStyle = .fullScreen
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

    func showFilters(currentSelection: FilterSelection, onApplyFilters: @escaping (FilterSelection, CoursesResponse?) -> Void, from viewController: UIViewController) {
        let filtersViewCtrl = StoryboardScene.Filters.initialScene.instantiate()
        filtersViewCtrl.onApplyFilters = onApplyFilters
        filtersViewCtrl.currentSelection = currentSelection
        viewController.present(filtersViewCtrl, animated: true)
    }

    func showOrganizationsList(from viewController: UIViewController) {
        let organizationsViewCtrl = StoryboardScene.OrganizationsList.organizationsListViewController.instantiate()
        organizationsViewCtrl.modalPresentationStyle = .fullScreen
        viewController.present(organizationsViewCtrl, animated: true)
    }
}
