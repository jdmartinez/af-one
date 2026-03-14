# Technology Stack

**Project:** AFOne - iOS Heart Rhythm Monitoring App
**Researched:** 2026-03-10, updated 2026-03-13 for v0.2
**Confidence:** HIGH

## Recommended Stack

### Core Framework

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **SwiftUI** | iOS 18+ target, iOS 16+ minimum | UI Framework | Industry standard for modern iOS health apps. Native SwiftUI Charts integration, declarative syntax aligns with health data patterns. iOS 18 adds significant Swift Charts improvements including 3D visualization. |
| **Swift** | 5.9+ | Language | Required for modern SwiftUI and Observation framework |

### Data & Health Integration

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **HealthKit** | Native (iOS 16+ for AF features) | Apple Health data access | The only way to read Apple Watch rhythm data. AF burden (iOS 16+), ECG readings, and heart rate data are all available. Key types: `HKQuantityTypeIdentifier.heartRate`, `HKQuantityTypeIdentifier.atrialFibrillationBurden`, `HKElectrocardiogram` |
| **SwiftData** | iOS 17+ | Local data persistence | For caching health data locally and storing user-entered symptoms, notes. Officially replaces Core Data for new projects. Native SwiftUI integration, @Model macro for schema definition. |
| **CloudKit** | Native | Future cloud sync (if needed) | Apple-native solution for iCloud backup if the app expands beyond offline-first |

### Charts & Visualization

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **Swift Charts** | Native (iOS 16+, iOS 18 enhanced) | Primary visualization | Apple's native framework for SwiftUI. Declarative syntax matches SwiftUI patterns. Supports timeline visualization, heart rate line charts, AF burden bars. iOS 18 adds 3D Chart API for advanced visualization. |
| **DGCharts** | 5.1.0 | Advanced chart requirements | Use only if Swift Charts lacks specific capabilities (complex real-time streaming, custom financial-style candlesticks). DGCharts (formerly Charts) has 27k+ stars, mature UIKit integration. SPM: `https://github.com/ChartsOrg/Charts.git` |

**Recommendation:** Use Swift Charts exclusively. Only add DGCharts if specific requirements emerge that Swift Charts cannot handle.

### Architecture & State Management

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **Swift Observation** | iOS 17+ | State management | Modern replacement for Combine-based ObservableObject. @Observable macro eliminates boilerplate. Better performance for health data updates. |
| **Combine** | Native | Reactive streams | Still needed for HealthKit observer queries and async data processing pipelines. Works alongside Observation. |
| **MVVM + Clean Architecture** | — | Architecture pattern | Health data apps benefit from clean separation: Presentation (Views/ViewModels) → Domain (Use Cases/Entities) → Data (Repositories/Services). MVVM with SwiftUI bindings is industry standard for health apps in 2025-2026. |

### Dependency Injection

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **SwiftUI Environment** | Native (iOS 17+) | Primary DI | Use `@Environment` and `@Environmentable` protocols for service injection. Follows Apple's guidance. |
| **Protocol-oriented services** | Native | Abstraction layer | Define protocols for HealthKitService, Repository, etc. Inject concrete implementations at app entry point. |
| **Swinject** | 2.10+ | DI Container (optional) | Only if complex multi-module architecture needed. For a single-target app, SwiftUI Environment + protocols are sufficient. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **Swift Collections** | 1.1+ | OrderedDictionary, Deque | When handling time-series health data that requires ordered key-value access |
| **Charts** | See above | — | — |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| UI Framework | SwiftUI | UIKit | SwiftUI has native HealthKit integration patterns, Charts support, and is Apple's strategic direction. UIKit only needed for specific legacy components. |
| Charts | Swift Charts | DGCharts | Swift Charts is native, actively developed by Apple, integrates with SwiftUI, and handles health data use cases well. DGCharts adds UIKit complexity unnecessarily. |
| State Management | Swift Observation | TCA (The Composable Architecture) | TCA adds complexity for a focused health monitoring app. Swift Observation provides 90% of benefits with simpler mental model. |
| Persistence | SwiftData | SQLite.swift | SwiftData is Apple's modern recommendation, native SwiftUI integration, and sufficient for symptom logging/cache. |
| DI | Environment + Protocols | Hilt/Dagger | No third-party DI needed for this app scope. SwiftUI's Environment provides adequate testability. |

## What NOT to Use

| Library/Pattern | Why Avoid |
|-----------------|-----------|
| **UIKit** (for new features) | Adds unnecessary complexity when SwiftUI handles all health app requirements. Only use for migration from existing UIKit apps. |
| **Core Data** | SwiftData is the modern replacement. Core Data has heavier overhead and worse SwiftUI integration. |
| **Combine-only ObservableObject** | Replaced by Swift Observation (@Observable) in iOS 17+. More performant for frequent health data updates. |
| **Third-party chart libraries** | Swift Charts handles all health visualization needs. Avoids extra dependencies. |
| **Backend/cloud infrastructure** | Project explicitly requires offline-first with no backend. |
| **Firebase/analytics SDKs** | Conflicts with privacy-first, on-device-only requirement. |

## HealthKit Specific Data Types

For AFOne's heart rhythm monitoring, these HealthKit types are relevant:

