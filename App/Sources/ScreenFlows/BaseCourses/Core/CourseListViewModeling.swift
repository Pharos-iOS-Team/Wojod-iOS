// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol CourseListViewModeling: AnyObject {
    var courses: [SubjectCourses] { get set }
    var subjects: [Subject] { get set }
    var selectedSubjectIndexPath: IndexPath { get set }
    var selectedSubject: Subject? { get set }
    var mode: HomeMode { get set }
    var emptyStateType: EmptyStateType { get set }
    var isMyCourses: Bool { get }

    func loadCourses(completion: @escaping () -> Void)
    func changeMode(to newMode: HomeMode)
    func selectSubject(_ subject: Subject)
    func resetPagination()
    func updateEmptyState()
}
