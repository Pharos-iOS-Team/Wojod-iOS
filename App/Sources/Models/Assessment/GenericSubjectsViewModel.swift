// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

protocol GenericSubjectsViewModel: AnyObject {
    func getNumberOfSubjects() -> Int
    func getNameOfSubject(atIndexPath indexPath: IndexPath) -> String
}
