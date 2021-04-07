// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
extension L10n {

  internal enum Global {
    /// Please try again later
    internal static let message = L10n.tr("GlobalLocalizable", "global.message.")
    internal enum Actions {
      /// Add
      internal static let add = L10n.tr("GlobalLocalizable", "global.actions.add")
      /// Cancel
      internal static let cancel = L10n.tr("GlobalLocalizable", "global.actions.cancel")
      /// Close
      internal static let close = L10n.tr("GlobalLocalizable", "global.actions.close")
      /// Confirm
      internal static let confirm = L10n.tr("GlobalLocalizable", "global.actions.confirm")
      /// Delete
      internal static let delete = L10n.tr("GlobalLocalizable", "global.actions.delete")
      /// Done
      internal static let done = L10n.tr("GlobalLocalizable", "global.actions.done")
      /// Edit
      internal static let edit = L10n.tr("GlobalLocalizable", "global.actions.edit")
      /// Login
      internal static let login = L10n.tr("GlobalLocalizable", "global.actions.login")
      /// Logout
      internal static let logout = L10n.tr("GlobalLocalizable", "global.actions.logout")
      /// No
      internal static let no = L10n.tr("GlobalLocalizable", "global.actions.no")
      /// Ok
      internal static let ok = L10n.tr("GlobalLocalizable", "global.actions.ok")
      /// Save
      internal static let save = L10n.tr("GlobalLocalizable", "global.actions.save")
      /// Search
      internal static let search = L10n.tr("GlobalLocalizable", "global.actions.search")
    }
    internal enum Alerts {
      /// Something went wrong while preparing the data
      internal static let dataPreparationError = L10n.tr("GlobalLocalizable", "global.alerts.data_preparation_error")
      /// Are you sure you need to logout?
      internal static let logout = L10n.tr("GlobalLocalizable", "global.alerts.logout")
      /// Something went wrong, check your connection and try again in a while
      internal static let somethingWentWrong = L10n.tr("GlobalLocalizable", "global.alerts.something_went_wrong")
    }
    internal enum Titles {
      /// Error
      internal static let error = L10n.tr("GlobalLocalizable", "global.titles.error")
      /// Settings
      internal static let settings = L10n.tr("GlobalLocalizable", "global.titles.settings")
      /// Warning
      internal static let warning = L10n.tr("GlobalLocalizable", "global.titles.warning")
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
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
