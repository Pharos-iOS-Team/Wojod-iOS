// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
extension L10n {

  internal enum Global {
    internal enum Actions {
      /// Add
      internal static var add: String {
          return L10n.tr("GlobalLocalizable", "global.actions.add")
        }
      /// Cancel
      internal static var cancel: String {
          return L10n.tr("GlobalLocalizable", "global.actions.cancel")
        }
      /// Close
      internal static var close: String {
          return L10n.tr("GlobalLocalizable", "global.actions.close")
        }
      /// Confirm
      internal static var confirm: String {
          return L10n.tr("GlobalLocalizable", "global.actions.confirm")
        }
      /// Delete
      internal static var delete: String {
          return L10n.tr("GlobalLocalizable", "global.actions.delete")
        }
      /// Done
      internal static var done: String {
          return L10n.tr("GlobalLocalizable", "global.actions.done")
        }
      /// Edit
      internal static var edit: String {
          return L10n.tr("GlobalLocalizable", "global.actions.edit")
        }
      /// Login
      internal static var login: String {
          return L10n.tr("GlobalLocalizable", "global.actions.login")
        }
      /// Logout
      internal static var logout: String {
          return L10n.tr("GlobalLocalizable", "global.actions.logout")
        }
      /// No
      internal static var no: String {
          return L10n.tr("GlobalLocalizable", "global.actions.no")
        }
      /// Ok
      internal static var ok: String {
          return L10n.tr("GlobalLocalizable", "global.actions.ok")
        }
      /// Save
      internal static var save: String {
          return L10n.tr("GlobalLocalizable", "global.actions.save")
        }
      /// Search
      internal static var search: String {
          return L10n.tr("GlobalLocalizable", "global.actions.search")
        }
    }
    internal enum Alerts {
      /// Something went wrong while preparing the data
      internal static var dataPreparationError: String {
          return L10n.tr("GlobalLocalizable", "global.alerts.data_preparation_error")
        }
      /// Loading
      internal static var loading: String {
          return L10n.tr("GlobalLocalizable", "global.alerts.loading")
        }
      /// Are you sure you need to logout?
      internal static var logout: String {
          return L10n.tr("GlobalLocalizable", "global.alerts.logout")
        }
      /// Something went wrong, check your connection and try again in a while
      internal static var somethingWentWrong: String {
          return L10n.tr("GlobalLocalizable", "global.alerts.something_went_wrong")
        }
    }
    internal enum Titles {
      /// Error
      internal static var error: String {
          return L10n.tr("GlobalLocalizable", "global.titles.error")
        }
      /// Settings
      internal static var settings: String {
          return L10n.tr("GlobalLocalizable", "global.titles.settings")
        }
      /// Warning
      internal static var warning: String {
          return L10n.tr("GlobalLocalizable", "global.titles.warning")
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
