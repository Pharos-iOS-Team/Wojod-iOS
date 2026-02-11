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
    
    func formattedTime() -> String {
      let formatter = DateComponentsFormatter()
      
      if self < 3600 {
        formatter.allowedUnits = [.minute, .second]
      } else {
        formatter.allowedUnits = [.hour, .minute, .second]
      }
      
      formatter.unitsStyle = .positional
      formatter.zeroFormattingBehavior = .pad
      return formatter.string(from: self) ?? "00:00"
    }
}
