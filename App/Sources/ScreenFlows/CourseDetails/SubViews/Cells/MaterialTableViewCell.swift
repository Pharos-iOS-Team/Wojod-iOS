// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

struct MaterialTableCellData {
    let title: String?
    let date: String?
    let image: UIImage
    var duration: Int?
}

class MaterialTableViewCell: UITableViewCell {
    @IBOutlet private var nextArrowIndicator: UIImageView! {
        didSet {
            nextArrowIndicator.image = Images.localizedNextArrowIndicator
        }
    }
    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.isHidden = true
        }
    }
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var videoDurationLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        videoDurationLabel.isHidden = true
    }
    func configure(with model: MaterialTableCellData) {
        selectionStyle = .none
        titleLabel.text = model.title
        dateLabel.text = model.date
        iconImageView.image = model.image
        setDuration(model.duration)
    }

    func startLoadingIndicator() {
        loadingIndicator.startAnimating()
    }

    func stopLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }
    
    private func setDuration(_ duration: Int?) {
        guard let duration = duration else { return }
        videoDurationLabel.isHidden = false
        videoDurationLabel.text = "\(L10n.Quizzes.duration) \(TimeInterval(duration).format() ?? "-")"
    }
}
