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
    @IBOutlet private var profileImageView: UIButton!
    @IBOutlet private var profileNameLabel: UILabel!
    @IBOutlet private var profileUserTypeLabel: UILabel!

    private weak var delegate: ProfileTableViewHeaderDelegate?

    @IBAction private func avatarPressed(_ sender: Any) {
        delegate?.changeProfileImage()
    }

    func configure(model: ProfileHeaderModel, delegate: ProfileTableViewHeaderDelegate?) {
        if model.imageURL == nil {
            profileImageView.isHidden = true
        } else {
            guard var link = model.imageURL else { return }
            link = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            link = link.replacingOccurrences(of: "http", with: "https")
            let url = Environment.baseURL.appendingPathComponent(link)
            profileImageView.kf.setImage(with: url, for: .normal)
        }
        profileNameLabel.text = model.name
        profileUserTypeLabel.text = model.type
        self.delegate = delegate
    }
}
