// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol ProfileTableViewHeaderDelegate: AnyObject {
    func changeProfileImage()
}

struct ProfileHeaderModel {
    var imageURL: String?
    var name: String
    var type: String
}

class ProfileTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet private var profileImageView: UIImageView!
    @IBOutlet private var profileNameLabel: UILabel!
    @IBOutlet private var profileUserTypeLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private weak var delegate: ProfileTableViewHeaderDelegate?

    func configure(model: ProfileHeaderModel, delegate: ProfileTableViewHeaderDelegate?) {
        if model.imageURL == nil {
            activityIndicator.stopLoading()
            profileImageView.image = Images.defaultAvatar.image
        } else {
            guard var link = model.imageURL else { return }
            link = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            link = link.replacingOccurrences(of: "http", with: "https")
            let url = Environment.baseURL.appendingPathComponent(link)
            profileImageView.isHidden = true
            activityIndicator.startLoading()
            profileImageView.kf.setImage(with: url) { [weak self] _ in
                self?.activityIndicator.stopLoading()
                self?.profileImageView.isHidden = false
            }
        }
        profileNameLabel.text = model.name
        profileUserTypeLabel.text = model.type
        self.delegate = delegate
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar)))
    }

    @objc
    private func changeAvatar() {
        delegate?.changeProfileImage()
    }
}
