# Architecture Research

**Domain:** iOS Health Monitoring Application
**Researched:** 2026-03-10
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Dashboard   │  │ Timeline    │  │ Episode Detail     │ │
│  │ View        │  │ View        │  │ View               │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                      │             │
│         └────────────────┴──────────────────────┘             │
│                          ↓                                      │
├──────────────────────────┬────────────────────────────────────┤
│                   ViewModel Layer                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Dashboard   │  │ Rhythm      │  │ Episode            │ │
│  │ ViewModel   │  │ ViewModel   │  │ ViewModel          │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                      │             │
│         └────────────────┴──────────────────────┘             │
│                          ↓                                      │
├─────────────────────────────────────────────────────────────┤
│                   Domain Layer                                 │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │              HealthKitService                         │    │
│  │  - Authorization management                          │    │
│  │  - Query execution                                    │    │
│  │  - Data transformation                                │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              AnalysisEngine                          │    │
│  │  - AF burden calculation                              │    │
│  │  - Trend analysis                                     │    │
│  │  - Pattern detection                                  │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│                   Data Layer                                   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │ HealthKit │  │ Local    │  │ Domain   │                 │
│  │ Store     │  │ Cache    │  │ Models   │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| HealthKitService | All HealthKit interactions: authorization, queries, data fetching | Singleton with HKHealthStore, async/await query methods |
| AnalysisEngine | Business logic for AF burden, trends, pattern detection | Pure Swift functions, stateless calculations |
| DashboardViewModel | Aggregates current state, recent episodes, summary metrics | @Observable @MainActor class |
| RhythmViewModel | Manages rhythm timeline data, date filtering | @Observable @MainActor class |
| EpisodeViewModel | Episode list, detail views, filtering | @Observable @MainActor class |
| Domain Models | Pure data structures for rhythm, episodes, metrics | Swift structs, Codable |

## Recommended Project Structure

```
AFOne/
├── App/
│   ├── AFOneApp.swift          # App entry point
│   └── AppState.swift           # Global app state
├── Core/
│   ├── HealthKit/
│   │   ├── HealthKitService.swift       # HKHealthStore wrapper
│   │   ├── HealthKitTypes.swift          # Type definitions
│   │   └── HealthKitError.swift          # Error types
│   └── Analysis/
│       ├── AFBurdenCalculator.swift     # Burden calculations
│       ├── TrendAnalyzer.swift          # Trend detection
│       └── PatternDetector.swift         # Pattern analysis
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── DashboardViewModel.swift
│   ├── Rhythm/
│   │   ├── RhythmTimelineView.swift
│   │   ├── RhythmViewModel.swift
│   │   └── RhythmSegmentView.swift
│   ├── Episodes/
│   │   ├── EpisodeListView.swift
│   │   ├── EpisodeDetailView.swift
│   │   └── EpisodeViewModel.swift
│   └── Reports/
│       ├── ReportView.swift
│       └── ReportGenerator.swift
├── Models/
│   ├── RhythmEpisode.swift     # AF episode data
│   ├── HeartRateReading.swift  # Individual readings
│   ├── AFBurden.swift          # Burden metrics
│   └── TrendData.swift         # Trend information
├── Shared/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   └── HKUnit+Extensions.swift
│   ├── Components/
│   │   ├── HeartRateChart.swift
│   │   └── MetricCard.swift
│   └── Constants/
│       └── HealthKitConstants.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### Structure Rationale

- **Core/HealthKit:** Centralizes all HealthKit interactions in one service. Single responsibility: talk to HealthKit. Other components never interact directly with HKHealthStore.

- **Core/Analysis:** Pure business logic separated from UI. These functions are testable without UI or HealthKit dependencies. No side effects.

- **Features/**: Each feature module contains its View and ViewModel together. This keeps related code co-located and makes feature addition/removal straightforward.

- **Models/:** Domain models that are independent of both HealthKit and SwiftUI. These represent the app's domain concepts (Episode, Burden, Reading).

- **Shared/:** Reusable UI components and extensions used across features.

## Architectural Patterns

### Pattern 1: MVVM with @Observable

**What:** Model-View-ViewModel pattern using Swift's @Observable macro for reactive state management.

**When to use:** Standard choice for SwiftUI apps targeting iOS 17+. Provides clean separation between UI (Views), business logic (ViewModels), and data (Models).

**Trade-offs:**
- Pros: Native SwiftUI integration, automatic invalidation, testable
- Cons: Requires iOS 17+ for @Observable (or use @ObservableObject for broader compatibility)

**Example:**
```swift
@Observable
@MainActor
class DashboardViewModel {
    var currentHeartRate: Double = 0
    var recentEpisodes: [RhythmEpisode] = []
    var afBurden: AFBurden?
    
