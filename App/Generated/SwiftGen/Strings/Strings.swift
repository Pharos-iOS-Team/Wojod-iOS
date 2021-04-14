// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Login {
    /// Please enter the mobile number and password
    internal static var bothAreEmpty: String {
        return L10n.tr("Localizable", "login.bothAreEmpty")
      }
    /// Forgot password?
    internal static var forgotPassword: String {
        return L10n.tr("Localizable", "login.forgotPassword")
      }
    /// Mobile number or password entered are not correct
    internal static var invalidCredentials: String {
        return L10n.tr("Localizable", "login.invalidCredentials")
      }
    /// Mobile number
    internal static var mobileNumber: String {
        return L10n.tr("Localizable", "login.mobileNumber")
      }
    /// Please enter the mobile number
    internal static var mobileNumberIsEmpty: String {
        return L10n.tr("Localizable", "login.mobileNumberIsEmpty")
      }
    /// No account? Sign up
    internal static var noAccount: String {
        return L10n.tr("Localizable", "login.noAccount")
      }
    /// Password
    internal static var password: String {
        return L10n.tr("Localizable", "login.password")
      }
    /// Please enter the password
    internal static var passwordIsEmpty: String {
        return L10n.tr("Localizable", "login.passwordIsEmpty")
      }
    /// Sign in
    internal static var signIn: String {
        return L10n.tr("Localizable", "login.signIn")
      }
  }

  internal enum Shared {
    internal enum Alerts {
      internal enum Camera {
        /// Wojood need to access camera
        internal static var message: String {
            return L10n.tr("Localizable", "shared.alerts.camera.message")
          }
        /// Camera Permission
        internal static var title: String {
            return L10n.tr("Localizable", "shared.alerts.camera.title")
          }
      }
      internal enum Photos {
        /// Wojood need to access Photos
        internal static var message: String {
            return L10n.tr("Localizable", "shared.alerts.photos.message")
          }
        /// Gallery Permission
        internal static var title: String {
            return L10n.tr("Localizable", "shared.alerts.photos.title")
          }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static var bundle: Bundle {
    Bundle(path: Bundle.main.path(forResource: Language.currentLanguage.rawValue, ofType: "lproj")!)!
  }
}
// swiftlint:enable convenience_type
