// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

protocol FiltersDelegate: AnyObject {
    func loadFilteredCourses(_ courses: CoursesResponse?)
}

enum SchoolSection {
    case academicType
    case academicDivision
    case academicYear
    case subjects
}

enum UniversitySection {
    case university
    case field
    case academicYear
    case subjects
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
    var schoolSectionTitles: [String] = [L10n.Profile.academicType]
    var universitySectionTitles: [String] = [L10n.Filters.university]
    var viewModel: FiltersViewModel?
    var academicLevel: AcademicLevel = .schoolStudent
    var academicTypes: [KeyValue] = []
    var selectedAcademicType: KeyValue?
    var schoolSection: SchoolSection = .academicType
    var divisions: [Division] = []
    var selectedDivision: Division?
    var years: [Batch] = []
    var selectedYear: Batch?
    var subjects: [Subject] = []
    var universities: [Division] = []
    var universitySection: UniversitySection = .university
    var selectedUniversity: Division?
    var fields: [Specialization] = []
    var academicYears: [Batch] = []
    var selectedAcademicYear: Batch?
    var universitySubjects: [Subject] = []
    var selectedField: Specialization?
    var selectedSubject: Subject?
    var shouldApplyButtonBeUnabled = false {
        didSet {
            configureApplyButton()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FiltersViewModel()
        configureSelectionOfAcademicLevel()
        configureTableView()
        configureTitles()
        handleAppSpecificFilters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Filters.shared.isDataBeingRetrieved = true
    }

    // MARK: - IBActions

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction private func didTapSchoolButton(_ sender: UIButton) {
        clearPreviouslyChosenFilters()
        selectSchool()
    }

    @IBAction private func didTapUniversityButton(_ sender: UIButton) {
        clearPreviouslyChosenFilters()
        shouldApplyButtonBeUnabled = false
        selectUniversity()
        selectStudentInUniversity()
    }

    @IBAction private func didTapStudentButton(_ sender: UIButton) {
        resetTitles()
        selectStudentInUniversity()
    }

    @IBAction private func didTapGraduatedButton(_ sender: UIButton) {
        resetTitles()
        selectGraduatedInUniversity()
    }

    @IBAction private func didTapApplyButton(_ sender: UIButton) {
        let batchID = academicLevel == .schoolStudent ? selectedYear?.key : selectedAcademicYear?.key
        viewModel?.loadFilteredCourses(subjectID: selectedSubject?.id, batchID: batchID ?? 0, specializationID: selectedField?.key) { courses in
            self.dismiss(animated: true) {
                self.delegate?.loadFilteredCourses(courses)
            }
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

        Filters.shared.academicLevel = .universityStudent
        academicLevel = .universityStudent
        Filters.shared.academicDivision = division
        selectedDivision = division
        Filters.shared.field = specialization
        selectedField = specialization
        universitySection = .academicYear
        universitySectionTitles = [L10n.Signup.School.academicYear]

        viewModel?.loadBatches(for: selectedDivision?.key ?? 0) { years in
            self.academicYears = years ?? []
            self.tableView.reloadData()
        }
    }

    private func configureSelectionOfAcademicLevel() {
        switch Filters.shared.academicLevel {
        case .universityStudent:
            selectUniversity()
            selectStudentInUniversity()
        case .graduate:
            selectUniversity()
            selectGraduatedInUniversity()
        default:
            selectSchool()
        }
    }

    private func configureTableView() {
        tableView.registerCell(ofType: FiltersTableViewCell.self)
        tableView.dataSource = self
    }

    private func configureApplyButton() {
        if shouldApplyButtonBeUnabled {
            applyButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
            applyButton.isEnabled = true
        } else {
            applyButton.setTitleColor(Colors.darkGreyColor.color, for: .disabled)
            applyButton.isEnabled = false
        }
    }

    private func configureTitles() {
        applyButton.setTitle(L10n.Filters.apply)
        filterLabel.text = L10n.Filters.filters
    }

    private func selectSchool() {
        shouldApplyButtonBeUnabled = false
        academicLevel = .schoolStudent
        Filters.shared.academicLevel = .schoolStudent
        schoolButton.setImage(Images.girlAvatar.image)
        universityButton.setImage(Images.boyAvatarFaded.image)
        studentButton.isHidden = true
        graduatedButton.isHidden = true
        headerViewHeightConstraint.constant -= 40
        fetchAcademicTypes()
    }

    private func selectUniversity() {
        shouldApplyButtonBeUnabled = false
        schoolButton.setImage(Images.girlAvatarFaded.image)
        universityButton.setImage(Images.boyAvatar.image)
        studentButton.isHidden = false
        graduatedButton.isHidden = false
        headerViewHeightConstraint.constant += 40
    }

    private func selectStudentInUniversity() {
        academicLevel = .universityStudent
        Filters.shared.academicLevel = .universityStudent
        studentButton.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        studentButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        graduatedButton.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        graduatedButton.setTitleColor(.black, for: .normal)
        fetchUniversities()
    }

    private func selectGraduatedInUniversity() {
        academicLevel = .graduate
        Filters.shared.academicLevel = .graduate
        studentButton.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        studentButton.setTitleColor(.black, for: .normal)
        graduatedButton.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        graduatedButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        fetchUniversities()
    }

    private func fetchAcademicTypes() {
        viewModel?.loadAcademicTypes(for: academicLevel) { academicTypes in
            self.academicTypes = academicTypes ?? []
            self.tableView.reloadData()
        }
    }

    private func fetchUniversities() {
        viewModel?.loadAcademicDivisions(for: academicLevel, in: 0) { universities in
            self.universities = universities ?? []
            self.tableView.reloadData()
        }
    }

    private func clearPreviouslyChosenFilters() {
        Filters.shared.academicLevel = nil
        Filters.shared.academicType = nil
        Filters.shared.academicDivision = nil
        Filters.shared.academicYear = nil
        Filters.shared.field = nil
        Filters.shared.subject = nil
        selectedUniversity = nil
        selectedYear = nil
        selectedDivision = nil
        selectedField = nil
        selectedAcademicYear = nil
        selectedAcademicType = nil
        selectedSubject = nil
    }

    private func resetTitles() {
        clearPreviouslyChosenFilters()
        shouldApplyButtonBeUnabled = false
        universitySection = .university
        schoolSection = .academicType
        universitySectionTitles = [L10n.Filters.university]
        schoolSectionTitles = [L10n.Profile.academicType]
    }
}

// MARK: - Table View Data Source

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  academicLevel == .schoolStudent ? schoolSectionTitles.count : universitySectionTitles.count
    }

