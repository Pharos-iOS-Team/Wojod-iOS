// Copyright © 2022 Pharos Solutions. All rights reserved.

import HandyUIKit

extension TimeInterval {
    func format(using units: NSCalendar.Unit = [.hour, .minute, .second]) -> String? {
        var calendar = Calendar.current
        calendar.locale = Language.locale
        let formatter = DateComponentsFormatter().with {
            $0.allowedUnits = units
            $0.unitsStyle = .abbreviated
            $0.zeroFormattingBehavior = .dropAll
            $0.calendar = calendar
        }
        return formatter.string(from: self)
    }
}
