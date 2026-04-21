// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

internal protocol CollapseExpandDelegate: AnyObject {
    func didTapOnCollapseExpand(in section: Int)
}

class CourseDetailsHeaderView: UITableViewHeaderFooterView {
    // MARK: - IBOutlets

    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var expandCollapseButton: UIButton!
    @IBOutlet private var lessonTitleLabel: UILabel!

    // MARK: - Public Properties

    internal weak var collapseExpandDelegate: CollapseExpandDelegate?
    internal var isExpanded: Bool?

    // MARK: - IBActions

    @IBAction private func didTapOnCollapseExpandButton(_ sender: UIButton) {
        collapseExpandDelegate?.didTapOnCollapseExpand(in: self.tag)
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnHeader)))
    }

    // MARK: - Public Functions

    internal func setNumberLabel(_ number: Int) {
        numberLabel.text = "\(number)"
    }

    internal func setLessonTitleLabel(_ title: String) {
        lessonTitleLabel.text = title
    }

    internal func assignSectionTagToButton(_ sectionNumber: Int) {
        expandCollapseButton.tag = sectionNumber
    }

    internal func setImageOfButton(_ image: UIImage) {
        expandCollapseButton.setImage(image)
    }

    internal func configureVisibilityOfExpandButton(state: CourseState?, doesContainAttachments: Bool) {
        expandCollapseButton.isHidden = state != .booked || !doesContainAttachments
    }

    @objc
    private func didTapOnHeader() {
        collapseExpandDelegate?.didTapOnCollapseExpand(in: self.tag)
    }
}
