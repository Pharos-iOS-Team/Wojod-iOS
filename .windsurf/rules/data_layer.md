# Data Layer Architecture

This document defines the rules and patterns for data access in the Wojod application, covering network calls, model patterns, and data flow.

## Model Architecture

### Two-Layer Model System

Wojod uses a simpler two-layer model system (no Core Data persistence layer):

1. **API Response Models** (`Models/[Feature]/`) - Codable structs for network responses
2. **Request Models** (`Models/RequestModel/`) - Codable structs for network request bodies

Example: `Video` model in `Models/Course/LessonsAttachmentsModel.swift`:
```swift
struct Video: Codable {
    var id: Int
    var title: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: String?
    var type: String?
    var publishedAt: Date?
    var vdocipherId: String?
    var duration: Int?
    var link: String?
    var viewsRemaining: Int?
    var daysRemaining: Int?
    var lockMessage: String?
    var locked: Bool
}
```

### Model Conventions

- All models are **Codable** structs (value types)
- Properties are `var` with optional types (`?`) for server-driven flexibility
- JSON decoder uses `.convertFromSnakeCase` so `library_id` maps to `libraryId` automatically
- Models live in feature-grouped directories under `App/Sources/Models/`

## Network Layer Patterns

### Unified Endpoint System

All API endpoints are routed through a single `Endpoint` enum that delegates to feature-specific sub-endpoints:

```swift
enum Endpoint {
    case auth(AuthEndpoint)
    case home(HomeEndpoint)
    case courseDetails(CourseDetailsEndpoint)
    case profile(ProfileEndpoint)
    case chat(ChatEndpoint)
    case notifications(NotificationsEndpoint)
    case academicInfo(AcademicInfoEndpoint)
    case organizationsList(OrganizationsListEndpoint)
    case registration(RegistrationEndpoint)
    case assessments(AssessmentsEndpoint)
}
```

Each sub-endpoint is a `TargetType` enum defining `path`, `method`, and `task`.

### Adding a New Endpoint

1. Add cases to the appropriate feature endpoint enum (e.g., `CourseDetailsEndpoint`)
2. Implement `path`, `method`, and `task` in the enum's `TargetType` extension
3. If it's a new feature domain, add a new case to `Endpoint` enum and wire up `path`/`method`/`task` delegation
4. Use `ApiProvider.shared.request()` to make the call

### ApiProvider Usage

```swift
// Completion-based (decode to specific type)
ApiProvider.shared.request(.courseDetails(.loadLessons(courseID: 42)),
    decodeTo: LessonsModel.self) { result in
    switch result {
    case .success(let lessons):
        // handle success
    case .failure(let error):
        // handle error
    }
}

// Completion-based (raw Response)
ApiProvider.shared.request(.auth(.login(loginRequest))) { result in
    switch result {
    case .success(let response):
        // handle raw response
    case .failure(let error):
        // handle ApiError
    }
}

// Upload with progress
ApiProvider.shared.upload(.profile(.updateAvatar(imageData)),
    decodeTo: AvatarResponse.self,
    progress: { fraction in /* update UI */ },
    completion: { result in /* handle result */ })
```

### Model Layer

Feature-specific Model classes wrap `ApiProvider` calls and use `Swift.Result` directly:

```swift
class CourseDetailsModel {
    func loadLessons(courseID: Int, completion: @escaping (Swift.Result<LessonsModel, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.loadLessons(courseID: courseID)),
            decodeTo: LessonsModel.self, completion: completion)
    }
}
```

### ViewModel Layer

ViewModels call Model methods and surface results via closure handlers:

```swift
class CourseDetailsViewModel {
    private let model = CourseDetailsModel()

    func loadLessons(courseID: Int, completion: @escaping (LessonsModel) -> Void) {
        model.loadLessons(courseID: courseID) { result in
            switch result {
            case .success(let lessons):
                completion(lessons)
            case .failure:
                break
            }
        }
    }
}
```

### Request Models

All request bodies use dedicated `Codable` structs in `Models/RequestModel/`:

```swift
struct LoginRequestModel: Codable {
    let mobileNumber: String
    let password: String
}

struct GetOTPRequestModel: Codable {
    let mobileNumber: String
    let countryCode: String
}
```

Request models use `toDictionary(encoder:)` extension for Moya task parameters:
```swift
case let .login(loginRequestModel):
    return .requestParameters(
        parameters: try loginRequestModel.toDictionary(encoder: .default),
        encoding: JSONEncoding.default
    )
```

## Auth Plugin

The `AuthPlugin` automatically injects auth headers (`access-token`, `client`, `uid`) into requests and saves them from responses:

- **No-auth endpoints**: `.auth(.login)`, `.auth(.guestMode)`, `.auth(.sendMobileNumber)`, `.auth(.verifyOtp)`, `.auth(.verifyOtpFromLogin)`
- **Save-auth endpoints**: `.auth(.login)`, `.auth(.verifyOtpFromLogin)`, `.profile(.fetchProfile)`

## Language Plugin

The `LanguagePlugin` automatically appends `locale` query parameter to all requests using `Language.currentLanguage`.

## Error Handling

### Error Types

```swift
// Legacy error type (used in ViewModels ↔ ViewControllers)
struct WJError: Error {
    var type: ErrorType
    var message: String
}

enum ErrorType: Equatable {
    case validationError
    case serverSideError(statusCode: HTTPStatusCode? = nil)
    case connectivityError
    case parsingError
}

// Network-layer error type (used in ApiProvider)
enum ApiError: LocalizedError, Equatable {
    case noResponseReceived(error: String?)
    case noDataInResponse
    case responseDataConversionFailed(error: String)
    case unauthorized(error: String)
    case clientError(statusCode: Int, clientError: EndpointError)
    case serverError(statusCode: Int)
    case unexpectedStatusCode(statusCode: Int)
    case networkError(String)
    case conflictError(String)
}
```

### Error Flow

```
ApiProvider → ApiError → Model layer → WJError → ViewModel → errorHandler closure → ViewController
```

## Shared State

### User Singleton
`User.shared` holds the current user session:
- `User.shared.id` — current user ID
- `User.shared.setLoggedIn(token:client:uid:)` — save auth credentials
- `User.shared.setLoggedOut()` — clear session
- `User.shared.setUserData(user:)` — update user profile data

### SwiftyUserDefaults
`Defaults[\.keyName]` for simple persisted values:
- `Defaults[\.isGuestModeEnabled]`
- `Defaults[\.clientKey]`
- `Defaults[\.uidKey]`

### KeychainHandler
`KeychainHandler.shared.userToken` for secure token storage.

## Bridge Files

Some legacy files still bridge old patterns to the new unified networking:
- `NetworkProvider.swift`: delegates to `ApiProvider.shared.request(.registration(target))`
- `RegistrationService.swift`: old TargetType enum, used as bridge by NetworkProvider
- `NetworkError.swift`: Decodable error struct, used by NetworkProvider
- `CoursesDecoder.swift`: used by ChatViewModel for WebSocket decoding
- `AssessmentSynchronization.swift`: uses migrated AssessmentDetailsModel

When writing new code, use `Swift.Result` directly from `ApiProvider` without custom Result enums.
