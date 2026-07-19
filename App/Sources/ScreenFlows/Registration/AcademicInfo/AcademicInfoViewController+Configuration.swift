// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

extension AcademicInfoViewController {
    func configureNavigationBar() {
        let backButton = UIBarButtonItem(image: Images.localizedBackButton, style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    func configureInitialLayout() {
        viewModel.restoreInitialLayoutState()
        if !viewModel.hasChosenTrack {
            schoolContainerView.isHidden = true
            universityContainerView.isHidden = true
            schoolContainerViewHeightConstraint.constant = 0
            universityContainerViewHeightConstraint.constant = 0
            letsKnowMoreTitleImageView.isHidden = true
        } else {
            viewModel.academicTrack == .school ? configureSchoolView() : configureUniversityView()
            if viewModel.academicTrack == .school {
                schoolInfoVC?.restoreData()
                if viewModel.divisionsList.isEmpty { schoolInfoVC?.loadAcademicTypes() }
            } else if viewModel.hasChosenAcademicLevel {
                universityInfoVC?.showFieldsImmediately()
                if viewModel.universities.isEmpty {
                    universityInfoVC?.retrieveUniversities()
                } else {
                    universityInfoVC?.restoreData()
                }
            }
        }
    }

    func configureSchoolView() {
        schoolButton.setImage(Images.girlAvatar.image, for: .normal)
        universityButton.setImage(Images.boyAvatarFaded.image, for: .normal)
        schoolContainerView.isHidden = false
        universityContainerView.isHidden = true
        schoolContainerViewHeightConstraint.constant = 530
        universityContainerViewHeightConstraint.constant = 0
    }

    func configureUniversityView() {
        schoolButton.setImage(Images.girlAvatarFaded.image, for: .normal)
        universityButton.setImage(Images.boyAvatar.image, for: .normal)
        schoolContainerView.isHidden = true
        universityContainerView.isHidden = false
        schoolContainerViewHeightConstraint.constant = 0
        if viewModel.hasChosenAcademicLevel {
            universityContainerViewHeightConstraint.constant = viewModel.academicLevel == .graduate ? 286 : 336
            viewModel.academicLevel == .graduate ? universityInfoVC?.configureGraduateView() : universityInfoVC?.configureStudentView()
            universityInfoVC?.showFieldsImmediately()
        } else {
            universityContainerViewHeightConstraint.constant = 50
            universityInfoVC?.configureSubTabsUnselected()
            universityInfoVC?.hideFields()
        }
    }

    func animateButtonsToTop(completion: @escaping () -> Void) {
        letsKnowMoreTitleImageView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        } completion: { _ in completion() }
    }

    @objc
    private func handleBack() {
        saveStateToStore()
        viewModel.goBack(from: self)
    }

    func saveStateToStore() {
        if viewModel.academicTrack == .school {
            viewModel.saveStateToStore(schoolValues: schoolInfoVC?.collectValues())
        } else {
            viewModel.saveStateToStore()
        }
    }

    func updateNextButtonState() {
        let schoolValues = viewModel.academicTrack == .school ? schoolInfoVC?.collectValues() : nil
        let enabled = viewModel.isMandatoryFieldsFilled(schoolValues: schoolValues)
        nextButton.isEnabled = enabled
        nextButton.backgroundColor = enabled ? Colors.sendButtonColor.color : Colors.darkGreyColor.color
    }

    func showValidationErrors(_ errors: [RegistrationValidationError]) {
        if viewModel.academicTrack == .school {
            schoolInfoVC?.showValidationErrors(errors)
        } else {
            universityInfoVC?.showValidationErrors(errors)
        }
        showWrongCredentials()
    }

    func showWrongCredentials() {
        wrongCredentialsImageView.isHidden = false
        wrongCredentialsImageViewHeight.constant = 50.0
    }

    func hideWrongCredentials() {
        wrongCredentialsImageView.isHidden = true
        wrongCredentialsImageViewHeight.constant = 0
    }
}