    func loadData() async {
        let service = HealthKitService.shared
        currentHeartRate = try await service.fetchLatestHeartRate()
        recentEpisodes = try await service.fetchRecentEpisodes(limit: 5)
        afBurden = AnalysisEngine.calculateBurden(from: recentEpisodes)
    }
}
```

### Pattern 2: HealthKit Service Facade

**What:** A single service class that wraps all HealthKit interactions, providing a clean API to the rest of the app.

**When to use:** Required for any HealthKit integration. Centralizes authorization, query logic, and error handling.

**Trade-offs:**
- Pros: Single entry point for HealthKit, easy to mock in tests, centralizes error handling
- Cons: Can become a "god class" if not carefully organized

**Example:**
```swift
@MainActor
class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    
    // Authorization
    func requestAuthorization() async throws
    
    // Queries
    func fetchHeartRateSamples(from: Date, to: Date) async throws -> [HeartRateReading]
    func fetchECGReadings() async throws -> [ECGReading]
    func fetchAFBurden() async throws -> AFBurden?
    func fetchEpisodes() async throws -> [RhythmEpisode]
}
```

### Pattern 3: Stateless Analysis Engine

**What:** Pure functions for data analysis that transform input data into meaningful metrics without side effects.

**When to use:** Any business logic that transforms health data into insights. Keeps analysis testable and independent of data sources.

**Trade-offs:**
- Pros: Highly testable, no dependencies, deterministic
- Cons: Must pass all data explicitly;不适合需要实时更新的场景

**Example:**
```swift
struct AnalysisEngine {
    static func calculateBurden(from episodes: [RhythmEpisode], window: TimeWindow) -> AFBurden {
        let totalDuration = window.duration
        let afDuration = episodes.reduce(0) { $0 + $1.duration }
        return AFBurden(percentage: afDuration / totalDuration, window: window)
    }
    
    static func detectTrends(in readings: [HeartRateReading]) -> [TrendData] {
        // Pure transformation logic
    }
}
```

### Pattern 4: Query-Based Data Fetching

**What:** HealthKit uses query descriptors to fetch data. Combine multiple queries for different data types.

**When to use:** When fetching health data from HealthKit. Use appropriate query types for different data needs.

**Trade-offs:**
- Pros: Efficient, Apple-optimized, supports background delivery
- Cons: Complex predicate syntax, asynchronous by nature

**Example:**
```swift
func fetchHeartRateSamples(from startDate: Date, to endDate: Date) async throws -> [HeartRateReading] {
    let heartRateType = HKQuantityType(.heartRate)
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
    let descriptor = HKSampleQueryDescriptor(
        predicates: [.sample(type: heartRateType, predicate: predicate)],
        sortDescriptors: [.init(\.endDate, order: .reverse)]
    )
    
    let samples = try await descriptor.result(for: healthStore)
    return samples.map { HeartRateReading(from: $0) }
}
```

## Data Flow

### Primary Data Flow: HealthKit to UI

```
┌──────────────────────────────────────────────────────────────────┐
│                        User Launches App                          │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│              DashboardViewModel.loadData()                        │
│                      (onAppear trigger)                          │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│              HealthKitService.requestAuthorization()              │
│                    (first launch only)                            │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│    HealthKitService fetches in parallel:                          │
│    - Heart rate samples (HKSampleQuery)                          │
│    - ECG readings (HKSampleQuery)                                 │
│    - AF burden (HKQuantityQuery)                                 │
│    - Activity summaries                                          │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│         Domain Models created from HealthKit data                 │
│         (transformation layer)                                    │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│         AnalysisEngine calculates:                               │
│         - AF burden percentages                                   │
│         - Trend data                                             │
│         - Episode statistics                                     │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│         ViewModel state updated (@Observable triggers UI)        │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│         SwiftUI Views re-render with new data                     │
└──────────────────────────────────────────────────────────────────┘
```

### Secondary Flow: Background Updates

```
Apple Watch detects AF episode
        ↓
HealthKit stores new sample
        ↓
App receives background notification (if enabled)
        ↓
HealthKitService performs observer query
        ↓
New episode processed and stored locally
        ↓
ViewModel notified of changes
        ↓
