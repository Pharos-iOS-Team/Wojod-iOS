// Copyright © 2021 Pharos Solutions. All rights reserved.

import Kingfisher
import UIKit

class AdsCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var viewMoreButton: UIButton! {
        didSet {
            viewMoreButton.layer.backgroundColor = Colors.sendButtonColor.color.withAlphaComponent(0.13).cgColor
            viewMoreButton.layer.cornerRadius = UIConstants.slightCornerRadius
            viewMoreButton.setTitle(L10n.Home.Ads.viewMore)
            viewMoreButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        }
    }

    // MARK: - Properties

    var advertisement: Advertisement?

    // MARK: - IBActions

    @IBAction private func didTapViewMore(_ sender: UIButton) {
        if let url = URL(string: advertisement?.mobileLink ?? "") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Public Functions

    func configure(using advertisement: Advertisement) {
        self.advertisement = advertisement
        titleLabel.text = advertisement.title
        descriptionLabel.text = advertisement.title
        if let url = URL(string: "\(Environment.baseURL)\(advertisement.media?.fileUrl ?? "")") {
            imageView.kf.setImage(with: url)
        }
    }
}
