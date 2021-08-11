// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class AcademicInfoModel: ModelDecodable {
    let apiClient = AcademicInfoApiClient()

    func fetchEducationalTypes(completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchEducationalTypes { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: EducationalTypesModel.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                self.handleMoyaError(error: error, completionHandler: completionHandler)
            }
        }
    }

    func fetchDivisions(completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchDivisions { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: DivisionsModel.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: ""))))
            }
        }
    }

    func fetchBatches(id: String, completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchBatches(id: id) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: BatchesModel.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: ""))))
            }
        }
    }

    func fetchSpecializations(id: String, completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchSpecializations(id: id) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: SpecializationsModel.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: ""))))
            }
        }
    }
}
