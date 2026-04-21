// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum CourseState: String {
    case normal
    case pending
    case booked = "approved"
}

enum ActiveScreen {
    case details
    case reviews
    case materials
}

enum MaterialsSections: Int, CaseIterable {
    case assignments
    case quizzes
    case videos
    case documents
}

protocol LoadableView: AnyObject {
    func startLoading()
    func stopLoading()
}
