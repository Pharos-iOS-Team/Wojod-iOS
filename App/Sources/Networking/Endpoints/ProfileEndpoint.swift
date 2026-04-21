// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ProfileEndpoint {
    case fetchProfile(IDRequestModel)
    case editProfile(id: String, profile: Profile)
    case fetchDivisions(AcademicInfoRequestModel)
    case fetchBatches(id: String)
    case fetchSpecializations(id: String)
    case deleteAccount
    case getAvatars
}

extension ProfileEndpoint: TargetType {
    var path: String {
        switch self {
        case let .fetchProfile(requestModel):
            return "/students/\(requestModel.id)"
        case let .editProfile(id, _):
            return "/students/\(id)"
        case .fetchDivisions:
            return "/divisions"
        case let .fetchBatches(id):
            return "/divisions/\(id)/batches"
        case let .fetchSpecializations(id):
            return "/divisions/\(id)/specializations"
        case .deleteAccount:
            return "/delete_account"
        case .getAvatars:
            return "/avatars"
        }
    }

    var method: Moya.Method {
        switch self {
        case .editProfile:
            return .put
        case .deleteAccount:
            return .delete
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .fetchProfile(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .editProfile(_, profile):
            do {
                return .requestParameters(
                    parameters: try profile.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .fetchDivisions(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.default
                )
            } catch {
                return .requestPlain
            }

        default:
            return .requestPlain
        }
    }
}
