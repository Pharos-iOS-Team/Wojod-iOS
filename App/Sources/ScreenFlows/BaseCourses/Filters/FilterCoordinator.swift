// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

class FilterCoordinator: NSObject, SelectingFilterDelegate {
    weak var viewController: FiltersViewController?
    weak var tableView: UITableView?
    weak var viewModel: FiltersViewModel?

    var currentSelection = FilterSelection()
    var schoolSectionTitles: [String] = [L10n.Profile.academicType]
    var universitySectionTitles: [String] = [L10n.Filters.university]
    var academicLevel: AcademicLevel = .schoolStudent
    var academicTypes: [KeyValue] = []
    var schoolSection: SchoolSection = .academicType
    var divisions: [Division] = []
    var years: [Batch] = []
    var subjects: [Subject] = []
    var universities: [Division] = []
    var universitySection: UniversitySection = .university
    var fields: [Specialization] = []
    var academicYears: [Batch] = []
    var universitySubjects: [Subject] = []

    var isLoadingData: Bool = false

    var isApplyEnabled: Bool = false {
        didSet {
            viewController?.isApplyEnabled = isApplyEnabled
        }
    }

    func clearSelections() {
        currentSelection.reset()
    }

    func reset() {
        let rowsBeforeReset = academicLevel == .schoolStudent ? schoolSectionTitles.count : universitySectionTitles.count
        clearSelections()
        isApplyEnabled = false
        universitySection = .university
        schoolSection = .academicType
        tableView?.performBatchUpdates({
            self.universitySectionTitles = [L10n.Filters.university]
            self.schoolSectionTitles = [L10n.Profile.academicType]
            if rowsBeforeReset > 1 {
                let indexPathsToDelete = (1 ..< rowsBeforeReset).map { IndexPath(row: $0, section: 0) }
                self.tableView?.deleteRows(at: indexPathsToDelete, with: .fade)
            }
            self.tableView?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }, completion: nil)
    }

    // MARK: - Restore

    func restoreSelection() {
        if academicLevel == .schoolStudent {
            restoreSchoolCascade()
        } else if AppEnvironment.shouldHideOrganization {
            restoreHiddenOrgCascade()
        } else {
            restoreUniversityCascade()
        }
    }

    private func restoreSchoolCascade() {
        guard currentSelection.academicType != nil else { return }
        viewModel?.loadAcademicDivisions(for: academicLevel, in: currentSelection.academicType?.key ?? 0) { [weak self] divisions in
            guard let self = self else { return }
            self.divisions = divisions ?? []
            self.schoolSection = .academicDivision
            self.insertRow(title: L10n.Signup.School.academicDivision, into: \.schoolSectionTitles, at: 1)
            guard let divisionKey = self.currentSelection.academicDivision?.key else { return }
            self.viewModel?.loadBatches(for: divisionKey) { [weak self] years in
                guard let self = self else { return }
                self.years = years ?? []
                self.schoolSection = .academicYear
                self.insertRow(title: L10n.Signup.School.academicYear, into: \.schoolSectionTitles, at: 2)
                guard let yearKey = self.currentSelection.academicYear?.key else { return }
                self.viewModel?.loadSubjects(forYear: yearKey) { [weak self] subjects in
                    guard let self = self else { return }
                    self.subjects = subjects.subjects ?? []
                    self.schoolSection = .subjects
                    self.insertRow(title: L10n.Filters.subject, into: \.schoolSectionTitles, at: 3)
                }
            }
        }
    }

    private func restoreHiddenOrgCascade() {
        guard let yearKey = currentSelection.academicYear?.key else { return }
        viewModel?.loadSubjects(forYear: yearKey) { [weak self] subjects in
            guard let self = self else { return }
            self.universitySubjects = subjects.subjects ?? []
            self.universitySection = .subjects
            self.insertRow(title: L10n.Filters.subject, into: \.universitySectionTitles, at: 1)
        }
    }

