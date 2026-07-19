// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import LanguageManager_iOS

class TimeCalculator {
    // MARK: - Singleton

    static var sharedInstance = TimeCalculator()

    // MARK: - Initializers

    private init() {}

    // MARK: - Private functions

    private func getLoacalizedHoursText(hours: Int) -> String {
        if hours == 1 {
            return L10n.Quizzes._1hour
        } else {
            if LanguageManager.shared.currentLanguage == .en {
                return "\(hours) hours ago"
            } else {
                var text = L10n.Quizzes.hours
                var hoursText = "\(hours)"
                if LanguageManager.shared.currentLanguage == .ar {
                    hoursText = hoursText.englishToArabicText()
                    if hours == 2 {
                        text = L10n.Quizzes._2hrs
                        hoursText = ""
                    } else  if hours > 11 {
                        text = L10n.Quizzes.hour
                    }
                }
                return "\(L10n.Quizzes.since) \(hoursText) \(text)"
            }
        }
    }

    private func getLoacalizedMinutesAgoText(minutes: Int) -> String {
        if minutes == 1 {
            return L10n.Quizzes._1min
        } else {
            if LanguageManager.shared.currentLanguage == .en {
                return "\(minutes) minutes ago"
            } else {
                var text = L10n.Quizzes.minutes
                var minutesText = "\(minutes)"
                if LanguageManager.shared.currentLanguage == .ar {
                    minutesText = minutesText.englishToArabicText()
                    if minutes == 2 {
                        text = L10n.Quizzes._2mins
                        minutesText = ""
                    } else  if minutes > 11 {
                        text = L10n.Quizzes.minute
                    }
                }
                return "\(L10n.Quizzes.since) \(minutesText) \(text)"
            }
        }
    }

    // MARK: - Public functions

    func getLoacalizedMinutesText(minutes: Int?) -> String {
        guard let minutes = minutes,
            let formatedMinutes = NumberFormatter.getFormattedString(fromInt: minutes)
            else { return "" }
        let isArabic = LanguageManager.shared.currentLanguage == .ar
        switch minutes {
        case 1:
            return isArabic ? L10n.Quizzes.minute : "\(formatedMinutes) \(L10n.Quizzes.minute)"
        case 2:
            return isArabic ? L10n.Quizzes._2mins : "\(formatedMinutes) \(L10n.Quizzes._2mins)"
        case 3 ..< 11:
            return "\(formatedMinutes) \(L10n.Quizzes.minutes)"
        default:
            return isArabic ? "\(formatedMinutes) \(L10n.Quizzes.minute)" : "\(formatedMinutes) \(L10n.Quizzes.minutes)"
        }
    }
}

// MARK: - Past
extension TimeCalculator {
    func timeAgoSinceDate(date: Date) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = earliest == now as Date ? date : now as Date
        let components = calendar.dateComponents([.day, .hour, .minute], from: earliest, to: latest)
        guard let minutes = components.minute, let hours = components.hour, let days = components.day else {
            return ""
        }
        if days >= 2 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = GlobalConstants.datePreviewFormat
            dateFormatter.locale = Locale(identifier: LanguageManager.shared.currentLanguage.rawValue)
            return dateFormatter.string(from: date)
        } else if days >= 1 {
            return L10n.Quizzes.yesterday
        } else if hours >= 1 {
            return getLoacalizedHoursText(hours: hours)
        } else if minutes >= 1 {
            return getLoacalizedMinutesAgoText(minutes: minutes)
        } else {
            return L10n.Quizzes.fewSeconds
        }
    }
}

// MARK: - Future
extension TimeCalculator {
    fileprivate func timeTillDateText(_ hours: Int, _ days: Int, _ date: Date) -> String {
        if days == 7 {
            return L10n.Quizzes.endInOneWeek
        } else if days > 1, days < 7 {
            return L10n.Quizzes.endInMoreThan1Day(NumberFormatter.getFormattedString(fromInt: days) ?? "")
        } else if days == 1 {
            return L10n.Quizzes.endInOneDay
        } else if hours > 10, days == 0 {
            return L10n.Quizzes.endInMoreThan10Hours(NumberFormatter.getFormattedString(fromInt: hours) ?? "")
        } else if hours <= 10, days == 0 {
            return L10n.Quizzes.endInMoreThan1HourAndLessThan11Hours(NumberFormatter.getFormattedString(fromInt: hours) ?? "")
        } else if hours == 2, days == 0 {
            return L10n.Quizzes.endIn2Hours(NumberFormatter.getFormattedString(fromInt: hours) ?? "")
        } else if hours <= 1, days == 0 {
            return L10n.Quizzes.endInOneHour
        } else {
            return L10n.Quizzes.endsIn(date.formatted(with: GlobalConstants.datePreviewFormat))
        }
    }

    func timeTillDate(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let dueDate = date.endOfDay ?? Date()
        let components = calendar.dateComponents([.day, .hour], from: now, to: dueDate)
        guard let hours = components.hour, let days = components.day else { return "" }
        return timeTillDateText(hours, days, date)
    }
}
