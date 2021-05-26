// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CourseDetailsModel: ModelDecodable {
    let apiClient = CourseDetailsApiClient()

    func loadLessons(courseID: Int, completion: @escaping (Result) -> Void) {
        apiClient.loadLessons(courseID: courseID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: LessonsModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }
}
