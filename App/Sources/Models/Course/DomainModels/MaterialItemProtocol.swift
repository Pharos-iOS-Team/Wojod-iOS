// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

protocol MaterialItemProtocol {
    var displayTitle: String? { get }
    var displayDate: String { get }
    var displayIcon: UIImage { get }
    var displayDuration: Int? { get }
    var displayDaysRemaining: Int? { get }
    var sortDate: Date { get }
    var payload: MaterialItemPayload { get }
}
