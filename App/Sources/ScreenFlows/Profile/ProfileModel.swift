// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ProfileModel: ModelDecodable {
    let apiClient = ProfileApiClient()

    func editProfile(id: String, profile: Profile, completionHandler: @escaping (Result) -> Void) {
        apiClient.editProfile(id: id, profile: profile) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: StudentModel.self, from: response) { result in
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

    func fetchDivisions(academicLevel: Int, academicType: Int, completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchDivisions(academicLevel: academicLevel, academicType: academicType) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: DivisionsModel.self, from: response) { result in
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
