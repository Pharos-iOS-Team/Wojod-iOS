// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol CancelBookingViewDelegate: AnyObject {
    func didTapCancelBooking()
    func didTapReturn()
}

class CancelBookingView: UIView {
    @IBOutlet private var messageTitleLabel: UILabel! {
        didSet {
            messageTitleLabel.text = L10n.CourseDetails.CancelBooking.messageTitle
        }
    }
    @IBOutlet private var messageBodyLabel: UILabel! {
        didSet {
            messageBodyLabel.text = L10n.CourseDetails.CancelBooking.message
        }
    }
    @IBOutlet private var cancelBookingButton: UIButton! {
        didSet {
            cancelBookingButton.setTitle(L10n.CourseDetails.CancelBooking.cancelButton)
        }
    }
    @IBOutlet private var returnButton: UIButton! {
        didSet {
            returnButton.setTitle(L10n.CourseDetails.CancelBooking.returnButton)
        }
    }

    // MARK: - Public Properties

    internal weak var delegate: CancelBookingViewDelegate?

    // MARK: - IBActions

    @IBAction private func didTapCancelBooking(_ sender: UIButton) {
        self.removeFromSuperview()
        delegate?.didTapCancelBooking()
    }

    @IBAction private func didTapReturn(_ sender: Any) {
        self.removeFromSuperview()
        delegate?.didTapReturn()
    }
}
