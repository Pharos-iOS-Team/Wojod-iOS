// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
enum GlobalConstants {
    enum Application {
        static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    static let homeworkDatesDateFormat: String = "d MMM h:mm a"
    static let dateTimeFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let avalibalityShortFormatWithoutYear: String = "d MMM,h:mm a"
    static let dayAndMonthFormat: String = "d MMM"
    static let timeOnlyFormat: String = "h:mm"
    static let periodFormat: String = "a"
    static let dueDateFormat: String = "dd MMMM yyyy h:mm a"
    static let datePreviewFormat: String = "dd MMMM yyyy"
    static let watermarkPositionChangeInterval: TimeInterval = .seconds(15.0)
}