UI updates if visible
```

### Key Data Flows

1. **Initial Load:** Authorization → Parallel queries → Model transformation → Analysis → UI update
2. **Date Range Filter:** User selects date range → ViewModel queries with predicate → New data → Analysis → UI update
3. **Background Refresh:** Observer query triggers → Fetch latest → Update models → UI refresh
4. **Report Generation:** User requests report → Gather all relevant data → Generate PDF → Share

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-1k users | Single HealthKitService instance, in-memory caching sufficient |
| 1k-100k users | Add local cache layer (SwiftData) for frequently accessed data; consider query result caching |
| 100k+ users | With offline-first and HealthKit as source-of-truth, scaling is less critical. Focus on efficient query predicates to limit data volume. |

### Scaling Priorities

1. **First consideration:** Query performance. HealthKit queries can be slow with large date ranges. Always predicate to the minimum necessary date range.

2. **Second consideration:** UI responsiveness. Move heavy analysis calculations to background tasks using Task.detached.

3. **Third consideration:** Memory usage. Large ECG datasets can consume memory. Consider lazy loading and pagination for history views.

## Anti-Patterns

### Anti-Pattern 1: Direct HealthKit Access in Views

**What people do:** Calling HKHealthStore methods directly from SwiftUI views or using @Query-like patterns.

**Why it's wrong:** Violates separation of concerns, makes testing impossible, creates HealthKit dependencies in UI layer.

**Do this instead:** Always go through HealthKitService. Views interact only with ViewModels.

### Anti-Pattern 2: Heavy Computation on Main Actor

**What people do:** Running AF burden calculations or trend analysis synchronously on the main thread.

**Why it's wrong:** Can cause UI stuttering, especially with large datasets. HealthKit queries are already async; analysis should be too.

**Do this instead:** Use Task.detached for heavy analysis, update @Observable state on MainActor when complete.

### Anti-Pattern 3: Caching HealthKit Data

**What people do:** Copying all HealthKit data to local storage for "performance."

**Why it's wrong:** Creates data duplication, synchronization issues, and defeats the purpose of HealthKit as the single source of truth. HealthKit is already optimized.

**Do this instead:** Query HealthKit directly. If caching needed for offline UI responsiveness, cache only computed results (burden percentages, trends), not raw data.

### Anti-Pattern 4: Ignoring Authorization States

**What people do:** Assuming authorization is granted without checking, or not handling denied states.

**Why it's wrong:** Users can revoke HealthKit access at any time. App must handle all authorization states gracefully.

**Do this instead:** Check authorization status on launch, observe changes, provide clear UI for each state (authorized, denied, notDetermined).

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Apple HealthKit | Direct framework integration | Requires HealthKit capability and entitlements |
| Apple Watch | Indirect via HealthKit | Watch collects data; iOS app queries through HealthKit |
| Share Sheet | UIActivityViewController | For exporting clinical reports |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| HealthKitService ↔ AnalysisEngine | Function parameters | AnalysisEngine is stateless; data passed in |
| ViewModels ↔ HealthKitService | async/await | All calls are async; ViewModels are @MainActor |
| Views ↔ ViewModels | @Observable property access | Views read @Observable properties; system handles refresh |
| Models ↔ HealthKit | Transformation functions | Models are plain Swift; HKObject conversion happens in service |

## Build Order Implications

Based on component dependencies, implement in this order:

1. **Phase 1: Foundation**
   - HealthKitService with authorization and basic queries
   - Domain models (RhythmEpisode, HeartRateReading)
   - Basic SwiftUI view scaffold

2. **Phase 2: Core Features**
   - DashboardViewModel and DashboardView
   - Timeline visualization
   - Episode list and detail

3. **Phase 3: Analysis**
   - AnalysisEngine calculations
   - Trend detection
   - Burden percentage computations

4. **Phase 4: Advanced**
   - Report generation
   - Background update handling
   - Notification integration

### Dependency Graph

```
HealthKitService ← DashboardViewModel ← DashboardView
       ↓                   ↓
   Models           AnalysisEngine
       ↑                   ↑
   (no deps)    ← (pure functions)
```

HealthKitService has no dependencies (build first). AnalysisEngine is stateless (build anytime, but needed for meaningful dashboards). ViewModels depend on both (build after). Views depend only on ViewModels (build last).

## Sources

- Apple Developer Documentation: HealthKit (https://developer.apple.com/documentation/healthkit)
- Apple Developer Documentation: HKQuantityTypeIdentifier.atrialFibrillationBurden (https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/atrialfibrillationburden)
- Apple Developer Documentation: HKElectrocardiogram (https://developer.apple.com/documentation/healthkit/hkelectrocardiogram)
- Create with Swift: Reading data from HealthKit in a SwiftUI app (https://www.createwithswift.com/reading-data-from-healthkit-in-a-swiftui-app/)
- Medium: Architecting a Modular HealthKit Manager in Swift (https://medium.com/apps-2-develop/architecting-a-modular-healthkit-manager-in-swift-72bddef5573d)
- Medium: Setting Up a Health Tracking App Using HealthKit with MVVM Architecture in SwiftUI (https://medium.com/@anthonygfrn/setting-up-a-health-tracking-app-using-healthkit-with-mvvm-architecture-in-swiftui-4faa547b8e20)

---
*Architecture research for: AFOne - iOS Heart Rhythm Monitoring Application*
*Researched: 2026-03-10*
