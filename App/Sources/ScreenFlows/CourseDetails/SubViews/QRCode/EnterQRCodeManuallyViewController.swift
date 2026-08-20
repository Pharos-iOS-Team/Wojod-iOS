// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

class EnterQRCodeManuallyViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var messageTitleLabel: UILabel!
    @IBOutlet private var messageDescriptionLabel: UILabel!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var bookButton: UIButton!
    @IBOutlet private var returnButton: UIButton!

    // MARK: - Properties
    var scanningCompletionHandler: ((_ codeString: String) -> Void)?
    var scanningDismissed: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - IBActions
    @IBAction private func didTapBookButton(_ sender: UIButton) {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        self.dismiss(animated: true)
        self.scanningCompletionHandler?(text)
    }

    @IBAction private func didTapReturnButton(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.scanningDismissed?()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = UIConstants.cornerRadius
        containerView.addShadow()
        messageTitleLabel.text = L10n.CourseDetails.Main.bookByQR
        messageDescriptionLabel.text = L10n.CourseDetails.Main.codeManually
        bookButton.setTitle(L10n.CourseDetails.Main.bookNow, for: .normal)
        returnButton.setTitle(L10n.CourseDetails.CancelBooking.returnButton, for: .normal)
        textField.placeholder = L10n.CourseDetails.Main.qrCode
        bookButton.layer.cornerRadius = UIConstants.cornerRadius
    }
}
