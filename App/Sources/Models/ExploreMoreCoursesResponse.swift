// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct CoursesResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case subjects
        case teachersCourses
    }

    var subjects: [Subject]?
    var teachersCourses: [SubjectCourses]?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            subjects = try values.decode([Subject].self, forKey: .subjects)
        } catch DecodingError.keyNotFound {
            subjects = nil
        }

        do {
            let coursesDictionary: [String: [SubjectCourses]] = try values.decode([String: [SubjectCourses]].self, forKey: .teachersCourses)
            teachersCourses = Array(coursesDictionary.values) as? [SubjectCourses]
        } catch DecodingError.typeMismatch {
            teachersCourses = try values.decode([SubjectCourses].self, forKey: .teachersCourses)
        }
    }
}
