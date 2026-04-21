// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

class FiltersTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var label: UILabel!
    @IBOutlet private var collectionView: UICollectionView!

    // MARK: - Public Properties

    var filters: [String] = []
    var onSelectSchoolFilter: ((Int, SchoolSection) -> Void)?
    var onSelectUniversityFilter: ((Int, UniversitySection) -> Void)?
    var academicLevel: AcademicLevel = .schoolStudent
    var currentSchoolSection: SchoolSection = .academicType
    var currentUniversitySection: UniversitySection = .university

    // MARK: - Private Functions

    private var selectedIndexPath: IndexPath?
    private var previouslySelectedItemPath: Int?
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
        configureActivityIndicator()
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.semanticContentAttribute = Language.semanticContent
        collectionView.registerCell(ofType: FilterCollectionViewCell.self)
        collectionView.collectionViewLayout = UICollectionViewLocalizableFlowLayout().with {
            $0.scrollDirection = .horizontal
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8)
        ])
    }

    func setIsLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
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

    func selectOldEntry(for item: Int?) {
        previouslySelectedItemPath = item
    }
}

extension FiltersTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        cell.configure(with: filters[indexPath.item])
        if previouslySelectedItemPath != nil, indexPath.item == previouslySelectedItemPath {
            cell.selectFilter()
        }
        return cell
    }
}

// MARK: - Collection View Delegate

extension FiltersTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if academicLevel == .schoolStudent {
            onSelectSchoolFilter?(indexPath.item, currentSchoolSection)
        } else {
            onSelectUniversityFilter?(indexPath.item, currentUniversitySection)
        }
    }
}
