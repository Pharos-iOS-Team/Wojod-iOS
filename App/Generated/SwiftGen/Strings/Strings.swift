// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum CreatePassword {
    /// All fields are required
    internal static var bothAreEmpty: String {
        return L10n.tr("Localizable", "createPassword.bothAreEmpty")
      }
    /// Confirm password
    internal static var confirmPassword: String {
        return L10n.tr("Localizable", "createPassword.confirmPassword")
      }
    /// Please make sure the password you entered is minimum 6 letters long
    internal static var passwordLengthTooShort: String {
        return L10n.tr("Localizable", "createPassword.passwordLengthTooShort")
      }
    /// The passwords you entered do not match
    internal static var passwordsDontMatch: String {
        return L10n.tr("Localizable", "createPassword.passwordsDontMatch")
      }
    /// Set new password
    internal static var setNewPassword: String {
        return L10n.tr("Localizable", "createPassword.setNewPassword")
      }
  }

  internal enum Login {
    /// Please enter the mobile number and password
    internal static var bothAreEmpty: String {
        return L10n.tr("Localizable", "login.bothAreEmpty")
      }
    /// Forgot password?
    internal static var forgotPassword: String {
        return L10n.tr("Localizable", "login.forgotPassword")
      }
    /// Forgot password?\nNo worries!
    internal static var forgotPasswordTitle: String {
        return L10n.tr("Localizable", "login.forgotPasswordTitle")
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
    /// Please enter your phone number, OTP will be sent to your mobile
    internal static var otpWillBeSent: String {
        return L10n.tr("Localizable", "login.otpWillBeSent")
      }
    /// Password
    internal static var password: String {
        return L10n.tr("Localizable", "login.password")
      }
    /// Please enter the password
    internal static var passwordIsEmpty: String {
        return L10n.tr("Localizable", "login.passwordIsEmpty")
      }
    /// Send
    internal static var send: String {
        return L10n.tr("Localizable", "login.send")
      }
    /// Sign in
    internal static var signIn: String {
        return L10n.tr("Localizable", "login.signIn")
      }
    /// Welcome!\nSign in to continue
    internal static var welcome: String {
        return L10n.tr("Localizable", "login.welcome")
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

  internal enum VerifyOtp {
    /// Continue
    internal static var `continue`: String {
        return L10n.tr("Localizable", "verifyOtp.continue")
      }
    /// Didn’t receive a code?
    internal static var didNotGetACode: String {
        return L10n.tr("Localizable", "verifyOtp.didNotGetACode")
      }
    /// If you didn’t receive a code please contact the admin
    internal static var didNotGetACodeAlert: String {
        return L10n.tr("Localizable", "verifyOtp.didNotGetACodeAlert")
      }
    /// Please enter the OTP sent to your phone
    internal static var pleaseEnterOTP: String {
        return L10n.tr("Localizable", "verifyOtp.pleaseEnterOTP")
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
