// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum AppAlert: StoryboardType {
    internal static let storyboardName = "AppAlert"

    internal static let appAlertViewController = SceneType<Wojood.AppAlertViewController>(storyboard: AppAlert.self, identifier: "AppAlertViewController")
  }
  internal enum AssessmentDetailOverview: StoryboardType {
    internal static let storyboardName = "AssessmentDetailOverview"

    internal static let assessmentDetailOverViewViewController = SceneType<Wojood.AssessmentDetailOverViewViewController>(storyboard: AssessmentDetailOverview.self, identifier: "AssessmentDetailOverViewViewController")
  }
  internal enum AssessmentDetails: StoryboardType {
    internal static let storyboardName = "AssessmentDetails"

    internal static let assessmentDetailsViewController = SceneType<Wojood.AssessmentDetailsViewController>(storyboard: AssessmentDetails.self, identifier: "assessmentDetailsViewController")
  }
  internal enum AvatarsList: StoryboardType {
    internal static let storyboardName = "AvatarsList"

    internal static let avatarsListViewController = SceneType<Wojood.AvatarsListViewController>(storyboard: AvatarsList.self, identifier: "AvatarsListViewController")
  }
  internal enum Chat: StoryboardType {
    internal static let storyboardName = "Chat"

    internal static let audioRecordingViewController = SceneType<Wojood.AudioRecordingViewController>(storyboard: Chat.self, identifier: "AudioRecordingViewController")

    internal static let chatContainerViewController = SceneType<Wojood.ChatContainerViewController>(storyboard: Chat.self, identifier: "ChatContainerViewController")

    internal static let documentContainerViewController = SceneType<Wojood.DocumentContainerViewController>(storyboard: Chat.self, identifier: "DocumentContainerViewController")
  }
  internal enum CourseDetails: StoryboardType {
    internal static let storyboardName = "CourseDetails"

    internal static let initialScene = InitialSceneType<Wojood.CourseDetailsViewController>(storyboard: CourseDetails.self)
  }
  internal enum CoursesList: StoryboardType {
    internal static let storyboardName = "CoursesList"

    internal static let coursesListViewController = SceneType<Wojood.CoursesListViewController>(storyboard: CoursesList.self, identifier: "CoursesListViewController")
  }
  internal enum CoursesTabBar: StoryboardType {
    internal static let storyboardName = "CoursesTabBar"

    internal static let initialScene = InitialSceneType<Wojood.CoursesTabBarViewController>(storyboard: CoursesTabBar.self)

    internal static let coursesTabBarViewController = SceneType<Wojood.CoursesTabBarViewController>(storyboard: CoursesTabBar.self, identifier: "CoursesTabBarViewController")
  }
  internal enum CreatePassword: StoryboardType {
    internal static let storyboardName = "CreatePassword"

    internal static let createPasswordViewController = SceneType<Wojood.CreatePasswordViewController>(storyboard: CreatePassword.self, identifier: "CreatePasswordViewController")
  }
  internal enum Filters: StoryboardType {
    internal static let storyboardName = "Filters"

    internal static let initialScene = InitialSceneType<Wojood.FiltersViewController>(storyboard: Filters.self)
  }
  internal enum ForgotPassword: StoryboardType {
    internal static let storyboardName = "ForgotPassword"

    internal static let forgotPasswordViewController = SceneType<Wojood.ForgotPasswordViewController>(storyboard: ForgotPassword.self, identifier: "ForgotPasswordViewController")
  }
  internal enum Home: StoryboardType {
    internal static let storyboardName = "Home"

    internal static let initialScene = InitialSceneType<Wojood.HomeViewController>(storyboard: Home.self)

    internal static let homeViewController = SceneType<Wojood.HomeViewController>(storyboard: Home.self, identifier: "HomeViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Login: StoryboardType {
    internal static let storyboardName = "Login"

    internal static let loginViewController = SceneType<Wojood.LoginViewController>(storyboard: Login.self, identifier: "LoginViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<Wojood.ViewController>(storyboard: Main.self)

    internal static let viewController = SceneType<Wojood.ViewController>(storyboard: Main.self, identifier: "ViewController")
  }
  internal enum Notifications: StoryboardType {
    internal static let storyboardName = "Notifications"

    internal static let initialScene = InitialSceneType<Wojood.NotificationsViewController>(storyboard: Notifications.self)
  }
  internal enum Profile: StoryboardType {
    internal static let storyboardName = "Profile"

    internal static let profileViewController = SceneType<Wojood.ProfileViewController>(storyboard: Profile.self, identifier: "ProfileViewController")
  }
  internal enum Registration: StoryboardType {
    internal static let storyboardName = "Registration"

    internal static let initialScene = InitialSceneType<Wojood.BasicInfoRegistrationViewController>(storyboard: Registration.self)

    internal static let locationInfo = SceneType<Wojood.LocationInfoViewController>(storyboard: Registration.self, identifier: "LocationInfo")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let settingsViewController = SceneType<Wojood.SettingsViewController>(storyboard: Settings.self, identifier: "SettingsViewController")
  }
  internal enum VerifyOtp: StoryboardType {
    internal static let storyboardName = "VerifyOtp"

    internal static let verifyOtpViewController = SceneType<Wojood.VerifyOtpViewController>(storyboard: VerifyOtp.self, identifier: "VerifyOtpViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
