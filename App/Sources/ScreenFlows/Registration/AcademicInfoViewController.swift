// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AcademicInfoViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var schoolButton: UIButton!
    @IBOutlet private var universityButton: UIButton!

    // MARK: - Private Properties

    private var isSchoolChosen = Bool()

    // MARK: - IBActions

    @IBAction private func didTapOnSchool(_ sender: UIButton) {
        isSchoolChosen = true
        schoolButton.setImage(Images.girlAvatar.image)
        universityButton.setImage(Images.boyAvatarFaded.image)
    }
    @IBAction private func didTapOnUniversity(_ sender: UIButton) {
        isSchoolChosen = false
        schoolButton.setImage(Images.girlAvatarFaded.image)
        universityButton.setImage(Images.boyAvatar.image)
    }
    @IBAction private func didTapOnNext(_ sender: SendButton) {
        if isSchoolChosen {
            performSegue(withIdentifier: "segueToSchool", sender: sender)
        } else {
            performSegue(withIdentifier: "segueToUniversity", sender: sender)
        }
    }
}