    private func restoreUniversityCascade() {
        guard currentSelection.academicDivision != nil else { return }
        viewModel?.loadSpecializations(for: currentSelection.academicDivision?.key ?? 0) { [weak self] fields in
            guard let self = self else { return }
            self.fields = fields ?? []
            self.universitySection = .field
            self.insertRow(title: L10n.Signup.School.field, into: \.universitySectionTitles, at: 1)
            guard let universityKey = self.currentSelection.academicDivision?.key else { return }
            self.viewModel?.loadBatches(for: universityKey) { [weak self] academicYears in
                guard let self = self else { return }
                self.academicYears = academicYears ?? []
                self.universitySection = .academicYear
                self.insertRow(title: L10n.Signup.School.academicYear, into: \.universitySectionTitles, at: 2)
                guard let yearKey = self.currentSelection.academicYear?.key else { return }
                self.viewModel?.loadSubjects(forYear: yearKey) { [weak self] subjects in
                    guard let self = self else { return }
                    self.universitySubjects = subjects.subjects ?? []
                    self.universitySection = .subjects
                    self.insertRow(title: L10n.Filters.subject, into: \.universitySectionTitles, at: 3)
                }
            }
        }
    }

    // MARK: - Helpers

    private func showLoading(on row: Int) {
        (tableView?.cellForRow(at: IndexPath(row: row, section: 0)) as? FiltersTableViewCell)?.setIsLoading(true)
    }

    private func removeRows(from keyPath: ReferenceWritableKeyPath<FilterCoordinator, [String]>, startingAt index: Int) {
        let count = self[keyPath: keyPath].count
        guard count > index else { return }
        let paths = (index ..< count).map { IndexPath(row: $0, section: 0) }
        self[keyPath: keyPath].removeSubrange(index ..< count)
        tableView?.deleteRows(at: paths, with: .fade)
    }

    private func insertRow(title: String, into keyPath: ReferenceWritableKeyPath<FilterCoordinator, [String]>, at row: Int) {
        if row > 0 {
            (tableView?.cellForRow(at: IndexPath(row: row - 1, section: 0)) as? FiltersTableViewCell)?.setIsLoading(false)
        }
        self[keyPath: keyPath].append(title)
        tableView?.performBatchUpdates {
            self.tableView?.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
    }

    // MARK: - SelectingFilterDelegate

    func selectSchoolFilter(_ filterIndex: Int, in section: SchoolSection) {
        switch section {
        case .academicType:
            selectAcademicType(filterIndex)
        case .academicDivision:
            selectAcademicDivision(filterIndex)
        case .academicYear:
            selectSchoolYear(filterIndex)
        case .subjects:
            selectSchoolSubject(filterIndex)
        }
    }

    func selectUniversityFilter(_ filterIndex: Int, in section: UniversitySection) {
        if AppEnvironment.shouldHideOrganization {
            switch section {
            case .academicYear:
                selectHiddenOrgYear(filterIndex)
            case .subjects:
                selectHiddenOrgSubject(filterIndex)
            default:
                return
            }
        } else {
            switch section {
            case .university:
                selectUniversity(filterIndex)
            case .field:
                selectField(filterIndex)
            case .academicYear:
                selectUniversityYear(filterIndex)
            case .subjects:
                selectUniversitySubject(filterIndex)
            }
        }
    }

    // MARK: - School filter steps

    private func selectAcademicType(_ filterIndex: Int) {
        schoolSection = .academicDivision
        currentSelection.academicDivision = nil
        currentSelection.academicYear = nil
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.schoolSectionTitles, startingAt: 1)
        showLoading(on: 0)
        currentSelection.academicType = academicTypes[filterIndex]
        viewModel?.loadAcademicDivisions(for: academicLevel, in: currentSelection.academicType?.key ?? 0) { [weak self] divisions in
            guard let self = self else { return }
            self.divisions = divisions ?? []
            self.insertRow(title: L10n.Signup.School.academicDivision, into: \.schoolSectionTitles, at: 1)
        }
    }

