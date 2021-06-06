// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol ProfileTableViewHeaderDelegate: class {
    func changeProfileImage()
}

struct ProfileHeaderModel {
    var imageURL: URL
    var name: String
    var type: String
}

class ProfileTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet private var profileImageView: UIButton!
    @IBOutlet private var profileNameLabel: UILabel!
    @IBOutlet private var profileUserTypeLabel: UILabel!

    private weak var delegate: ProfileTableViewHeaderDelegate?

    func configure(model: ProfileHeaderModel, delegate: ProfileTableViewHeaderDelegate?) {
        profileImageView.kf.setImage(with: model.imageURL, for: .normal)
        profileNameLabel.text = model.name
        profileUserTypeLabel.text = model.type
        self.delegate = delegate
    }
    @IBAction private func avatarPressed(_ sender: Any) {
        delegate?.changeProfileImage()
    }
}
