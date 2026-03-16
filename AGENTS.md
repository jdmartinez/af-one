# AGENTS.md — AFOne Development Guide

## Project Overview

AFOne is an iOS clinical atrial fibrillation monitoring app built with SwiftUI. It integrates with Apple Watch/HealthKit to help patients track AF episodes, burden, symptoms, and generate clinical reports.

- **Platform**: iOS 17.0+ (SwiftUI)
- **Swift Version**: 5.9
- **Architecture**: MVVM with `@Observable` classes
- **Build System**: XcodeGen (`project.yml`)

---

## Build & Run Commands

### Prerequisites

```bash
# Install XcodeGen if not present
brew install xcodegen

# Generate Xcode project
xcodebuild -project AFOne.xcodeproj -scheme AFOne -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### Running the App

1. Open `AFOne.xcodeproj` in Xcode
2. Select a simulator (iPhone 16 Pro recommended)
3. Press `Cmd + R` to build and run

### Testing

No dedicated tests exist yet. When adding tests:

```bash
# Run all tests in Xcode
Cmd + U

# Run specific test class
xcodebuild test -scheme AFOne -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:AFOneTests.SomeTestClass
```

---

## Code Style Guidelines

### General Conventions

- **Swift Version**: Target Swift 5.9+ features
- **iOS Deployment**: 17.0 minimum (required for `@Observable` and modern SwiftUI)
- **Always use async/await** for asynchronous operations
- **Prefer value types** (structs) over reference types unless reference semantics are needed

### File Organization

```plaintext
AFOne/
├── App/           # App entry point (AFOneApp.swift, ContentView.swift)
├── Features/      # Feature modules organized by screen/function
│   ├── Dashboard/
│   ├── Timeline/
│   ├── Log/
│   └── ...
├── Core/          # Services, business logic
│   ├── HealthKit/
│   ├── Analysis/
│   ├── Notifications/
│   └── Export/
├── Models/        # Data models
├── Shared/        # Reusable components
│   ├── Extensions/
│   └── Components/
└── Localization/  # Localized strings
```

### Naming Conventions

- **Types/Enums/Protocols**: `PascalCase` (e.g., `RhythmEpisode`, `HealthKitError`)
- **Properties/Methods/Variables**: `camelCase` (e.g., `currentStatus`, `fetchEpisodes()`)
- **Files**: Match type name (e.g., `RhythmEpisode.swift`)
- **ViewModels**: `{FeatureName}ViewModel.swift` (e.g., `DashboardViewModel.swift`)
- **Views**: `{FeatureName}{View,Row,Card}.swift` (e.g., `DashboardView.swift`, `HeroCardView.swift`)

### Import Organization

```swift
// Standard library first
import Foundation

// Third-party frameworks
import SwiftUI
import SwiftData
import Charts

// Internal imports (alphabetical)
import AFOne.Core.HealthKit
import AFOne.Models
```

### Type Definitions

```swift
// Models - use structs with Identifiable and Codable
struct RhythmEpisode: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    var duration: TimeInterval { ... }
}

// Enums - use for finite types
enum RhythmType: String, Codable {
    case normal
    case af = "AF"
    case unknown
}

// Error types - conform to Error and LocalizedError
enum HealthKitError: Error, LocalizedError {
    case dataNotAvailable
    case authorizationDenied
    case queryFailed(Error)

    var errorDescription: String? {
        switch self { ... }
    }
}
```

### ViewModels & State Management

```swift
// Use @Observable for iOS 17+ ViewModels
@MainActor
@Observable
final class DashboardViewModel {
    var currentStatus: RhythmStatus = .unknown
    var isLoading = false

    // Computed properties for derived state
    var statusIcon: String { ... }

    // Async methods for data fetching
    func loadData() async { ... }
}

// In views, use @State for owned state, inject ViewModels via environment or direct init
@State private var selectedPeriod: TimePeriod = .week

struct DashboardView: View {
    let viewModel: DashboardViewModel  // Injected, not @StateObject

    var body: some View { ... }
}
```

### SwiftUI Best Practices

**State Management**:

- `@State` must be `private` and only for internal view state
- Use `@Binding` only when child needs to modify parent state
- `@StateObject` when view creates the object; `@ObservedObject` when injected
- iOS 17+: Prefer `@Observable` with `@Bindable` for injected observables

**View Structure**:

- Extract complex views into separate subviews
- Keep `body` pure (no side effects or complex logic)
- Use modifiers over conditionals for state changes (preserves view identity)
- Use semantic fonts: `.headline`, `.body`, `.subheadline` (supports Dynamic Type)

**Performance**:

- Use `LazyVStack`/`LazyHStack` for long lists
- Use stable identity for `ForEach` (never `.indices`)
- Pass only needed values to views, avoid large config objects

### Error Handling

```swift
// Service layer - throw typed errors
func fetchEpisodes() async throws -> [RhythmEpisode] {
    guard isAuthorized else {
        throw HealthKitError.authorizationDenied
    }
    // ... implementation
}

// View layer - handle gracefully
func loadData() async {
    do {
        let episodes = try await service.fetchEpisodes()
        self.episodes = episodes
    } catch {
        // Show fallback data or log
        self.episodes = fallbackData
    }
}
```

### Accessibility

- Use semantic fonts (respects Dynamic Type)
- Use SF Symbols (built-in accessibility)
- Prefer `Button` over `onTapGesture` (free VoiceOver support)
- Add `.accessibilityLabel()` for custom elements

### API Availability

```swift
// Always gate newer APIs
if #available(iOS 26.0, *) {
    content.glassEffect(...)
} else {
    content.background(.ultraThinMaterial, ...)
}
```

---

## Available Skills

This project has specialized skills in `.agents/skills/`:

| Skill | Purpose |
|-------|---------|
| `ios-swift-development` | Swift, SwiftUI, MVVM, async/await, HealthKit |
| `mobile-ios-design` | iOS HIG, SwiftUI layouts, navigation, SF Symbols |
| `swiftui-expert-skill` | Advanced SwiftUI, state management, performance, iOS 26+ APIs |

---

## Important Notes

- **This is NOT a medical device** — do not add diagnostic features
- Health data must remain on-device and under user control
- Prioritize clarity and simplicity in UI
- Test on physical devices for HealthKit features (simulator limitations)
