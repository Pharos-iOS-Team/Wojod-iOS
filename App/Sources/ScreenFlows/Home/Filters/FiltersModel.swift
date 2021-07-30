// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class FiltersModel: ModelDecodable {
    private let apiClient = FiltersApiClient()

    func loadFilteredCourses(isMyCourses: Bool, subjectID: Int, batchID: Int, specializationID: Int?, completion: @escaping (Result) -> Void) {
        apiClient.loadFilteredCourses(isMyCourses: isMyCourses, subjectID: subjectID, batchID: batchID, specializationID: specializationID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: ExploreMoreCoursesResponse.self, from: response) { result in
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
