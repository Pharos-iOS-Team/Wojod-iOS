// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AcademicInfoViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var schoolButton: UIButton!
    @IBOutlet private var universityButton: UIButton!
    @IBOutlet private var schoolLabel: UILabel! {
        didSet {
            schoolLabel.text = L10n.Signup.AcademicInfo.school
        }
    }
    @IBOutlet private var universityLabel: UILabel! {
        didSet {
            universityLabel.text = L10n.Signup.AcademicInfo.university
        }
    }
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }
    @IBOutlet private var academicInfoTitleImageView: UIImageView! {
        didSet {
            academicInfoTitleImageView.image = Images.academicInfoTitle
        }
    }
    @IBOutlet private var thirdMilestoneImageView: UIImageView! {
        didSet {
            thirdMilestoneImageView.image = Images.thirdMilestone
        }
    }

    // MARK: - Private Properties

    private var isSchoolChosen = Bool()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSemanticAttribute()
        configureDefaultSelection()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }

    @IBAction private func didTapOnSchool(_ sender: UIButton) {
        isSchoolChosen = true
        User.shared.isSchoolStudent = true
        configureSchoolView()
    }

    @IBAction private func didTapOnUniversity(_ sender: UIButton) {
        isSchoolChosen = false
        User.shared.isSchoolStudent = false
        configureUniversityView()
    }

    @IBAction private func didTapOnNext(_ sender: SendButton) {
        if isSchoolChosen {
            User.shared.divisionId = nil
            User.shared.divisionName = nil
            User.shared.batch = nil
            User.shared.batchName = nil
            User.shared.academicType = nil
            User.shared.academicTypeName = nil
            performSegue(withIdentifier: "segueToSchool", sender: sender)
        } else {
            User.shared.divisionId = nil
            User.shared.divisionName = nil
            User.shared.batch = nil
            User.shared.batchName = nil
            User.shared.academicType = nil
            User.shared.academicTypeName = nil
            performSegue(withIdentifier: "segueToUniversity", sender: sender)
        }
    }

    // MARK: - // Private Functions

    private func configureDefaultSelection() {
        isSchoolChosen = (User.shared.isSchoolStudent == nil ? true : User.shared.isSchoolStudent) ?? true
        isSchoolChosen ? configureSchoolView() : configureUniversityView()
    }

    private func configureUniversityView() {
        schoolButton.setImage(Images.girlAvatarFaded.image)
        universityButton.setImage(Images.boyAvatar.image)
    }

    private func configureSchoolView() {
        schoolButton.setImage(Images.girlAvatar.image)
        universityButton.setImage(Images.boyAvatarFaded.image)
    }
}
