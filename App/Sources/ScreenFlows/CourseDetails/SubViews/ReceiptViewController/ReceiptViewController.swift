// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class ReceiptViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var receiptNumberContainerView: UIView!
    @IBOutlet private var receiptNumberLabel: UILabel!
    @IBOutlet private var receiptNumberTitleLabel: UILabel!
    @IBOutlet private var customerNameLabel: UILabel!
    @IBOutlet private var customerNameValueLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var addressValueLabel: UILabel!
    @IBOutlet private var courseLabel: UILabel!
    @IBOutlet private var courseNameValueLabel: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var teacherNameValueLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var priceValueLabel: UILabel!
    @IBOutlet private var doneButton: UIButton!

    // MARK: - Properties
    var receiptData: BookingCourseResponseModel?
    var myCourseReceipt: Receipt?
    var coursePrice: String?
    var onDone: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayData()
    }

    // MARK: - IBActions
    @IBAction private func didTapDone(_ sender: UIButton) {
        dismiss(animated: true)
        onDone?()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = UIConstants.cornerRadius
        containerView.addShadow()
        receiptNumberContainerView.addLineDashedStroke(pattern: [2, 2], radius: 10, colorAsset: Colors.darkGreyColor)

        receiptNumberTitleLabel.text = L10n.CourseDetails.Receipt.receiptNumber
        customerNameLabel.text = L10n.CourseDetails.Receipt.customerName
        addressLabel.text = L10n.CourseDetails.Receipt.address
        courseLabel.text = L10n.CourseDetails.Receipt.courseName
        teacherNameLabel.text = L10n.CourseDetails.Receipt.teacherName
        priceLabel.text = L10n.Home.Course.priceLabel
        doneButton.setTitle(L10n.CourseDetails.Receipt.done, for: .normal)
        doneButton.layer.cornerRadius = 5
    }

    private func displayData() {
        if let data = receiptData {
            receiptNumberLabel.text = data.receiptNumber?.dashed()
            customerNameValueLabel.text = data.studentName
            addressValueLabel.text = data.address
            courseNameValueLabel.text = data.courseName
            teacherNameValueLabel.text = data.teacherName
            priceValueLabel.text = formatPrice(coursePrice ?? "")
        } else if let receipt = myCourseReceipt {
            receiptNumberLabel.text = receipt.receiptNumber?.dashed()
            customerNameValueLabel.text = receipt.studentName
            addressValueLabel.text = receipt.address
            courseNameValueLabel.text = receipt.courseName
            teacherNameValueLabel.text = receipt.teacherName
            priceValueLabel.text = formatPrice(receipt.price ?? "")
        }
    }

    private func formatPrice(_ price: String) -> String {
        return price.isEmpty ? L10n.Home.Course.returnToTeacher : "\(price) \(L10n.Home.Course.price)"
    }
}
