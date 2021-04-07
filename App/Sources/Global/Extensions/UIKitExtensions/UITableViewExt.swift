// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import HandyUIKit
import UIKit

extension UITableView {
    func dequeueCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        return dequeueCell(ofType: Cell.self, for: indexPath) ?? Cell()
    }
}

// MARK: - Scrolling

extension UITableView {
    var lastIndexPath: IndexPath {
        return IndexPath(
            row: numberOfRows(inSection: numberOfSections - 1) - 1,
            section: numberOfSections - 1
        )
    }

    func scrollToBottom(animated: Bool = false) {
        guard hasRowAtIndexPath(lastIndexPath) else { return }
        scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
    }

    func scrollToTop(animated: Bool = false) {
        guard hasRowAtIndexPath(.zero) else { return }
        scrollToRow(at: .zero, at: .top, animated: animated)
    }

    func hasRowAtIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
