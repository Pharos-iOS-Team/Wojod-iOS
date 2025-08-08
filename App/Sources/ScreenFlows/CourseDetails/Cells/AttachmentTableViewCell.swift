// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AttachmentTableViewCell: UITableViewCell {
    @IBOutlet private var attachmentImageView: UIImageView!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var avaliabliltyLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        attachmentImageView.image = nil
        subtitleLabel.text = nil
        durationLabel.isHidden = true
        avaliabliltyLabel.isHidden = true
    }

    func setAttachmentImageView(_ image: UIImage) {
        attachmentImageView.image = image
    }

    func setSubtitleLabel(_ subtitle: String?) {
        subtitleLabel.text = subtitle
    }

    func setDuration(_ duration: Int?) {
        guard let duration = duration else { return }
        durationLabel.isHidden = false
        durationLabel.text = "\(L10n.Quizzes.duration) \(TimeInterval(duration).format() ?? "-")"
    }

    func setAvaliablity(_ daysRemaining: Int?) {
        guard let daysRemaining = daysRemaining else {
            avaliabliltyLabel.isHidden = true
            return
        }
        avaliabliltyLabel.isHidden = false
        let seperator = "|  "
        if daysRemaining > 0 {
            avaliabliltyLabel.text = seperator + L10n.CourseDetails.Main.avaliableFor(daysRemaining)
            avaliabliltyLabel.textColor = .darkGray
        } else {
            avaliabliltyLabel.text = seperator + L10n.CourseDetails.Main.noLongerAvaliable
            avaliabliltyLabel.textColor = .red
        }
    }
}