```swift
// Heart Rate - continuous series from Apple Watch
HKQuantityTypeIdentifier.heartRate

// AF Burden - percentage of time in AF (iOS 16+, watchOS 9+)
// Read-only, calculated weekly by iOS
HKQuantityTypeIdentifier.atrialFibrillationBurden

// ECG Recordings - stored on Apple Watch
HKObjectType.electrocardiogramType()

// Heart Rate Variability
HKQuantityTypeIdentifier.heartRateVariabilitySDNN

// Step Count, Exercise Minutes - for correlation analysis
HKQuantityTypeIdentifier.stepCount
HKQuantityTypeIdentifier.appleExerciseTime
```

## Installation

```swift
// Package.swift dependencies (if using SPM)
dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
    // DGCharts - only if Swift Charts proves insufficient
    // .package(url: "https://github.com/ChartsOrg/Charts.git", from: "5.1.0"),
]

// No external dependencies required for core functionality
// All frameworks above are native Apple frameworks
```

## Minimum Deployment Target

- **iOS 17+** (recommended) — Enables SwiftData, Swift Observation, latest Swift Charts features
- **iOS 16+** (minimum) — If broader device support needed, but loses SwiftData and some Observation benefits

Given AFOne targets users who own Apple Watch (Series 4+ for ECG, Series 1+ for heart rhythm), iOS 17+ is appropriate as these users typically have modern iPhones.

## Sources

- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit) — HIGH confidence
- [Swift Charts Documentation](https://developer.apple.com/documentation/Charts) — HIGH confidence
- [HealthKit AF Burden Type](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/atrialfibrillationburden) — HIGH confidence
- [Swift Charts 2025 Updates](https://developer.apple.com/documentation/updates/swiftcharts) — HIGH confidence
- [DGCharts Swift Package Index](https://swiftpackageindex.com/ChartsOrg/Charts) — MEDIUM confidence (community library)
- [iOS Architecture 2025](https://medium.com/@rashadsh/mvvm-vs-viper-vs-tca-best-architecture-for-your-next-app-159e11e333e9) — MEDIUM confidence (community article)
- [SwiftUI HealthKit Integration](https://www.createwithswift.com/reading-data-from-healthkit-in-a-swiftui-app/) — MEDIUM confidence (tutorial)

---

# v0.2 UI Enhancements — Stack Additions

## iOS 26 Liquid Glass

- **API:** `.glassEffect()` modifier — applies Liquid Glass material to any view
- **Variants:** `.regular` (standard), `.clear` (specialized), `.interactive` (touch feedback)
- **Shape:** Custom shapes via `in: Shape` parameter (RoundedRectangle, Capsule, Circle)
- **Tint:** `.tint()` for accent coloring on glass surfaces
- **Container:** `GlassEffectContainer` for grouping multiple glass elements
- **Collapse on scroll:** `tabBarMinimizeBehavior(.onScroll)` for iPhone tab bars
- **Key Point:** Use native SwiftUI — iOS 26 automatically applies Liquid Glass to TabView

## Dark/Light Theme Support

- **Semantic Colors:** `.primary`, `.secondary`, `.background`, `.systemBackground`
- **Environment:** `@Environment(\.colorScheme) var colorScheme`
- **Asset Catalogs:** Create Color Sets with "Any, Dark" appearances for custom adaptive colors
- **Override:** `.preferredColorScheme(.dark)` / `.light` / `nil` (system)
- **Key Point:** Use asset catalog colors with Any/Dark variants, avoid hardcoded colors

## Localization

- **String Catalogs:** `.xcstrings` format — Xcode's recommended approach
- **API:** `String(localized:)`, `Text("key")`, `LocalizedStringKey`
- **Environment:** `@Environment(\.locale) var locale`
- **RTL:** Use `.leading`/`.trailing` instead of `.left`/`.right`, `layoutDirection` environment
- **Pluralization:** Use `.stringsdict` for complex plural rules

## What NOT to Add

| Pattern | Avoid | Use Instead |
|---------|-------|-------------|
| Manual blur | Custom UIVisualEffectView | Native `.glassEffect()` |
| Custom nav | Custom tab implementations | NavigationStack/TabView |
| Hardcoded colors | `.red`, `.blue`, `.white` | Semantic colors, asset catalogs |
| Raw strings | `NSLocalizedString` | String Catalogs `.xcstrings` |

## Integration Points

| Feature | Existing Code | Integration |
|---------|--------------|-------------|
| Dark/Light theme | ColorScheme (existing) | Add asset catalog colors, review all hardcoded colors |
| Dashboard redesign | DashboardView.swift | Restyle cards, add semantic colors |
| Liquid Glass tab | TabView (existing) | Add `.glassEffect()` to custom tabs, test collapse behavior |
| Localization | All Views | Add String Catalog, wrap strings |
| Navigation fixes | MoreView, ReportView | Review navigation structure |

## Sources

- [Apple WWDC25 - Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/) — HIGH confidence
- [Liquid Glass SwiftUI Guide](https://swiftcrafted.dev/article/mastering-liquid-glass-swiftui-complete-guide-ios-26-design-language) — HIGH confidence
- [SwiftUI Dark Mode Best Practices](https://medium.com/@chandra.welim/dark-mode-implement-it-right-or-dont-implement-it-at-all-9960616ce1b7) — HIGH confidence
- [iOS Localization with SwiftUI](https://intlpull.com/blog/swift-ios-localization-complete-guide-2026) — HIGH confidence
- **[Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) — PRIMARY REFERENCE**
