// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class HomeModel: ModelDecodable {
    private let homeApiClient = HomeApiClient()
    private let profileApiClient = ProfileApiClient()

    private func cacheAccessToken(headers: [AnyHashable: Any]?) {
        guard let token = headers?["access-token"] as? String,
        let client = headers?["client"] as? String,
        let uid = headers?["uid"] as? String
        else { return }
        User.shared.setLoggedIn(token: token, client: client, uid: uid)
    }

    func loadSubjects(batchID: Int, completion: @escaping (Result) -> Void) {
        homeApiClient.loadSubjects(batchID: batchID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: Subjects.self, from: response) { result in
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

    func loadCourses(requestModel: CoursesRequestModel, completion: @escaping (Result) -> Void) {
        homeApiClient.loadCourses(requestModel: requestModel) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: CoursesResponse.self, from: response) { result in completion(result) }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func searchCourses(value: String, completion: @escaping (Result) -> Void) {
        homeApiClient.searchCourses(value: value) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: CoursesResponse.self, from: response) { result in completion(result) }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func loadAds(completion: @escaping (Result) -> Void) {
        homeApiClient.loadAds { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: Advertisements.self, from: response) { result in
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

    func fetchUserProfile(id: Int, completionHandler: @escaping (Result) -> Void) {
        profileApiClient.fetchProfile(id: String(User.shared.id ?? 62)) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.cacheAccessToken(headers: response.response?.allHeaderFields)
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
}
