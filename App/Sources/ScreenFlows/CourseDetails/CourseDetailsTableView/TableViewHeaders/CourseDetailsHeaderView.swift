// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class CourseDetailsHeaderView: UITableViewHeaderFooterView {
    // MARK: - IBOutlets

    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var expandCollapseButton: UIButton!
    @IBOutlet private var lessonTitleLabel: UILabel!

    // MARK: - Public Properties

    internal var onCollapseExpand: ((Int) -> Void)?
    internal var isExpanded: Bool?

    // MARK: - IBActions

    @IBAction private func didTapOnCollapseExpandButton(_ sender: UIButton) {
        onCollapseExpand?(self.tag)
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

    internal func animateExpandCollapse(isExpanded: Bool) {
        let image = isExpanded ? Images.collapse.image : Images.expand.image
        UIView.transition(with: expandCollapseButton, duration: 0.3, options: .transitionCrossDissolve) {
            self.expandCollapseButton.setImage(image, for: .normal)
        }
    }

    internal func configureVisibilityOfExpandButton(state: CourseState?, doesContainAttachments: Bool) {
        expandCollapseButton.isHidden = state != .booked || !doesContainAttachments
    }

    func configure(_ model: LessonHeaderModel, onCollapseExpand: @escaping (Int) -> Void) {
        self.tag = model.section
        self.onCollapseExpand = onCollapseExpand
        lessonTitleLabel.text = model.lessonName
        numberLabel.text = "\(model.lessonNumber)"
        expandCollapseButton.tag = model.section
        expandCollapseButton.isHidden = model.reservationState != .booked || !model.doesContainAttachments
        if model.isLocked {
            expandCollapseButton.setImage(Images.lock.image)
        } else {
            expandCollapseButton.setImage(model.isExpanded ? Images.collapse.image : Images.expand.image)
        }
    }

    @objc
    private func didTapOnHeader() {
        onCollapseExpand?(self.tag)
    }
}
