// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.
import Foundation

protocol GenericSubjectsViewModel: class {
    func getNumberOfSubjects() -> Int
    func getNameOfSubject(atIndexPath indexPath: IndexPath) -> String
}
