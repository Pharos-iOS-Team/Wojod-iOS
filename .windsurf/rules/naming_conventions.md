# Naming Conventions

## File Naming

### Swift Files
- **Types**: `PascalCase` matching the primary type (e.g., `CourseDetailsViewController.swift`)
- **Protocols**: `PascalCase` (e.g., `AssessmentDetailsDelegate.swift`)
- **Extensions**: `ClassName+ExtensionName.swift` (e.g., `UIView+Round.swift`)
- **Test Files**: `ClassNameTests.swift` (e.g., `CourseDetailsViewModelTests.swift`)

### Directory Structure
- Follow the feature-based structure under `ScreenFlows/`
- Group related files in appropriate folders (Cells/, Views/, etc.)
- Use `PascalCase` for folder names

## Code Naming — Swift API Design Guidelines

### Types
- **Classes**: `PascalCase` (e.g., `CourseDetailsViewController`)
- **Structs**: `PascalCase` (e.g., `LoginRequestModel`, `EncryptedVideoResponse`)
- **Enums**: `PascalCase` (e.g., `ErrorType`, `AssessmentStatus`, `HomeMode`)
- **Protocols describing capability**: `-able`/`-ible`/`-ing` suffix (e.g., `Codable`, `Encodable`)
- **Protocols describing identity**: Noun (e.g., `TableViewCellConfigurable`, `Collection`)

### Properties and Variables
- **Instance properties**: `camelCase` (e.g., `courseID`, `activeScreen`)
- **Static properties**: `camelCase` (e.g., `shared`)
- **Constants**: `camelCase` (e.g., `cornerRadius`)
- **IBOutlets**: `camelCase` with descriptive type suffix (e.g., `profileTableView`, `submitButton`, `nameTextField`)
- **Booleans**: `is`/`has`/`can`/`should` prefix (e.g., `isLoading`, `isGuestModeEnabled`, `hasUnsavedChanges`)

### Functions and Methods
- **Methods**: `camelCase`, verb-first for mutations (e.g., `loadLessons()`, `configureCell()`)
- **Non-mutating methods**: noun or verb phrase (e.g., `lessonsList()`, `isValid`)
- **IBActions**: `camelCase` with action description (e.g., `login(_:)`, `dismiss(_:)`, `editProfile(_:)`)
- **Lifecycle**: `camelCase` (e.g., `viewDidLoad`, `viewWillAppear`)

### Enum Cases
- **LowerCamelCase** (e.g., `.validationError`, `.connectivityError`, `.open`, `.closed`)

## Special Naming Patterns

### MVVM Pattern
- **ViewControllers**: `[Feature]ViewController` (e.g., `CourseDetailsViewController`)
- **ViewModels**: `[Feature]ViewModel` (e.g., `CourseDetailsViewModel`)
- ❌ **No more `[Feature]Model` classes** — ViewModels call `ApiProvider` directly

### Network Layer
- **Endpoint enums**: `[Feature]Endpoint` (e.g., `AuthEndpoint`, `CourseDetailsEndpoint`)
- **Request models**: `[Action]RequestModel` (e.g., `LoginRequestModel`, `LogoutRequestModel`)
- **Response models**: `[Entity]Response[Model]` (e.g., `CourseDetailsResponse`, `BookingCourseResponseModel`)

### Localization Keys
- **Module scope**: `module.section.key` in `snake_case` (e.g., `course_details.main.contact_us`)
- **Global scope**: `global.section.key` (e.g., `global.actions.cancel`)
- **Sections**: Plural naming (actions, alerts, titles, messages)
- **SwiftGen accessor**: `L10n.[Feature].[Key]` or `L10n.Global.[Section].[Key]`

### SwiftGen Accessors — One Canonical Form
- **Images**: `Asset.Images.someImage` — no alternatives
- **Colors**: `Asset.Colors.someColor`
- **Storyboards**: `StoryboardScene.[Feature].viewController`
- **Localization**: `L10n.[Feature].[Key]`

## Banned Naming Patterns

| Banned | Reason | Use Instead |
|--------|--------|-------------|
| `var successHandler` | Inconsistent — some use `successHandler`, some use `showIndicator` | `private(set) var isLoading` + async method |
| `var showIndicator` | Not a noun, inconsistent naming | `private(set) var isLoading` |
| `var errorHandler` | Inconsistent type (`WJError` vs `ApiError`) | `private(set) var error: ApiError?` |
| `ID` vs `Id` | Inconsistent across codebase | **`id`** for property names (per Swift API guidelines), **`ID`** only in type names |
| `ViewCtrl` / `viewCtrl` | Abbreviation | `ViewController` / `viewController` |

## SwiftLint Enforcement

The following naming conventions are enforced by SwiftLint (see `.swiftlint.yml`):
- **type_name**: Types must be PascalCase
- **function_body_length**: Reasonable function length
- **type_body_length**: Reasonable type length
- **file_length**: Reasonable file length
- **line_length**: Max 160 characters
- **file_header**: Copyright header required (`// Copyright © YYYY Pharos Solutions. All rights reserved.`)
- **file_name**: File name must match primary type

## Best Practices

1. **Be descriptive**: Use names that clearly describe the purpose
2. **Avoid abbreviations**: Use full words unless widely understood (e.g., `URL`, `id`, `OTP`)
3. **Consistency**: Pick one form and stick with it — no mixing `ViewCtrl`/`ViewController`
4. **Boolean naming**: Always use `is`/`has`/`can`/`should` prefix for booleans
5. **Verb-first methods**: `load`, `fetch`, `configure`, `present`, `handle` — not noun-first
