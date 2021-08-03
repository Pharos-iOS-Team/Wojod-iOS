// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit
import HandySwift

class SubjectsCollectionViewDataObject: NSObject, UICollectionViewDataSource {
    private let viewModel: SubjectsViewModel?
    private let skeletonNumberOfItemsInSection = 5
    
    init(viewModel: GenericSubjectsViewModel?) {
        self.viewModel = SubjectsViewModel(viewModel: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getNumberOfSubjects()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OptionCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        let subjectName = getSubjectNameForCell(at: indexPath)
        cell.setTitle(withTitle: subjectName)
        cell.configureDeselectedCell()
        return cell
    }
}

extension SubjectsCollectionViewDataObject {
    private func getNumberOfSubjects() -> Int {
        return viewModel?.getNumberOfSubjects() ?? 0
    }
    
    private func getSubjectNameForCell(at indexPath: IndexPath) -> String {
        return viewModel?.getSubjectName(indexPath: indexPath) ?? ""
    }
}