    // swiftlint:disable all
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FiltersTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.selectionStyle = .none
        cell.academicLevel = academicLevel
        if academicLevel == .schoolStudent {
            switch schoolSection {
            case .academicType:
                cell.configure(title: schoolSectionTitles[indexPath.row], filters: academicTypes.compactMap { $0.value }, section: .academicType)
                if let academicType = Filters.shared.academicType, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: academicTypes.firstIndex { $0.key == academicType.key })
                    viewModel?.loadAcademicDivisions(for: academicLevel, in: selectedAcademicType?.key ?? 0) { divisions in
                        self.divisions = divisions ?? []
                        if self.schoolSection == .academicType {
                            self.schoolSection = .academicDivision
                            self.schoolSectionTitles.append(L10n.Signup.School.academicDivision)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            case .academicDivision:
                cell.configure(title: L10n.Signup.School.academicDivision, filters: divisions.compactMap { $0.value }, section: .academicDivision)
                if let division = Filters.shared.academicDivision, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: divisions.firstIndex { $0.key == division.key })
                    viewModel?.loadBatches(for: division.key ?? 0) { years in
                        self.years = years ?? []
                        if self.schoolSection == .academicDivision {
                            self.schoolSection = .academicYear
                            self.schoolSectionTitles.append(L10n.Signup.School.academicYear)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            case .academicYear:
                cell.configure(title: L10n.Signup.School.academicYear, filters: years.compactMap { $0.value }, section: .academicYear)
                if let year = Filters.shared.academicYear, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: years.firstIndex { $0.key == year.key })
                    viewModel?.loadSubjects(forYear: year.key ?? 0) { subjects in
                        self.subjects = subjects.subjects ?? []
                        if self.schoolSection == .academicYear {
                            self.schoolSection = .subjects
                            self.schoolSectionTitles.append(L10n.Filters.subject)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            case .subjects:
                cell.configure(title: L10n.Filters.subject, filters: subjects.compactMap { $0.name }, section: .subjects)
                if let subject = Filters.shared.subject, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: subjects.firstIndex { $0.id == subject.id })
                }
            }
        } else {
            if AppEnvironment.shouldHideOrganization {
                switch universitySection {
                case .academicYear:
                    cell.configureForUniveristy(title: L10n.Signup.School.academicYear,
                                                filters: academicYears.compactMap { $0.value },
                                                section: .academicYear)
                    if let academicYear = Filters.shared.academicYear, Filters.shared.isDataBeingRetrieved {
                        cell.selectOldEntry(for: academicYears.firstIndex { $0.key == academicYear.key })
                    }
                    
                case .subjects:
                    cell.configureForUniveristy(title: L10n.Filters.subject,
                                                filters: universitySubjects.compactMap { $0.name },
                                                section: .subjects)
                    if let subject = Filters.shared.subject, Filters.shared.isDataBeingRetrieved {
                        cell.selectOldEntry(for: universitySubjects.firstIndex { $0.id == subject.id })
                    }
                    
                default:
                    cell.configure(title: "", filters: [], section: .academicType)
                }
            } else {
                switch universitySection {
                case .university:
                    cell.configureForUniveristy(title: L10n.Filters.university, filters: universities.compactMap { $0.value }, section: .university)
                    if let univeristy = Filters.shared.academicDivision, Filters.shared.isDataBeingRetrieved {
                        cell.selectOldEntry(for: universities.firstIndex { $0.key == univeristy.key })
                        viewModel?.loadSpecializations(for: univeristy.key ?? 0) { fields in
                            self.fields = fields ?? []
                            if self.universitySection == .university {
                                self.universitySection = .field
                                self.universitySectionTitles.append(L10n.Signup.School.field)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                case .field:
                    cell.configureForUniveristy(title: L10n.Signup.School.field, filters: fields.compactMap { $0.value }, section: .field)
                    if let field = Filters.shared.field, Filters.shared.isDataBeingRetrieved {
                        cell.selectOldEntry(for: fields.firstIndex { $0.key == field.key })
                        viewModel?.loadBatches(for: Filters.shared.academicDivision?.key ?? 0) { academicYears in
                            self.academicYears = academicYears ?? []
                            if self.universitySection == .field {
                                self.universitySection = .academicYear
                                self.universitySectionTitles.append(L10n.Signup.School.academicYear)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                case .academicYear:
                    cell.configureForUniveristy(title: L10n.Signup.School.academicYear, filters: academicYears.compactMap { $0.value }, section: .academicYear)
                    if let academicYear = Filters.shared.academicYear, Filters.shared.isDataBeingRetrieved {
                        cell.selectOldEntry(for: academicYears.firstIndex { $0.key == academicYear.key })
                        viewModel?.loadSubjects(forYear: academicYear.key ?? 0) { subjects in
                            self.universitySubjects = subjects.subjects ?? []
                            if self.universitySection == .academicYear {
                                self.universitySection = .subjects
                                self.universitySectionTitles.append(L10n.Filters.subject)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                case .subjects:
                    cell.configureForUniveristy(title: L10n.Filters.subject, filters: universitySubjects.compactMap { $0.name }, section: .subjects)
                    if let subject = Filters.shared.subject, Filters.shared.isDataBeingRetrieved {
                        cell.selectOldEntry(for: universitySubjects.firstIndex { $0.id == subject.id })
                    }
                }
            }
        }

        cell.delegate = self
        return cell
    }
}

// MARK: - Selecting Filter Delegate

extension FiltersViewController: SelectingFilterDelegate {
    // swiftlint:disable function_body_length
    func didSelectFilter(_ filterIndex: Int, in section: SchoolSection) {
        Filters.shared.isDataBeingRetrieved = false
        switch section {
        case .academicType:
            schoolSection = .academicDivision
            if selectedAcademicType == nil {
                selectedAcademicType = academicTypes[filterIndex]
                Filters.shared.academicType = selectedAcademicType
                viewModel?.loadAcademicDivisions(for: academicLevel, in: selectedAcademicType?.key ?? 0) { divisions in
                    self.tableView.performBatchUpdates {
                        self.divisions = divisions ?? []
                        if self.schoolSectionTitles.contains(L10n.Signup.School.academicDivision) {
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        } else {
                            self.schoolSectionTitles.append(L10n.Signup.School.academicDivision)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            } else {
                selectedAcademicType = academicTypes[filterIndex]
                Filters.shared.academicType = selectedAcademicType
                viewModel?.loadAcademicDivisions(for: academicLevel, in: selectedAcademicType?.key ?? 0) { divisions in
                    self.tableView.performBatchUpdates {
                        self.divisions = divisions ?? []
                        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    }
                }
            }

        case .academicDivision:
            schoolSection = .academicYear
            if selectedDivision == nil {
                selectedDivision = divisions[filterIndex]
                Filters.shared.academicDivision = selectedDivision
                viewModel?.loadBatches(for: selectedDivision?.key ?? 0) { years in
                    self.tableView.performBatchUpdates {
                        self.years = years ?? []
                        if self.schoolSectionTitles.contains(L10n.Signup.School.academicYear) {
                            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                        } else {
                            self.schoolSectionTitles.append(L10n.Signup.School.academicYear)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            } else {
                selectedDivision = divisions[filterIndex]
                Filters.shared.academicDivision = selectedDivision
                viewModel?.loadBatches(for: selectedDivision?.key ?? 0) { years in
                    self.tableView.performBatchUpdates {
                        self.years = years ?? []
                        self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                    }
                }
            }

        case .academicYear:
            schoolSection = .subjects
            if selectedYear == nil {
                selectedYear = years[filterIndex]
                Filters.shared.academicYear = selectedYear
                viewModel?.loadSubjects(forYear: selectedYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.subjects = subjects.subjects ?? []
                        if self.schoolSectionTitles.contains(L10n.Filters.subject) {
                            self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                        } else {
                            self.schoolSectionTitles.append(L10n.Filters.subject)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            } else {
                selectedYear = years[filterIndex]
                Filters.shared.academicYear = selectedYear
                viewModel?.loadSubjects(forYear: selectedYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.subjects = subjects.subjects ?? []
                        self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    }
                }
            }

        case .subjects:
            shouldApplyButtonBeUnabled = true
            selectedSubject = subjects[filterIndex]
            Filters.shared.subject = selectedSubject
        }
    }

    func didSelectFilterInUniversity(_ filterIndex: Int, in section: UniversitySection) {
        Filters.shared.isDataBeingRetrieved = false
        
        if AppEnvironment.shouldHideOrganization {
            switch section {
            case .academicYear:
                universitySection = .subjects
                selectedAcademicYear = academicYears[filterIndex]
                Filters.shared.academicYear = selectedAcademicYear

                viewModel?.loadSubjects(forYear: selectedAcademicYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.universitySubjects = subjects.subjects ?? []
                        if self.universitySectionTitles.contains(L10n.Filters.subject) {
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        } else {
                            self.universitySectionTitles.append(L10n.Filters.subject)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
                
            case .subjects:
                shouldApplyButtonBeUnabled = true
                selectedSubject = universitySubjects[filterIndex]
                Filters.shared.subject = selectedSubject
                
            default:
                break
            }
        } else {
            switch section {
            case .university:
                universitySection = .field
                if selectedUniversity == nil {
                    selectedUniversity = universities[filterIndex]
                    Filters.shared.academicDivision = selectedUniversity
                    viewModel?.loadSpecializations(for: selectedUniversity?.key ?? 0) { fields in
                        self.tableView.performBatchUpdates {
                            self.fields = fields ?? []
                            if self.universitySectionTitles.contains(L10n.Signup.School.field) {
                                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                            } else {
                                self.universitySectionTitles.append(L10n.Signup.School.field)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                } else {
                    selectedUniversity = universities[filterIndex]
                    Filters.shared.academicDivision = selectedUniversity
                    viewModel?.loadSpecializations(for: selectedUniversity?.key ?? 0) { fields in
                        self.tableView.performBatchUpdates {
                            self.fields = fields ?? []
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        }
                    }
                }
                
            case .field:
                universitySection = .academicYear
                if selectedField == nil {
                    selectedField = fields[filterIndex]
                    Filters.shared.field = selectedField
                    viewModel?.loadBatches(for: selectedUniversity?.key ?? 0) { academicYears in
                        self.tableView.performBatchUpdates {
                            self.academicYears = academicYears ?? []
                            if self.universitySectionTitles.contains(L10n.Signup.School.academicYear) {
                                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                            } else {
                                self.universitySectionTitles.append(L10n.Signup.School.academicYear)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                } else {
                    selectedField = fields[filterIndex]
                    Filters.shared.field = selectedField
                    viewModel?.loadBatches(for: selectedUniversity?.key ?? 0) { academicYears in
                        self.tableView.performBatchUpdates {
                            self.academicYears = academicYears ?? []
                            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                        }
                    }
                }
                
            case .academicYear:
                universitySection = .subjects
                if selectedAcademicYear == nil {
                    selectedAcademicYear = academicYears[filterIndex]
                    Filters.shared.academicYear = selectedAcademicYear
                    viewModel?.loadSubjects(forYear: selectedAcademicYear?.key ?? 0) { subjects in
                        self.tableView.performBatchUpdates {
                            self.universitySubjects = subjects.subjects ?? []
                            if self.universitySectionTitles.contains(L10n.Filters.subject) {
                                self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                            } else {
                                self.universitySectionTitles.append(L10n.Filters.subject)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                } else {
                    selectedAcademicYear = academicYears[filterIndex]
                    Filters.shared.academicYear = selectedAcademicYear
                    viewModel?.loadSubjects(forYear: selectedAcademicYear?.key ?? 0) { subjects in
                        self.tableView.performBatchUpdates {
                            self.universitySubjects = subjects.subjects ?? []
                            self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                        }
                    }
                }
                
            case .subjects:
                shouldApplyButtonBeUnabled = true
                selectedSubject = universitySubjects[filterIndex]
                Filters.shared.subject = selectedSubject
            }
        }
    }
}
