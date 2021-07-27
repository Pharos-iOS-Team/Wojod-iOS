// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

protocol SelectingFilterDelegate: AnyObject {
    func didSelectFilter(_ filterIndex: Int, in section: SchoolSection)
    func didSelectFilterInUniversity(_ filterIndex: Int, in section: UniversitySection)
}

class FiltersTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var label: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!

    // MARK: - Public Properties

    var filters: [String] = []
    weak var delegate: SelectingFilterDelegate?
    var academicLevel: AcademicLevel = .schoolStudent
    var currentSchoolSection: SchoolSection = .academicType
    var currentUniversitySection: UniversitySection = .university

    // MARK: - Private Functions

    private var selectedIndexPath: IndexPath?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
    }

    func configure(title: String, filters: [String], section: SchoolSection) {
        label.text = title
        self.filters = filters
        self.currentSchoolSection = section
        collectionView.reloadData()
    }

    func configureForUniveristy(title: String, filters: [String], section: UniversitySection) {
        label.text = title
        self.filters = filters
        self.currentUniversitySection = section
        collectionView.reloadData()
    }
}

extension FiltersTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        cell.configure(with: filters[indexPath.item])
        return cell
    }
}

// MARK: - Collection View Delegate

extension FiltersTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if academicLevel == .schoolStudent {
            delegate?.didSelectFilter(indexPath.item, in: currentSchoolSection)
        } else {
            delegate?.didSelectFilterInUniversity(indexPath.item, in: currentUniversitySection)
        }
    }
}

// MARK: - Collection View Delegate Flow Layout

extension FiltersTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = filters[indexPath.item]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 10, height: 50)
    }
}
