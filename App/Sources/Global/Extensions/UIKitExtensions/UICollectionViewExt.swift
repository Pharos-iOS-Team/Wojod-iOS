// Copyright © 2020 Pharos Solutions. All rights reserved.

import HandyUIKit
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
}
