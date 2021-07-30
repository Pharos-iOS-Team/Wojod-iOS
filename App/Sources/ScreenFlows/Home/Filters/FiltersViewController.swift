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
        selectSchool()
        configureTableView()
    }

    // MARK: - IBActions

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction private func didTapSchoolButton(_ sender: UIButton) {
        selectSchool()
    }

    @IBAction private func didTapUniversityButton(_ sender: UIButton) {
        selectUniversity()
        selectStudentInUniversity()
    }

    @IBAction private func didTapStudentButton(_ sender: UIButton) {
        selectStudentInUniversity()
        academicLevel = .universityStudent
        fetchUniversities()
    }

    @IBAction private func didTapGraduatedButton(_ sender: UIButton) {
        selectGraduatedInUniversity()
        academicLevel = .graduate
        fetchUniversities()
    }

    @IBAction private func didTapApplyButton(_ sender: UIButton) {
        let batchID = academicLevel == .schoolStudent ? selectedYear?.key : selectedAcademicYear?.key
        viewModel?.loadFilteredCourses(subjectID: selectedSubject?.id ?? 0, batchID: batchID ?? 0, specializationID: selectedField?.key) { courses in
            self.dismiss(animated: true) {
                self.delegate?.loadFilteredCourses(courses)
            }
        }
    }

    // MARK: - Private Functions

    private func configureTableView() {
        tableView.registerCell(ofType: FiltersTableViewCell.self)
        tableView.dataSource = self
    }

    private func selectSchool() {
        academicLevel = .schoolStudent
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
        studentButton.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        studentButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        graduatedButton.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        graduatedButton.setTitleColor(.black, for: .normal)
        fetchUniversities()
    }

    private func selectGraduatedInUniversity() {
        academicLevel = .graduate
        studentButton.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        studentButton.setTitleColor(.black, for: .normal)
        graduatedButton.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        graduatedButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
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
}

// MARK: - Table View Data Source

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  academicLevel == .schoolStudent ? schoolSectionTitles.count : universitySectionTitles.count
    }

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FiltersTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.selectionStyle = .none
        cell.academicLevel = academicLevel
        if academicLevel == .schoolStudent {
            switch schoolSection {
            case .academicType:
                cell.configure(title: schoolSectionTitles[indexPath.row], filters: academicTypes.compactMap { $0.value }, section: .academicType)
            case .academicDivision:
                cell.configure(title: "Academic Division", filters: divisions.compactMap { $0.value }, section: .academicDivision)
            case .academicYear:
                cell.configure(title: "Academic Year", filters: years.compactMap { $0.value }, section: .academicYear)
            case .subjects:
                cell.configure(title: "Subject", filters: subjects.compactMap { $0.name }, section: .subjects)
            }
        } else {
            switch universitySection {
            case .university:
                cell.configureForUniveristy(title: "University", filters: universities.compactMap { $0.value }, section: .university)
            case .field:
                cell.configureForUniveristy(title: "Field", filters: fields.compactMap { $0.value }, section: .field)
            case .academicYear:
                cell.configureForUniveristy(title: "Academic Year", filters: academicYears.compactMap { $0.value }, section: .academicYear)
            case .subjects:
                cell.configureForUniveristy(title: "Subjects", filters: universitySubjects.compactMap { $0.name }, section: .subjects)
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
        switch section {
        case .academicType:
            schoolSection = .academicDivision
            if selectedAcademicType == nil {
                selectedAcademicType = academicTypes[filterIndex]
                viewModel?.loadAcademicDivisions(for: academicLevel, in: selectedAcademicType?.key ?? 0) { divisions in
                    self.tableView.performBatchUpdates {
                        self.divisions = divisions ?? []
                        self.schoolSectionTitles.append("Academic Divisions")
                        self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    }
                }
            } else {
                selectedAcademicType = academicTypes[filterIndex]
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
                viewModel?.loadBatches(for: selectedDivision?.key ?? 0) { years in
                    self.tableView.performBatchUpdates {
                        self.years = years ?? []
                        self.schoolSectionTitles.append("Academic Year")
                        self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                    }
                }
            } else {
                selectedDivision = divisions[filterIndex]
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
                viewModel?.loadSubjects(forYear: selectedYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.subjects = subjects.subjects ?? []
                        self.schoolSectionTitles.append("Subject")
                        self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    }
                }
            } else {
                selectedYear = years[filterIndex]
                viewModel?.loadSubjects(forYear: selectedYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.subjects = subjects.subjects ?? []
                        self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    }
                }
            }

        case .subjects:
            selectedSubject = subjects[filterIndex]
        }
    }

    func didSelectFilterInUniversity(_ filterIndex: Int, in section: UniversitySection) {
        switch section {
        case .university:
            universitySection = .field
            if selectedUniversity == nil {
                selectedUniversity = universities[filterIndex]
                viewModel?.loadSpecializations(for: selectedUniversity?.key ?? 0) { fields in
                    self.tableView.performBatchUpdates {
                        self.fields = fields ?? []
                        self.universitySectionTitles.append("Field")
                        self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    }
                }
            } else {
                selectedUniversity = universities[filterIndex]
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
                viewModel?.loadBatches(for: selectedUniversity?.key ?? 0) { academicYears in
                    self.tableView.performBatchUpdates {
                        self.academicYears = academicYears ?? []
                        self.universitySectionTitles.append("Academic Year")
                        self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                    }
                }
            } else {
                selectedField = fields[filterIndex]
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
                viewModel?.loadSubjects(forYear: selectedAcademicYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.universitySubjects = subjects.subjects ?? []
                        self.universitySectionTitles.append("Subjects")
                        self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    }
                }
            } else {
                selectedAcademicYear = academicYears[filterIndex]
                viewModel?.loadSubjects(forYear: selectedAcademicYear?.key ?? 0) { subjects in
                    self.tableView.performBatchUpdates {
                        self.universitySubjects = subjects.subjects ?? []
                        self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    }
                }
            }

        case .subjects:
            selectedSubject = universitySubjects[filterIndex]
        }
    }
}
