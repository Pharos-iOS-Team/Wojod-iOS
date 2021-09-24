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

    /// Registers a nib with the name of `cellType` if it exists or registers the class of type `cellType` as reusable cell.
    func registerCell<Cell: UICollectionViewCell>(ofType cellType: Cell.Type) {
        let cellTypeName = String(describing: cellType)

        if Bundle.main.path(forResource: cellTypeName, ofType: "nib") != nil {
            register(UINib(nibName: cellTypeName, bundle: .main), forCellWithReuseIdentifier: cellTypeName)
        } else {
            register(cellType, forCellWithReuseIdentifier: cellTypeName)
        }
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
