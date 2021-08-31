// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

protocol HomeTableViewHeaderDelegate: AnyObject {
    func didSelectRelatedCourses()
    func didSelectExploreMore()
    func didSelectSubject(in collectionView: UICollectionView, at indexPath: IndexPath)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    func textDidChange(in searchBar: UISearchBar)
}

class HomeTableViewHeader: UITableViewHeaderFooterView {
    // MARK: - Lifecycle

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - IBOutlets

    @IBOutlet private var subjectCollectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            subjectCollectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

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
    @IBOutlet private var adsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var subjectsCollectionViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties

    weak var delegate: HomeTableViewHeaderDelegate?
    var subjects: [Subject]?
    var advertisements: [Advertisement] = []
    var selectedSubjectIndexPath: IndexPath?
    private var isFirstLoad: Bool = true

    // MARK: - IBActions

    @IBAction private func didTapRelatedCourses(_ sender: UIButton) {
        selectRelatedCoursesButton()
        delegate?.didSelectRelatedCourses()
    }

    @IBAction private func didTapExploreMore(_ sender: UIButton) {
        selectExploreMoreButton()
        delegate?.didSelectExploreMore()
    }

    // MARK: - Functions

    func configureCollectionViews() {
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
        }
        subjectsCollectionView.register(UINib(nibName: "SubjectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubjectCollectionViewCell")
        adsCollectionView.register(UINib(nibName: "AdsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdsCollectionViewCell")
    }

    func configureSearchBar() {
        searchBar.delegate = self
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
        showSubjectsAndAds()
        relatedCoursesButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        relatedCoursesButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        exploreMoreButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        exploreMoreButton.setTitleColor(UIColor.black, for: .normal)
    }

    private func selectExploreMoreButton() {
        hideSubjectsAndAds()
        relatedCoursesButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        relatedCoursesButton.setTitleColor(UIColor.black, for: .normal)
        exploreMoreButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        exploreMoreButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
    }

    func showSubjectsAndAds() {
        subjectsCollectionView.isHidden = false
        adsCollectionView.isHidden = false
        subjectsCollectionViewHeightConstraint.constant = 50
        adsCollectionViewHeightConstraint.constant = 150
    }

    func hideSubjectsAndAds() {
        subjectsCollectionView.isHidden = true
        adsCollectionView.isHidden = true
        subjectsCollectionViewHeightConstraint.constant = 0
        adsCollectionViewHeightConstraint.constant = 0
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
            if isFirstLoad && !(subjects?.isEmpty ?? true) && indexPath.item == 0 {
                isFirstLoad = false
                cell.isSelected = true
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
        if collectionView == subjectsCollectionView {
            delegate?.didSelectSubject(in: collectionView, at: indexPath)
        }
    }
}

// MARK: - Collection View Delegate Flow Layout

extension HomeTableViewHeader: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == subjectsCollectionView {
            let label = UILabel(frame: CGRect.zero)
            label.text = subjects?[indexPath.item].name
            label.sizeToFit()
            return CGSize(width: label.frame.width, height: 50)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }
}

// MARK: - Search Bar Delegate

extension HomeTableViewHeader: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchBarSearchButtonClicked(searchBar)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.textDidChange(in: searchBar)
    }
}

class UICollectionViewLocalizableFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return Language.currentLanguage == .arabic
    }
}
