// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol ReceiptDoneButtonDelegate: AnyObject {
    func didTapDone()
}

class ReceiptView: UIView {
    // MARK: - IBOutlets

    @IBOutlet private var receiptNumberContainerView: UIView! {
        didSet {
            receiptNumberContainerView.addLineDashedStroke(pattern: [2, 2], radius: 10, colorAsset: Colors.darkGreyColor)
        }
    }
    @IBOutlet private var receiptNumberLabel: UILabel!
    @IBOutlet private var customerNameLabel: UILabel!
    @IBOutlet private var customerNameValueLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var addressValueLabel: UILabel!
    @IBOutlet private var courseLabel: UILabel!
    @IBOutlet private var courseNameValueLabel: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var teacherNameValueLabel: UILabel!
    @IBOutlet private var doneButton: UIButton! {
        didSet {
            doneButton.layer.cornerRadius = 5
        }
    }

    // MARK: - Public Properties

    internal weak var receiptDoneButtonDelegate: ReceiptDoneButtonDelegate?

    // MARK: - IBActions

    @IBAction private func didTapDone(_ sender: UIButton) {
        self.removeFromSuperview()
        receiptDoneButtonDelegate?.didTapDone()
    }

    // MARK: - Public Functions

    internal func configure(with receiptData: BookingCourseResponseModel) {
        receiptNumberLabel.text = receiptData.receiptNumber
        customerNameValueLabel.text = receiptData.studentName
        addressValueLabel.text = receiptData.address
        courseNameValueLabel.text = receiptData.courseName
        teacherNameValueLabel.text = receiptData.teacherName
    }
}
