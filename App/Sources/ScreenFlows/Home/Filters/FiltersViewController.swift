// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

protocol FiltersDelegate: AnyObject {
    func loadFilteredCourses(_ courses: ExploreMoreCoursesResponse?)
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
    @IBOutlet private var tableView: UITableView!
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
    @IBOutlet private var applyButton: UIButton!
    @IBOutlet private var studentButtonHeightConstraint: NSLayoutConstraint!

    // MARK: - Public Properties

    weak var delegate: FiltersDelegate?
    var schoolSectionTitles: [String] = ["Academic Type"]
    var universitySectionTitles: [String] = ["University"]
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FiltersViewModel()
        configureSelectionOfAcademicLevel()
        configureTableView()
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
        selectUniversity()
        selectStudentInUniversity()
    }

    @IBAction private func didTapStudentButton(_ sender: UIButton) {
        clearPreviouslyChosenFilters()
        selectStudentInUniversity()
    }

    @IBAction private func didTapGraduatedButton(_ sender: UIButton) {
        clearPreviouslyChosenFilters()
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

    private func selectSchool() {
        academicLevel = .schoolStudent
        Filters.shared.academicLevel = .schoolStudent
        schoolButton.setImage(Images.girlAvatar.image)
        universityButton.setImage(Images.boyAvatarFaded.image)
        studentButton.isHidden = true
        graduatedButton.isHidden = true
        studentButtonHeightConstraint.constant = 0
        fetchAcademicTypes()
    }

    private func selectUniversity() {
        schoolButton.setImage(Images.girlAvatarFaded.image)
        universityButton.setImage(Images.boyAvatar.image)
        studentButton.isHidden = false
        graduatedButton.isHidden = false
        studentButtonHeightConstraint.constant = 40
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
                            self.schoolSectionTitles.append("Academic Divisions")
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        }
                    }
                }
            case .academicDivision:
                cell.configure(title: "Academic Division", filters: divisions.compactMap { $0.value }, section: .academicDivision)
                if let division = Filters.shared.academicDivision, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: divisions.firstIndex { $0.key == division.key })
                    viewModel?.loadBatches(for: division.key ?? 0) { years in
                        self.years = years ?? []
                        if self.schoolSection == .academicDivision {
                            self.schoolSection = .academicYear
                            self.schoolSectionTitles.append("Academic Year")
                            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                        }
                    }
                }
            case .academicYear:
                cell.configure(title: "Academic Year", filters: years.compactMap { $0.value }, section: .academicYear)
                if let year = Filters.shared.academicYear, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: years.firstIndex { $0.key == year.key })
                    viewModel?.loadSubjects(forYear: year.key ?? 0) { subjects in
                        self.subjects = subjects.subjects ?? []
                        if self.schoolSection == .academicYear {
                            self.schoolSection = .subjects
                            self.schoolSectionTitles.append("Subject")
                            self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                        }
                    }
                }
            case .subjects:
                cell.configure(title: "Subject", filters: subjects.compactMap { $0.name }, section: .subjects)
                if let subject = Filters.shared.subject, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: subjects.firstIndex { $0.id == subject.id })
                }
            }
        } else {
            switch universitySection {
            case .university:
                cell.configureForUniveristy(title: "University", filters: universities.compactMap { $0.value }, section: .university)
                if let univeristy = Filters.shared.academicDivision, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: universities.firstIndex { $0.key == univeristy.key })
                    viewModel?.loadSpecializations(for: univeristy.key ?? 0) { fields in
                        self.fields = fields ?? []
                        if self.universitySection == .university {
                            self.universitySection = .field
                            self.universitySectionTitles.append("Field")
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        }
                    }
                }
            case .field:
                cell.configureForUniveristy(title: "Field", filters: fields.compactMap { $0.value }, section: .field)
                if let field = Filters.shared.field, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: fields.firstIndex { $0.key == field.key })
                    viewModel?.loadBatches(for: Filters.shared.academicDivision?.key ?? 0) { academicYears in
                        self.academicYears = academicYears ?? []
                        if self.universitySection == .field {
                            self.universitySection = .academicYear
                            self.universitySectionTitles.append("Academic Year")
                            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                        }
                    }
                }
            case .academicYear:
                cell.configureForUniveristy(title: "Academic Year", filters: academicYears.compactMap { $0.value }, section: .academicYear)
                if let academicYear = Filters.shared.academicYear, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: academicYears.firstIndex { $0.key == academicYear.key })
                    viewModel?.loadSubjects(forYear: academicYear.key ?? 0) { subjects in
                        self.universitySubjects = subjects.subjects ?? []
                        if self.universitySection == .academicYear {
                            self.universitySection = .subjects
                            self.universitySectionTitles.append("Subject")
                            self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                        }
                    }
                }
            case .subjects:
                cell.configureForUniveristy(title: "Subjects", filters: universitySubjects.compactMap { $0.name }, section: .subjects)
                if let subject = Filters.shared.subject, Filters.shared.isDataBeingRetrieved {
                    cell.selectOldEntry(for: universitySubjects.firstIndex { $0.id == subject.id })
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
                        if self.schoolSectionTitles.contains("Academic Divisions") {
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        } else {
                            self.schoolSectionTitles.append("Academic Divisions")
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
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
                        if self.schoolSectionTitles.contains("Academic Year") {
                            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                        } else {
                            self.schoolSectionTitles.append("Academic Year")
                            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
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
                        if self.schoolSectionTitles.contains("Subject") {
                            self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                        } else {
                            self.schoolSectionTitles.append("Subject")
                            self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
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
            selectedSubject = subjects[filterIndex]
            Filters.shared.subject = selectedSubject
        }
    }

    func didSelectFilterInUniversity(_ filterIndex: Int, in section: UniversitySection) {
        Filters.shared.isDataBeingRetrieved = false
        switch section {
        case .university:
            universitySection = .field
            if selectedUniversity == nil {
                selectedUniversity = universities[filterIndex]
                Filters.shared.academicDivision = selectedUniversity
                viewModel?.loadSpecializations(for: selectedUniversity?.key ?? 0) { fields in
                    self.tableView.performBatchUpdates {
                        self.fields = fields ?? []
                        if self.universitySectionTitles.contains("Field") {
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                        } else {
                            self.universitySectionTitles.append("Field")
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
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
                        if self.universitySectionTitles.contains("Academic Year") {
                            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                        } else {
                            self.universitySectionTitles.append("Academic Year")
                            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
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
                        if self.universitySectionTitles.contains("Subjects") {
                            self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                        } else {
                            self.universitySectionTitles.append("Subjects")
                            self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
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
            selectedSubject = universitySubjects[filterIndex]
            Filters.shared.subject = selectedSubject
        }
    }
}
