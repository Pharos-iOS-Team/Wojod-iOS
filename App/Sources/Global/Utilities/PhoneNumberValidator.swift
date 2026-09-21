// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import PhoneNumberKit
import PhoneNumberKitUI

/// Centralises all phone-number validation rules for the application.
///
/// Rules:
/// - **Standard phones** (student primary / secondary): validated with
///   `PhoneNumberKit` using the selected country region code.
/// - **Parent phones**: only a minimum digit count is enforced
///   (no country-specific format check).
/// - **OTP provider selection**: first-time is always WhatsApp;
///   resends use SMS for Egyptian numbers and WhatsApp for all others.
enum PhoneNumberValidator {
    // MARK: - Constants

    private static let phoneUtility = PhoneNumberUtility()
    static let egyptRegionCode: String = "EG"
    static let egyptCountryCode: String = "+20"

    // MARK: - Prefix Protection

    /// Returns the character length of the dial-code prefix for the given region,
    /// e.g. `3` for `+20` (Egypt).
    static func prefixLength(for regionCode: String) -> Int {
        let code = phoneUtility.countryCode(for: regionCode) ?? 20
        return "+\(code)".count
    }

    /// Returns `false` when the proposed edit touches the read-only dial-code
    /// prefix, `true` otherwise. Use from `UITextFieldDelegate.shouldChange…`.
    static func shouldAllowEdit(in phoneField: PhoneNumberTextField, range: NSRange) -> Bool {
        range.location >= prefixLength(for: phoneField.currentRegion)
    }

    // MARK: - Number Formatting

    /// Ensures an Egyptian (+20) phone number always carries a leading `0`.
    /// If the number already starts with `0` it is returned unchanged;
    /// otherwise a `0` is prepended. Non-Egyptian numbers are returned as-is.
    static func formattedEgyptianPhone(_ number: String, countryCode: String) -> String {
        guard countryCode == egyptCountryCode else { return number }
        return number.hasPrefix("0") ? number : "0" + number
    }

    /// Strips a single leading `0` from `number` when `countryCode` is the
    /// Egyptian dial code. Used for display-only contexts where the dial code
    /// is shown alongside the national number (e.g. the profile screen) so the
    /// leading 0 is not duplicated as `+20 012...`.
    static func stripEgyptianLeadingZero(_ number: String, countryCode: String) -> String {
        guard countryCode == egyptCountryCode, number.hasPrefix("0") else { return number }
        return String(number.dropFirst())
    }

    /// Returns the regional-indicator emoji flag for an ISO region code (e.g.
    /// `"EG"` → `"🇪🇬"`). Returns an empty string for unknown/invalid codes.
    static func flagEmoji(forRegionCode regionCode: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        return regionCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()
    }

    /// Returns the phone number with its country dial code in a display-friendly format.
    static func formattedInternationalPhone(_ number: String, countryCode: String) -> String {
        let dialCode = countryCode.hasPrefix("+") ? countryCode : "+\(countryCode)"
        let displayNumber = stripEgyptianLeadingZero(number, countryCode: dialCode)

        guard !displayNumber.isEmpty else { return "" }
        return "\(dialCode) \(displayNumber)"
    }
}
