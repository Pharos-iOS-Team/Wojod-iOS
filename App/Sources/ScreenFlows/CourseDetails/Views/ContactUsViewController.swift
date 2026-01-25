// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

class ContactUsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descLabel: UILabel!
    @IBOutlet private var retrunBtn: UIButton!
    @IBOutlet private var containerView: UIView!

    // MARK: - Properties
    var contactInfo: String?
    var viewDismissed: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction private func returnButtonDidTapped(_ sender: Any) {
        self.dismiss(animated: true)
        self.viewDismissed?()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = UIConstants.cornerRadius
        containerView.addShadow()
        descLabel.text = contactInfo
        titleLabel.text = L10n.CourseDetails.Main.contactUs
        retrunBtn.setTitle(L10n.CourseDetails.CancelBooking.returnButton, for: .normal)
    }
}
