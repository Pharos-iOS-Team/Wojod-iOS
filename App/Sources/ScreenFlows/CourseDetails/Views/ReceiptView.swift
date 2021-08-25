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
    @IBOutlet private var receiptNumberTitleLabel: UILabel! {
        didSet {
            receiptNumberTitleLabel.text = L10n.CourseDetails.Receipt.receiptNumber
        }
    }
    @IBOutlet private var customerNameLabel: UILabel! {
        didSet {
            customerNameLabel.text = L10n.CourseDetails.Receipt.customerName
        }
    }
    @IBOutlet private var customerNameValueLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel! {
        didSet {
            addressLabel.text = L10n.CourseDetails.Receipt.address
        }
    }
    @IBOutlet private var addressValueLabel: UILabel!
    @IBOutlet private var courseLabel: UILabel! {
        didSet {
            courseLabel.text = L10n.CourseDetails.Receipt.courseName
        }
    }
    @IBOutlet private var courseNameValueLabel: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel! {
        didSet {
            teacherNameLabel.text = L10n.CourseDetails.Receipt.teacherName
        }
    }
    @IBOutlet private var teacherNameValueLabel: UILabel!
    @IBOutlet private var doneButton: UIButton! {
        didSet {
            doneButton.setTitle(L10n.CourseDetails.Receipt.done)
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
        receiptNumberLabel.text = receiptData.receiptNumber?.dashed()
        customerNameValueLabel.text = receiptData.studentName
        addressValueLabel.text = receiptData.address
        courseNameValueLabel.text = receiptData.courseName
        teacherNameValueLabel.text = receiptData.teacherName
    }

    internal func configureInMyCourses(with receipt: Receipt) {
        receiptNumberLabel.text = receipt.receiptNumber?.dashed()
        customerNameValueLabel.text = receipt.studentName
        addressValueLabel.text = receipt.address
        courseNameValueLabel.text = receipt.courseName
        teacherNameValueLabel.text = receipt.teacherName
    }
}
