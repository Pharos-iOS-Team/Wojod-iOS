// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

/// Protocol defining navigation actions for courses screens
protocol CoursesNavigationCoordinating: AnyObject {
    func showCourseDetails(course: Course?, teacherName: String?, teacherID: Int?, from viewController: UIViewController)
    func showNotifications(from viewController: UIViewController)
    func prefetchWhatsAppSupportNumber()
    func showWhatsAppSupport(from viewController: UIViewController)
    func showFilters(currentSelection: FilterSelection, onApplyFilters: @escaping (FilterSelection, CoursesResponse?) -> Void, from viewController: UIViewController)
    func showOrganizationsList(from viewController: UIViewController)
}

/// Default implementation of courses navigation coordinator
final class CoursesNavigationCoordinator: CoursesNavigationCoordinating {
    private let whatsAppSupportRepository: WhatsAppSupportRepositoryProtocol
    private var cachedWhatsAppNumber: String?

    init(whatsAppSupportRepository: WhatsAppSupportRepositoryProtocol = WhatsAppSupportRepository()) {
        self.whatsAppSupportRepository = whatsAppSupportRepository
    }

    func showCourseDetails(course: Course?, teacherName: String?, teacherID: Int?, from viewController: UIViewController) {
        let viewModel = CourseDetailsViewModel().with {
            $0.state.course = course
            $0.state.teacherName = teacherName
            $0.state.teacherID = teacherID
        }

        let courseDetailsViewCtrl = CourseDetailsViewController.make(viewModel: viewModel, coordinator: CourseDetailsCoordinator())

        let navigationController = UINavigationController(rootViewController: courseDetailsViewCtrl)
        navigationController.modalPresentationStyle = .fullScreen
        viewController.present(navigationController, animated: true)
    }

    func showNotifications(from viewController: UIViewController) {
        let notificationsViewCtrl = StoryboardScene.Notifications.initialScene.instantiate()
        let navigationController = UINavigationController(rootViewController: notificationsViewCtrl)
        navigationController.modalPresentationStyle = .fullScreen
        viewController.present(navigationController, animated: true)
    }

    func prefetchWhatsAppSupportNumber() {
        Task { @MainActor in
            cachedWhatsAppNumber = try? await whatsAppSupportRepository.fetchWhatsAppSupportNumber()
        }
    }

    func showWhatsAppSupport(from viewController: UIViewController) {
        Task { @MainActor [weak viewController] in
            guard let viewController else { return }
            do {
                let phoneNumber: String
                if let cached = cachedWhatsAppNumber {
                    phoneNumber = cached
                } else {
                    phoneNumber = try await whatsAppSupportRepository.fetchWhatsAppSupportNumber()
                    cachedWhatsAppNumber = phoneNumber
                }
                let message = L10n.Home.whatsappSupportMessage(phoneNumber)
                let internationalNumber = Self.egyptianInternationalNumber(from: phoneNumber)
                AlertHandler(presentingViewCtrl: viewController).showConfirmAlert(
                    title: L10n.Home.helpCenter,
                    message: message,
                    confirmButtonTitle: L10n.Home.openWhatsApp
                ) { _ in
                    guard let url = URL(string: "https://wa.me/\(internationalNumber)") else { return }
                    UIApplication.shared.open(url)
                }
            } catch {
                AlertHandler(presentingViewCtrl: viewController).showInformationAlert(
                    title: L10n.Global.Titles.error,
                    message: error.localizedDescription
                )
            }
        }
    }

    func showFilters(currentSelection: FilterSelection, onApplyFilters: @escaping (FilterSelection, CoursesResponse?) -> Void, from viewController: UIViewController) {
        let filtersViewCtrl = StoryboardScene.Filters.initialScene.instantiate()
        filtersViewCtrl.onApplyFilters = onApplyFilters
        filtersViewCtrl.currentSelection = currentSelection
        viewController.present(filtersViewCtrl, animated: true)
    }

    func showOrganizationsList(from viewController: UIViewController) {
        let organizationsViewCtrl = StoryboardScene.OrganizationsList.organizationsListViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: organizationsViewCtrl)
        navigationController.modalPresentationStyle = .fullScreen
        viewController.present(navigationController, animated: true)
    }

    // MARK: - Private helpers

    /// Converts a local Egyptian number (e.g. "01067080602") to international format ("201067080602")
    /// required by wa.me links. If the number already starts with "20" it is returned unchanged.
    private static func egyptianInternationalNumber(from number: String) -> String {
        let digits = number.trimmingCharacters(in: .whitespaces)
        if digits.hasPrefix("20") { return digits }
        if digits.hasPrefix("0") { return "20" + digits.dropFirst() }
        return "20" + digits
    }
}
