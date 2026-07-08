// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

protocol Choice {
    var choiceTitle: String { get }
    var choiceSubtitle: String { get }
    var index: Int? { get }
    var subject: Subject? { get }
}
