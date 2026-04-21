// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

protocol FiltersDelegate: AnyObject {
    func didApplyFilters(_ selection: FilterSelection, courses: CoursesResponse?)
}

class FiltersViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var schoolButton: UIButton!
    @IBOutlet private var universityButton: UIButton!
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.semanticContentAttribute = Language.semanticContent
        }
    }
    @IBOutlet private var studentButton: UIButton! {
        didSet {
            studentButton.isHidden = true
            studentButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var graduatedButton: UIButton! {
        didSet {
            graduatedButton.isHidden = true
            graduatedButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var applyButton: UIButton!
    @IBOutlet private var studentLabel: UILabel! {
        didSet {
            studentLabel.text = L10n.Filters.school
        }
    }
    @IBOutlet private var universityLabel: UILabel! {
        didSet {
            universityLabel.text = L10n.Filters.university
        }
    }
    @IBOutlet private var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var headerView: UIView!

    // MARK: - Public Properties

    weak var delegate: FiltersDelegate?
    var currentSelection = FilterSelection() {
        didSet {
            filterState.currentSelection = currentSelection
        }
    }
    var viewModel: FiltersViewModel?

    var filterState = FilterCoordinator()
    var dataSource = FilterDataSource()

    var isApplyEnabled: Bool = false {
        didSet {
            configureApplyButton()
        }
    }

    private var universityButtonIsTapped: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FiltersViewModel()

        filterState.viewController = self
        filterState.tableView = tableView
        filterState.viewModel = viewModel
        filterState.currentSelection = currentSelection

        dataSource.coordinator = filterState

        configureSelectionOfAcademicLevel()
        configureTableView()
        configureTitles()
        handleAppSpecificFilters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterState.restoreSelection()
    }

    // MARK: - IBActions

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction private func didTapSchoolButton(_ sender: UIButton) {
        filterState.reset()
        selectSchool()
    }

    @IBAction private func didTapUniversityButton(_ sender: UIButton) {
        filterState.reset()
        isApplyEnabled = false
        selectUniversity()
        selectStudentInUniversity()
    }

    @IBAction private func didTapStudentButton(_ sender: UIButton) {
        filterState.reset()
        selectStudentInUniversity()
    }

    @IBAction private func didTapGraduatedButton(_ sender: UIButton) {
        filterState.reset()
        selectGraduatedInUniversity()
    }

    @IBAction private func didTapApplyButton(_ sender: UIButton) {
        let batchID = filterState.academicLevel == .schoolStudent ? filterState.selectedYear?.key : filterState.selectedAcademicYear?.key
        viewModel?.loadFilteredCourses(
            subjectID: filterState.selectedSubject?.id,
            batchID: batchID ?? 0,
            specializationID: filterState.selectedField?.key
        ) { courses in
            self.delegate?.didApplyFilters(self.filterState.currentSelection, courses: courses)
            self.dismiss(animated: true)
        }
    }

    // MARK: - Private Functions
    private func handleAppSpecificFilters() {
        guard AppEnvironment.shouldHideOrganization
        else { return }

        let division = Division(key: User.shared.divisionId, value: User.shared.divisionName)
        let specialization = Specialization(key: User.shared.specializationId, value: User.shared.specializationName)
        headerViewHeightConstraint.constant = 0
        headerView.isHidden = true

        filterState.currentSelection.academicLevel = .universityStudent
        filterState.academicLevel = .universityStudent
        filterState.currentSelection.academicDivision = division
        filterState.selectedDivision = division
        filterState.currentSelection.field = specialization
        filterState.selectedField = specialization
        filterState.universitySection = .academicYear
        filterState.universitySectionTitles = [L10n.Signup.School.academicYear]
        tableView.reloadData()
        fetchUniversities()
    }

    private func configureSelectionOfAcademicLevel() {
        switch filterState.currentSelection.academicLevel {
        case .universityStudent:
            selectUniversity()
            selectStudentInUniversity()
        case .schoolStudent:
            selectSchool()
        case .graduate:
            selectUniversity()
            selectGraduatedInUniversity()
        default:
            selectSchool()
        }
    }

    private func configureTableView() {
        tableView.dataSource = dataSource
        tableView.registerCell(ofType: FiltersTableViewCell.self)
    }

    private func configureTitles() {
        filterLabel.text = L10n.Filters.filters
        configureApplyButton()
    }

    private func configureApplyButton() {
        applyButton.setTitle(L10n.Filters.apply, for: .normal)
        applyButton.layer.cornerRadius = UIConstants.cornerRadius
        applyButton.setTitleColor(isApplyEnabled ? Colors.sendButtonColor.color : .systemGray, for: .normal)
        applyButton.isUserInteractionEnabled = isApplyEnabled
    }

    private func selectSchool() {
        isApplyEnabled = false
        filterState.academicLevel = .schoolStudent
        filterState.currentSelection.academicLevel = .schoolStudent
        schoolButton.setImage(Images.girlAvatar.image)
        universityButton.setImage(Images.boyAvatarFaded.image)
        studentButton.isHidden = true
        graduatedButton.isHidden = true
        fetchAcademicTypes()
    }

    private func selectUniversity() {
        universityButtonIsTapped = true
        schoolButton.setImage(Images.girlAvatarFaded.image)
        universityButton.setImage(Images.boyAvatar.image)
        studentButton.isHidden = false
        graduatedButton.isHidden = false
    }

    private func selectStudentInUniversity() {
        filterState.academicLevel = .universityStudent
        filterState.currentSelection.academicLevel = .universityStudent
        studentButton.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        studentButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        graduatedButton.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        graduatedButton.setTitleColor(.black, for: .normal)
        if universityButtonIsTapped {
            fetchUniversities()
            universityButtonIsTapped = false
        }
    }

    private func selectGraduatedInUniversity() {
        filterState.academicLevel = .graduate
        filterState.currentSelection.academicLevel = .graduate
        studentButton.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        studentButton.setTitleColor(.black, for: .normal)
        graduatedButton.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        graduatedButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        fetchUniversities()
    }

    private func fetchAcademicTypes() {
        viewModel?.loadAcademicTypes(for: filterState.academicLevel) { academicTypes in
            self.filterState.academicTypes = academicTypes ?? []
            self.tableView.reloadData()
        }
    }

    private func fetchUniversities() {
        viewModel?.loadAcademicDivisions(for: filterState.academicLevel, in: 0) { universities in
            self.filterState.universities = universities ?? []
            self.tableView.reloadData()
        }
    }
}
