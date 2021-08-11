// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation

class SubjectsViewModel {
    private weak var viewModel: GenericSubjectsViewModel?
    
    init(viewModel: GenericSubjectsViewModel?) {
        self.viewModel = viewModel
    }

    func getNumberOfSubjects() -> Int {
        return viewModel?.getNumberOfSubjects() ?? 0
    }

    func getSubjectName(indexPath: IndexPath) -> String {
        return viewModel?.getNameOfSubject(atIndexPath: indexPath) ?? ""
    }
}
