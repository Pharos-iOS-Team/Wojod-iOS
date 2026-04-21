// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AuthEndpoint {
    case login(LoginRequestModel)
    case guestMode(GuestModeRequestModel)
    case logout(LogoutRequestModel)
    case sendMobileNumber(GetOTPRequestModel)
    case verifyOtp(OtpVerification)
    case verifyOtpFromLogin(OtpVerification)
    case createPassword(ForgetPasswordModel)
}

extension AuthEndpoint: TargetType {
    var path: String {
        switch self {
        case .login:
            return "/auth/sign_in"
        case .guestMode:
            return "/white_label_version"
        case .logout:
            return "/auth/sign_out"
        case .sendMobileNumber:
            return "/password/send_otp"
        case .verifyOtp:
            return "/password/verify_otp"
        case .verifyOtpFromLogin:
            return "/verify_otp"
        case .createPassword:
            return "/password"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .sendMobileNumber, .verifyOtp, .verifyOtpFromLogin:
            return .post
        case .guestMode:
            return .get
        case .logout:
            return .delete
        case .createPassword:
            return .put
        }
    }

    var task: Task {
        switch self {
        case let .login(loginRequestModel):
            do {
                return .requestParameters(
                    parameters: try loginRequestModel.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .guestMode(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .logout(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }
        case let .sendMobileNumber(otp):
            do {
                return .requestParameters(
                    parameters: try otp.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .verifyOtp(otp):
            do {
                return .requestParameters(
                    parameters: try otp.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .verifyOtpFromLogin(otp):
            do {
                return .requestParameters(
                    parameters: try otp.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .createPassword(password):
            do {
                return .requestParameters(
                    parameters: try password.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }
        }
    }
}
