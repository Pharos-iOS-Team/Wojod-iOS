// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension UICollectionView {
    func dequeCell<Cell: UICollectionViewCell>(indexPath: IndexPath) -> Cell {
        let cellName = String(describing: Cell.self)
        guard let myCell = self.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? Cell else {
            return Cell()
        }
        return myCell
    }

    func dequeueReusableHeader<Header: UICollectionReusableView>(indexPath: IndexPath) -> Header {
        guard
            let header = dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(Header.self)",
                for: indexPath
            ) as? Header
        else {
            return Header()
        }

        return header
    }

    func registerSectionHeader(type: UICollectionReusableView.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(type.self)")
    }

    func reloadWithAnimation() {
        let range = NSMakeRange(0, self.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.reloadSections(sections as IndexSet)
    }
}

extension UICollectionView {
//    func setEmptyView(message: String) {
//        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height / 2))
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
//        emptyView.addSubview(messageLabel)
//        messageLabel.centerInSuperview()
//        backgroundView = emptyView
//    }

    func removeEmptyState() {
        backgroundView = nil
    }
}
