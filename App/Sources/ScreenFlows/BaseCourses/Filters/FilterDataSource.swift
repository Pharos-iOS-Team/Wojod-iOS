// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

class FilterDataSource: NSObject, UITableViewDataSource {
    weak var coordinator: FilterCoordinator?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let state = coordinator else { return 0 }
        return state.academicLevel == .schoolStudent ? state.schoolSectionTitles.count : state.universitySectionTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FiltersTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.selectionStyle = .none
        cell.setIsLoading(false)

        guard let state = coordinator else { return cell }
        cell.onSelectSchoolFilter = { [weak state] index, section in
            state?.selectSchoolFilter(index, in: section)
        }
        cell.onSelectUniversityFilter = { [weak state] index, section in
            state?.selectUniversityFilter(index, in: section)
        }
        cell.academicLevel = state.academicLevel

        if state.isLoadingData && indexPath.row == 0 {
            cell.setIsLoading(true)
            return cell
        }

        if state.academicLevel == .schoolStudent {
            configureSchoolCell(cell, at: indexPath, state: state)
        } else {
            configureUniversityCell(cell, at: indexPath, state: state)
        }

        return cell
    }

    private func configureSchoolCell(_ cell: FiltersTableViewCell, at indexPath: IndexPath, state: FilterCoordinator) {
        switch state.schoolSection {
        case .academicType:
            cell.configure(title: state.schoolSectionTitles[indexPath.row], filters: state.academicTypes.compactMap { $0.value }, section: .academicType)
            if let academicType = state.currentSelection.academicType {
                cell.selectOldEntry(for: state.academicTypes.firstIndex { $0.key == academicType.key })
            }
        case .academicDivision:
            cell.configure(title: L10n.Signup.School.academicDivision, filters: state.divisions.compactMap { $0.value }, section: .academicDivision)
            if let division = state.currentSelection.academicDivision {
                cell.selectOldEntry(for: state.divisions.firstIndex { $0.key == division.key })
            }
        case .academicYear:
            cell.configure(title: L10n.Signup.School.academicYear, filters: state.years.compactMap { $0.value }, section: .academicYear)
            if let year = state.currentSelection.academicYear {
                cell.selectOldEntry(for: state.years.firstIndex { $0.key == year.key })
            }
        case .subjects:
            cell.configure(title: L10n.Filters.subject, filters: state.subjects.compactMap { $0.name }, section: .subjects)
            if let subject = state.currentSelection.subject {
                cell.selectOldEntry(for: state.subjects.firstIndex { $0.id == subject.id })
            }
        }
    }

    private func configureUniversityCell(_ cell: FiltersTableViewCell, at indexPath: IndexPath, state: FilterCoordinator) {
        if AppEnvironment.shouldHideOrganization {
            configureHiddenOrgCell(cell, at: indexPath, state: state)
        } else {
            configureStandardUniversityCell(cell, at: indexPath, state: state)
        }
    }

    private func configureHiddenOrgCell(_ cell: FiltersTableViewCell, at indexPath: IndexPath, state: FilterCoordinator) {
        switch state.universitySection {
        case .academicYear:
            cell.configureForUniveristy(title: L10n.Signup.School.academicYear, filters: state.academicYears.compactMap { $0.value }, section: .academicYear)
            if let academicYear = state.currentSelection.academicYear {
                cell.selectOldEntry(for: state.academicYears.firstIndex { $0.key == academicYear.key })
            }
        case .subjects:
            cell.configureForUniveristy(title: L10n.Filters.subject, filters: state.universitySubjects.compactMap { $0.name }, section: .subjects)
            if let subject = state.currentSelection.subject {
                cell.selectOldEntry(for: state.universitySubjects.firstIndex { $0.id == subject.id })
            }
        default:
            cell.configure(title: "", filters: [], section: .academicType)
        }
    }

    private func configureStandardUniversityCell(_ cell: FiltersTableViewCell, at indexPath: IndexPath, state: FilterCoordinator) {
        switch state.universitySection {
        case .university:
            cell.configureForUniveristy(title: L10n.Filters.university, filters: state.universities.compactMap { $0.value }, section: .university)
            if let university = state.currentSelection.academicDivision {
                cell.selectOldEntry(for: state.universities.firstIndex { $0.key == university.key })
            }
        case .field:
            cell.configureForUniveristy(title: L10n.Signup.School.field, filters: state.fields.compactMap { $0.value }, section: .field)
            if let field = state.currentSelection.field {
                cell.selectOldEntry(for: state.fields.firstIndex { $0.key == field.key })
            }
        case .academicYear:
            cell.configureForUniveristy(title: L10n.Signup.School.academicYear, filters: state.academicYears.compactMap { $0.value }, section: .academicYear)
            if let academicYear = state.currentSelection.academicYear {
                cell.selectOldEntry(for: state.academicYears.firstIndex { $0.key == academicYear.key })
            }
        case .subjects:
            cell.configureForUniveristy(title: L10n.Filters.subject, filters: state.universitySubjects.compactMap { $0.name }, section: .subjects)
            if let subject = state.currentSelection.subject {
                cell.selectOldEntry(for: state.universitySubjects.firstIndex { $0.id == subject.id })
            }
        }
    }
}
