// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import HandyUIKit
import UIKit

extension UITableView {
    func dequeCell<Cell: UITableViewCell> () -> Cell {
        let cellName = String(describing: Cell.self)
        guard let myCell = dequeueReusableCell(withIdentifier: cellName) as? Cell else { return Cell() }
        return myCell
    }

//    func setEmptyView(title: String, message: String, isScrollable: Bool = true) {
//        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height / 2))
//        let titleLabel = UILabel().with {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            $0.textColor = UIColor.black
//            $0.font = UIFont.systemFont(ofSize: 20)
//            $0.text = title
//        }
//
//        let messageLabel = UILabel().with {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            $0.textColor = UIColor.lightGray
//            $0.font = UIFont.systemFont(ofSize: 17.5)
//            $0.text = message
//            $0.numberOfLines = 0
//            $0.textAlignment = .center
//        }
//
//        emptyView.addSubviews(titleLabel, messageLabel)
//        titleLabel.centerInSuperview()
//        messageLabel.layoutToSuperview(.leading, offset: 20)
//        messageLabel.layoutToSuperview(.trailing, offset: -20)
//        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
//
//        if isScrollable {
//            tableHeaderView = emptyView
//        } else {
//            backgroundView = emptyView
//        }
//    }

    func removeEmptyState(isScrollable: Bool = true) {
        if isScrollable {
            tableHeaderView = nil
        } else {
            backgroundView = nil
        }
    }
}
