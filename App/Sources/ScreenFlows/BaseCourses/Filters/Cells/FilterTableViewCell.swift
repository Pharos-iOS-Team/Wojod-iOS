// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

class FilterTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var filtersCollectionView: UICollectionView!

    // MARK: - Public Properties

    var filters: [String] = []

    // MARK: - Public Functions

    func configureCollecionView() {
        // filtersCollectionView.register(FilterCollectionViewCell.Type, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        filtersCollectionView.dataSource = self
    }
}

// MARK: - Collection View Data Source

extension FilterTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        cell.configure(filter: filters[indexPath.item])
        return cell
    }
}
