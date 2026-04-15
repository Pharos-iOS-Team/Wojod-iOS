// Copyright © 2021 Pharos Solutions. All rights reserved.

// swiftlint:disable all

import UIKit
import AlamofireImage

protocol CommentAndImagesCellDelegate: AnyObject {
    func didTapCorrectionImage(imageView: UIImageView, image: UIImage)
}

class CommentAndImagesTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet private weak var imagesCollectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!

    // MARK: - Properties

    private weak var delegate: CommentAndImagesCellDelegate?
    private var correctionImages = [CorrectionImage]()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        titleLabel.text = L10n.Quizzes.questionComment

        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Asset.Colors.orange.color.cgColor.copy(alpha: 0.2)
        containerView.backgroundColor = Asset.Colors.orange.color.withAlphaComponent(0.2)
        containerView.clipsToBounds = true

        pageControl.currentPageIndicatorTintColor = Asset.Colors.orange.color
        pageControl.pageIndicatorTintColor = UIColor.systemGray4

        imagesCollectionView.backgroundColor = .clear
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        if let layout = imagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        imagesCollectionView.register(
            UINib(nibName: String(describing: CorrectionImageCollectionViewCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CorrectionImageCollectionViewCell.self)
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        correctionImages = []
        commentLabel.text = nil
        commentLabel.isHidden = false
        imagesCollectionView.isHidden = false
        pageControl.currentPage = 0
    }

    // MARK: - Configuration

    func configure(comment: String?, imageURLs: [CorrectionImage], delegate: CommentAndImagesCellDelegate?) {
        self.delegate = delegate
        self.correctionImages = imageURLs

        let hasComment = comment?.isEmpty == false
        commentLabel.text = comment
        commentLabel.isHidden = !hasComment

        let hasImages = !imageURLs.isEmpty
        imagesCollectionView.isHidden = !hasImages
        pageControl.isHidden = !hasImages
        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = 0

        imagesCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension CommentAndImagesTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return correctionImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CorrectionImageCollectionViewCell.self),
            for: indexPath
        ) as! CorrectionImageCollectionViewCell

        let item = correctionImages[indexPath.item]
        if let fileUrl = item.fileUrl,
           let url = URL(string: "\(AppEnvironment.baseURL)\(fileUrl)") {
            cell.imageView.af.setImage(withURL: url)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CommentAndImagesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        pageControl.currentPage = page
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CorrectionImageCollectionViewCell,
              let image = cell.imageView.image else { return }
        delegate?.didTapCorrectionImage(imageView: cell.imageView, image: image)
    }
}
