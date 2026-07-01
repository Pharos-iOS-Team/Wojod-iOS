// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

protocol HomeTableViewHeaderDelegate: AnyObject {
    func didSelectRelatedCourses()
    func didSelectExploreMore()
    func didSelectSubject(at indexPath: IndexPath)
    func textDidChange(in searchBar: UISearchBar)
}

class HomeTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet private var subjectCollectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            subjectCollectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

    @IBOutlet private var buttonsStackView: UIStackView!
    @IBOutlet private var relatedCoursesButton: UIButton! {
        didSet {
            relatedCoursesButton.layer.cornerRadius = UIConstants.slightCornerRadius
            relatedCoursesButton.setTitle(L10n.Home.relatedCourses)
        }
    }
    @IBOutlet private var exploreMoreButton: UIButton! {
        didSet {
            exploreMoreButton.layer.cornerRadius = UIConstants.slightCornerRadius
            exploreMoreButton.setTitle(L10n.Home.exploreMore)
        }
    }
    @IBOutlet private var subjectsCollectionView: UICollectionView! {
        didSet {
            subjectsCollectionView.allowsMultipleSelection = false
        }
    }
    @IBOutlet private var adsCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet private var dotsIndicator: UIPageControl!
    @IBOutlet private var adsCollectionView: UICollectionView!
    @IBOutlet private var searchBar: UISearchBar!

    // MARK: - Properties

    weak var delegate: HomeTableViewHeaderDelegate?
    var subjects: [Subject]?
    var advertisements: [Advertisement] = []
    var selectedSubjectIndexPath: IndexPath?
    private var mode: HomeMode = .relatedCourses

    // MARK: - IBActions

    @IBAction private func didTapRelatedCourses(_ sender: UIButton) {
        guard mode != .relatedCourses else { return }
        mode = .relatedCourses
        selectRelatedCoursesButton()
        delegate?.didSelectRelatedCourses()
    }

    @IBAction private func didTapExploreMore(_ sender: UIButton) {
        guard mode != .exploreMore else { return }
        mode = .exploreMore
        selectExploreMoreButton()
        delegate?.didSelectExploreMore()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.delegate = self
        configureCollectionViews()
    }

    // MARK: - Functions

    private func configureCollectionViews() {
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        adsCollectionView.dataSource = self
        adsCollectionView.delegate = self
        adsCollectionView.dataSource = self
        adsCollectionView.collectionViewLayout = UICollectionViewLocalizableFlowLayout().with {
            $0.scrollDirection = .horizontal
        }
        subjectsCollectionView.collectionViewLayout = UICollectionViewLocalizableFlowLayout().with {
            $0.scrollDirection = .horizontal
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        subjectsCollectionView.registerCell(ofType: SubjectCollectionViewCell.self)
        adsCollectionView.registerCell(ofType: AdsCollectionViewCell.self)
    }

    func setSubjects(_ subjects: [Subject]?) {
        self.subjects = subjects
        subjectsCollectionView.reloadData()
    }

    func setAdvertisements(_ advertisements: [Advertisement]?) {
        self.advertisements = advertisements ?? []
        adsCollectionView.reloadData()
    }

    func selectRelatedCoursesButton() {
        relatedCoursesButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        relatedCoursesButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        exploreMoreButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        exploreMoreButton.setTitleColor(UIColor.black, for: .normal)
    }

    private func selectExploreMoreButton() {
        relatedCoursesButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        relatedCoursesButton.setTitleColor(UIColor.black, for: .normal)
        exploreMoreButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        exploreMoreButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
    }

    func setButtonsVisibility(_ visible: Bool) {
        buttonsStackView.isHidden = !visible
    }

    func setSubjectsVisibility(_ visible: Bool) {
        subjectsCollectionView.isHidden = !visible
    }

    func setAdvertisementsVisibility(_ visible: Bool) {
        adsCollectionView.isHidden = !visible
        dotsIndicator.isHidden = !visible
    }
}

// MARK: - Collection View Data Source

extension HomeTableViewHeader: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dotsIndicator.numberOfPages = advertisements.count
        return collectionView == subjectsCollectionView ? subjects?.count ?? 0 : advertisements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subjectsCollectionView {
            let cell: SubjectCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
            let subject = subjects?[indexPath.item]
            cell.setSubject(subject?.name ?? "")
            if indexPath == selectedSubjectIndexPath {
                cell.selectSubject()
            }
            return cell
        } else {
            let cell: AdsCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
            let advertisement = advertisements[indexPath.item]
            cell.configure(using: advertisement)
            return cell
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dotsIndicator.currentPage = Int(self.adsCollectionView.contentOffset.x) / Int(self.adsCollectionView.frame.width)
    }
}

// MARK: - Collection View Delegate

extension HomeTableViewHeader: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let subjectCell = collectionView.cellForItem(at: indexPath) as? SubjectCollectionViewCell {
            subjectCell.isSelected = true
        }
        if collectionView == subjectsCollectionView {
            delegate?.didSelectSubject(at: indexPath)
        }
    }
}

// MARK: - Collection View Delegate Flow Layout

extension HomeTableViewHeader: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == subjectsCollectionView {
            return subjects?[indexPath.item].name?.size() ?? .zero
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 15.0
    }
}

// MARK: - Search Bar Delegate

extension HomeTableViewHeader: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        delegate?.textDidChange(in: searchBar)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.textDidChange(in: searchBar)
    }
}
