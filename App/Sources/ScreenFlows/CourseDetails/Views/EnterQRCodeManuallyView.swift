// Copyright © 2023 Pharos Solutions. All rights reserved.

import UIKit

class EnterQRCodeManuallyView: UIView {
    @IBOutlet private var messageTitleLabel: UILabel! {
        didSet {
            messageTitleLabel.text = L10n.CourseDetails.Main.bookByQR
        }
    }
    @IBOutlet private var messageDescriptionLabel: UILabel! {
        didSet {
            messageDescriptionLabel.text = L10n.CourseDetails.Main.codeManually
        }
    }
    @IBOutlet private var bookButton: UIButton! {
        didSet {
            bookButton.setTitle(L10n.CourseDetails.Main.bookNow)
        }
    }
    @IBOutlet private var returnButton: UIButton! {
        didSet {
            returnButton.setTitle(L10n.CourseDetails.CancelBooking.returnButton)
        }
    }
    @IBOutlet private var textField: UITextField! {
        didSet {
            textField.placeholder = L10n.CourseDetails.Main.qrCode
        }
    }

    var scanningCompletionHandler: ((_ codeString: String) -> Void)?
    var scanningDismissed: (() -> Void)?

    // MARK: - IBActions

    @IBAction private func didTapBookButton(_ sender: UIButton) {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        self.removeFromSuperview() 
        scanningCompletionHandler?(text)
    }

    @IBAction private func returnButton(_ sender: UIButton) {
        self.removeFromSuperview()
        self.scanningDismissed?()
    }
}
