// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension CGFloat {
    public static func orientationAdjusted(
        portrait portraitValue: CGFloat,
        landscape landscapeValue: CGFloat
    ) -> CGFloat {
        return UIWindow.isPortrait ? portraitValue : landscapeValue
    }

    public static func deviceAdjusted(
        phone phoneValue: CGFloat,
        pad padValue: CGFloat
    ) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return phoneValue
        } else {
            return padValue
        }
    }
}
