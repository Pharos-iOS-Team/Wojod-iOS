// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol CancelBookingViewDelegate: AnyObject {
    func didTapCancelBooking()
    func didTapReturn()
}

class CancelBookingView: UIView {
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
