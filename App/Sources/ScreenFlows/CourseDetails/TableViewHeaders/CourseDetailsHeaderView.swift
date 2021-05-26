// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

internal protocol CollapseExpandDelegate: AnyObject {
    func didTapOnCollapseExpand()
}

class CourseDetailsHeaderView: UITableViewHeaderFooterView {
    // MARK: - Lifecycle

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - IBOutlets

    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var expandCollapseButton: UIButton!
    @IBOutlet private var lessonTitleLabel: UILabel!

    // MARK: - Public Properties

    internal weak var collapseExpandDelegate: CollapseExpandDelegate?

    // MARK: - IBActions

    @IBAction private func didTapOnCollapseExpandButton(_ sender: UIButton) {
        collapseExpandDelegate?.didTapOnCollapseExpand()
    }

    // MARK: - Public Functions

    internal func setNumberLabel(_ number: Int) {
        numberLabel.text = "\(number)"
    }

    internal func setLessonTitleLabel(_ title: String) {
        lessonTitleLabel.text = title
    }
}