    private func selectAcademicDivision(_ filterIndex: Int) {
        schoolSection = .academicYear
        currentSelection.academicYear = nil
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.schoolSectionTitles, startingAt: 2)
        showLoading(on: 1)
        currentSelection.academicDivision = divisions[filterIndex]
        viewModel?.loadBatches(for: currentSelection.academicDivision?.key ?? 0) { [weak self] years in
            guard let self = self else { return }
            self.years = years ?? []
            self.insertRow(title: L10n.Signup.School.academicYear, into: \.schoolSectionTitles, at: 2)
        }
    }

    private func selectSchoolYear(_ filterIndex: Int) {
        schoolSection = .subjects
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.schoolSectionTitles, startingAt: 3)
        showLoading(on: 2)
        currentSelection.academicYear = years[filterIndex]
        viewModel?.loadSubjects(forYear: currentSelection.academicYear?.key ?? 0) { [weak self] subjects in
            guard let self = self else { return }
            self.subjects = subjects.subjects ?? []
            self.insertRow(title: L10n.Filters.subject, into: \.schoolSectionTitles, at: 3)
        }
    }

    private func selectSchoolSubject(_ filterIndex: Int) {
        isApplyEnabled = true
        currentSelection.subject = subjects[filterIndex]
    }

    // MARK: - Hidden-org university filter steps

    private func selectHiddenOrgYear(_ filterIndex: Int) {
        universitySection = .subjects
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.universitySectionTitles, startingAt: 1)
        showLoading(on: 0)
        currentSelection.academicYear = academicYears[filterIndex]
        viewModel?.loadSubjects(forYear: currentSelection.academicYear?.key ?? 0) { [weak self] subjects in
            guard let self = self else { return }
            self.universitySubjects = subjects.subjects ?? []
            self.insertRow(title: L10n.Filters.subject, into: \.universitySectionTitles, at: 1)
        }
    }

    private func selectHiddenOrgSubject(_ filterIndex: Int) {
        isApplyEnabled = true
        currentSelection.subject = universitySubjects[filterIndex]
    }

    // MARK: - Standard university filter steps

    private func selectUniversity(_ filterIndex: Int) {
        universitySection = .field
        currentSelection.field = nil
        currentSelection.academicYear = nil
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.universitySectionTitles, startingAt: 1)
        showLoading(on: 0)
        currentSelection.academicDivision = universities[filterIndex]
        viewModel?.loadSpecializations(for: currentSelection.academicDivision?.key ?? 0) { [weak self] fields in
            guard let self = self else { return }
            self.fields = fields ?? []
            self.insertRow(title: L10n.Signup.School.field, into: \.universitySectionTitles, at: 1)
        }
    }

    private func selectField(_ filterIndex: Int) {
        universitySection = .academicYear
        currentSelection.academicYear = nil
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.universitySectionTitles, startingAt: 2)
        showLoading(on: 1)
        currentSelection.field = fields[filterIndex]
        viewModel?.loadBatches(for: currentSelection.academicDivision?.key ?? 0) { [weak self] academicYears in
            guard let self = self else { return }
            self.academicYears = academicYears ?? []
            self.insertRow(title: L10n.Signup.School.academicYear, into: \.universitySectionTitles, at: 2)
        }
    }

    private func selectUniversityYear(_ filterIndex: Int) {
        universitySection = .subjects
        currentSelection.subject = nil
        isApplyEnabled = false
        removeRows(from: \.universitySectionTitles, startingAt: 3)
        showLoading(on: 2)
        currentSelection.academicYear = academicYears[filterIndex]
        viewModel?.loadSubjects(forYear: currentSelection.academicYear?.key ?? 0) { [weak self] subjects in
            guard let self = self else { return }
            self.universitySubjects = subjects.subjects ?? []
            self.insertRow(title: L10n.Filters.subject, into: \.universitySectionTitles, at: 3)
        }
    }

    private func selectUniversitySubject(_ filterIndex: Int) {
        isApplyEnabled = true
        currentSelection.subject = universitySubjects[filterIndex]
    }
}
