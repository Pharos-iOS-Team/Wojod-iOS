# Architecture (MVVM + UIKit)

The app uses **MVVM with UIKit** — ViewControllers own ViewModels, ViewModels own Models, and communication flows through closures (handlers).

## Architecture Pattern

```
ScreenFlows/[Feature]/
  ├── [Feature]ViewController.swift   → UIKit ViewController (Presentation + Navigation)
  ├── [Feature]ViewModel.swift        → Business logic, closure-based callbacks
  ├── [Feature]Model.swift            → Network calls (wraps ApiProvider)
  ├── Cells/                          → UITableView/UICollectionView cells
  ├── Views/                          → Custom UIView subclasses
  └── [Feature].storyboard            → Interface Builder layout
```

## Core Components

### ViewController → ViewModel → Model Flow
- **ViewController**: Owns ViewModel, binds handlers in `viewDidLoad`, handles UI and navigation
- **ViewModel**: Owns Model, exposes closure handlers for success/error/loading, contains business logic
- **Model**: Wraps `ApiProvider.shared.request()` calls, transforms raw `Result` enum responses

### Handler Pattern (Closure-based Binding)
ViewModels communicate back to ViewControllers via closures:
```swift
class LoginViewModel {
    var errorHandler: ((WJError) -> Void)?
    var successHandler: ((LoginApiResponseModel) -> Void)?
    var showIndicator: (() -> Void)?

    func login(mobileNumber: String?, password: String?) {
        // validation → showIndicator?() → model.login → successHandler?() / errorHandler?()
    }
}
```

ViewController binds handlers in `viewDidLoad`:
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = LoginViewModel()
    handleLoginSuccess()
    handleErrors()
    showLoadingIndicatorHandler()
}
```

### Data Flow
**Closure-based flow:** View → IBAction → ViewModel → Model → ApiProvider → Result → Handler → View Update

```
ViewController --(IBAction)--> ViewModel --(method call)--> Model --(ApiProvider)--> Network
     ↑                                                              ↓
     └----------------------(handler closure)----------------------┘
```

## Key Patterns

### Navigation
- Use `StoryboardScene.[Feature].viewController.instantiate()` for storyboard-based navigation
- Present modally with `.fullScreen` style for major flows
- Push onto `navigationController` for drill-down flows
- `ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()` for root transitions

### Loading Indicators
- Use `JGProgressHUD` for loading states
- Show in `showIndicator` handler, dismiss in success/error handlers

### Alert Handling
- Use `AlertHandler(presentingViewCtrl: self)` for standard alerts
- `AlertView` (custom) for inline validation errors
- `AppAlertViewController` for complex modal alerts (assessments)

### Localization & RTL
- Use `Language` enum for RTL/LTR support
- Set `semanticContentAttribute` and `textAlignment` via `Language` helpers
- `Language.contentHorizontalAlignment` for button alignment

### Error Handling
- `WJError` struct with `ErrorType` enum (validationError, serverSideError, connectivityError, parsingError)
- `ApiError` enum for network-layer errors (unauthorized, clientError, serverError, networkError, conflictError)
- ViewModels map errors to `WJError` or `ApiError` and surface via `errorHandler`

## File Organization

### Directory Structure
```
App/Sources/
├── AppDelegates/           → App lifecycle, composite AppDelegate pattern
├── DataServices/           → (reserved for future data services)
├── Global/
│   ├── Constants/          → App-wide constants (UIConstants, etc.)
│   ├── Extensions/         → Swift/UIKit/Foundation extensions
│   ├── Modules/            → Shared module helpers
│   └── Utilities/          → AlertHandler, Language, KeychainHandler, etc.
├── Models/
│   ├── Assessment/         → Assessment-related Codable models
│   ├── Chat/               → Chat models
│   ├── Core/               → Shared models (WJError, Result, HTTPStatusCode, etc.)
│   ├── CoreData/           → Core Data models (if any)
│   ├── Course/             → Course, Lesson, Materials, Video models
│   ├── Home/               → Home screen models
│   ├── Profile/            → User, Profile, Auth models
│   └── RequestModel/       → API request body models
├── Networking/
│   ├── Core/               → ApiProvider, Endpoint, ApiError, EndpointError
│   ├── Endpoints/          → Feature-specific TargetType enums
│   └── Plugins/            → AuthPlugin, LanguagePlugin
└── ScreenFlows/
    ├── [Feature]/          → ViewController + ViewModel + Model + Cells + Views
    └── UIComponents/       → Shared UI components (AlertView, SendButton, etc.)
```

## Integration Points

### SwiftUI in UIKit
- Use `UIHostingController` to present SwiftUI views from UIKit (e.g., BunnyPlayerView)
- SwiftUI views can use `WatermarkModifier` and other shared modifiers

### Storyboards
- Each feature has its own storyboard (`[Feature].storyboard`)
- Access via SwiftGen-generated `StoryboardScene` enum
- IBOutlets configured in `didSet` blocks for localization and styling
