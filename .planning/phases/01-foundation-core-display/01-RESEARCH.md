# Phase 1: Foundation & Core Display - Research

**Researched:** 2026-03-11
**Domain:** iOS HealthKit Integration, SwiftUI Data Visualization, Local Persistence
**Confidence:** HIGH

## Summary

Phase 1 establishes the core infrastructure for reading Apple Health data and displaying heart rhythm information. The key technical foundation is **HealthKit integration** for reading AF burden, heart rate, and ECG data from Apple Watch. SwiftData provides local persistence for caching health data (offline-first), while Swift Charts enables timeline and burden visualization. The project correctly identifies that **background sync is unreliable** - HealthKit's HKObserverQuery and background delivery have inconsistent behavior, making foreground refresh on app launch the reliable pattern.

**Primary recommendation:** Use Swift Charts + SwiftData as the core stack with a dedicated HealthKit service layer following Clean Architecture. Implement foreground refresh on launch rather than relying on background delivery.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| **HealthKit** | Native (iOS 8+) | Read heart rhythm data from Apple Watch | Required for accessing AF burden, heart rate, ECG data |
| **SwiftData** | Native (iOS 17+) | Local data persistence | Native replacement for Core Data; works offline-first |
| **Swift Charts** | Native (iOS 16+) | Data visualization | Apple-native declarative charting framework |
| **SwiftUI** | Native | User interface | Project requirement; modern iOS UI |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **UserNotifications** | Native | Local notifications | NOTIF-01: AF episode detection alerts |
| **Combine** | Native | Reactive data flow | Binding HealthKit queries to SwiftUI views |

### Installation
No external packages required - all frameworks are native Apple frameworks.

```swift
// Required capabilities in Xcode:
// - HealthKit
// - Background Modes (for notifications, if needed)
```

---

## Architecture Patterns

### Recommended Project Structure

```
AFOne/
├── App/
│   └── AFOneApp.swift
├── Features/
│   ├── Dashboard/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Episodes/
│   ├── Timeline/
│   ├── Emergency/
│   └── Settings/
├── Core/
│   ├── HealthKit/
│   │   ├── HealthKitService.swift
│   │   ├── Models/
│   │   └── Queries/
│   ├── Persistence/
│   │   └── DataManager.swift
│   └── Notifications/
│       └── NotificationService.swift
├── Domain/
│   ├── Models/
│   │   ├── RhythmStatus.swift
│   │   ├── Episode.swift
│   │   └── AfBurden.swift
│   └── UseCases/
├── Shared/
│   ├── Components/
│   ├── Extensions/
│   └── Theme/
└── Resources/
    └── Assets.xcassets
```

### Pattern 1: Clean Architecture with SwiftUI

**What:** Separate app into Domain, Data, and Presentation layers
**When to use:** All features in Phase 1
**Why:** Testability, maintainability, clear data flow

```
Presentation Layer (SwiftUI Views + ViewModels)
    ↓ reads/writes
Domain Layer (Use Cases, Domain Models)
    ↓ depends on
Data Layer (HealthKitService, SwiftData Repositories)
```

**Key insight:** The iOS 17+ SwiftUI ecosystem (SwiftData + @Observable) simplifies traditional Clean Architecture. Keep business logic in Services/UseCases, not in Views.

### Pattern 2: MVVM with @Observable (iOS 17+)

**What:** ViewModels as observable objects that hold UI state
**When to use:** All SwiftUI views in Phase 1
**Example:**

```swift
// Source: Apple SwiftUI Documentation + iOS 17+ patterns
import SwiftUI
import HealthKit
import SwiftData

@Observable
final class DashboardViewModel {
    var currentStatus: RhythmStatus = .unknown
    var recentEpisodes: [Episode] = []
    var afBurden: AfBurden?
    var isLoading = false
    var errorMessage: String?
    
    private let healthKitService: HealthKitService
    
    @MainActor
    func loadData() async {
        isLoading = true
        // Fetch from HealthKit
        // Update state
        isLoading = false
    }
}
```

### Pattern 3: Repository Pattern for HealthKit

**What:** Abstract HealthKit access behind repository protocols
**When to use:** When you need to mock HealthKit for testing or cache data locally
**Why:** HealthKit queries are async and can fail; repository provides consistent interface

```swift
// Source: Apple HealthKit Documentation
protocol HealthRepositoryProtocol {
    func requestAuthorization() async throws
    func fetchAfBurden(from: Date, to: Date) async throws -> [AfBurdenSample]
    func fetchEpisodes(from: Date, to: Date) async throws -> [Episode]
    func fetchHeartRateSamples(from: Date, to: Date) async throws -> [HeartRateSample]
}

final class HealthKitRepository: HealthRepositoryProtocol {
    private let healthStore = HKHealthStore()
    
    // Implementation queries HealthKit
}
```

### Anti-Patterns to Avoid

- **Don't put HealthKit queries directly in Views** - Violates separation of concerns, hard to test
- **Don't assume background delivery works reliably** - HKObserverQuery has inconsistent behavior; always implement foreground refresh
- **Don't write to HealthKit** - AF burden samples are read-only; Apple Watch generates them
- **Don't skip error handling for HealthKit authorization** - Users can deny permissions; handle gracefully

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| **Health data persistence** | Custom SQLite/JSON storage | SwiftData | Native, efficient, automatic schema migration |
| **Chart visualizations** | Custom drawing/Core Graphics | Swift Charts | Accessible, performant, declarative |
| **Date/time calculations** | Manual date math | Swift Date/TimeInterval | Handles time zones, locales correctly |
| **Notification scheduling** | Custom timer-based alerts | UNUserNotificationCenter | Battery-efficient, system-managed |

**Key insight:** For this health app, all data ultimately comes from HealthKit - you cannot write AF burden data, only read it. This means local persistence is for caching metadata, user preferences, and any Phase 2+ user-entered data (symptoms, triggers).

---

## Common Pitfalls

### Pitfall 1: HealthKit Background Delivery Unreliability
**What goes wrong:** HKObserverQuery callbacks don't fire consistently; background delivery is throttled unpredictably
**Why it happens:** iOS manages background execution aggressively; Apple Watch data syncs intermittently
**How to avoid:** Always implement foreground refresh on app launch. Use HKObserverQuery as supplement, not primary data sync mechanism.
**Warning signs:** Data not updating despite new Apple Watch readings; callbacks fire hours late

### Pitfall 2: AF Burden Data Availability
**What goes wrong:** AF burden samples only appear after user enables "AF History" in Apple Watch settings
**Why it happens:** Apple Watch only calculates AF burden when user opts in; calculation happens weekly (~Monday 8am)
**How to avoid:** Check if AF burden type is available; show appropriate messaging if no data
**Warning signs:** Empty AF burden despite having Apple Watch - likely AF History not enabled

### Pitfall 3: Privacy Permission Handling
**What goes wrong:** App doesn't handle denied HealthKit permissions gracefully
**Why it happens:** iOS doesn't reveal whether user granted/denied permission - apps only know if data returns empty
**How to avoid:** Design UI that shows meaningful empty states; explain what data is needed and why
**Warning signs:** All HealthKit queries return empty after user taps "Don't Allow"

### Pitfall 4: Health Data Privacy (FOUN-03, FOUN-04)
**What goes wrong:** Accidentally sending health data to external services or logging sensitive info
**Why it happens:** Easy to accidentally include health data in analytics, crash logs, or network requests
**How to avoid:** Explicitly design for offline-first; audit all data flows; use NSHealthShareUsageDescription
**Warning signs:** Health data appearing in network traffic or crash reports

### Pitfall 5: Medical Device Claims (FOUN-02)
**What goes wrong:** App language or UI suggests medical diagnosis or treatment recommendations
**Why it happens:** Easy to inadvertently use clinical-sounding language
**How to avoid:** Prominent "Not a medical device" disclaimer on launch; use neutral terms like "heart rhythm information" not "diagnosis"
**Warning signs:** Terms like "diagnosis," "treatment," "condition" - should use "heart rhythm data"

---

## Code Examples

### HealthKit Service - Request Authorization

```swift
// Source: Apple HealthKit Documentation
import HealthKit

final class HealthKitService {
    private let healthStore = HKHealthStore()
    
    // Types to read for Phase 1
    private var typesToRead: Set<HKObjectType> {
        [
            HKQuantityType(.atrialFibrillationBurden),
            HKQuantityType(.heartRate),
            HKObjectType.electrocardiogramType(),
            HKSeriesType.heartbeat(),
        ]
    }
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
}
```

### Fetch AF Burden

```swift
// Source: Apple HealthKit Documentation
func fetchAfBurden(from startDate: Date, to endDate: Date) async throws -> [HKQuantitySample] {
    let afBurdenType = HKQuantityType(.atrialFibrillationBurden)
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    return try await withCheckedThrowingContinuation { continuation in
        let query = HKSampleQuery(
            sampleType: afBurdenType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
        }
        healthStore.execute(query)
    }
}
```

### Fetch Heart Rate for Episode

```swift
// Source: Apple HealthKit Documentation
func fetchHeartRateSamples(during episode: Episode) async throws -> [HKQuantitySample] {
    let heartRateType = HKQuantityType(.heartRate)
    let predicate = HKQuery.predicateForSamples(
        withStart: episode.startDate,
        end: episode.endDate,
        options: .strictEndDate
    )
    
    return try await withCheckedThrowingContinuation { continuation in
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
        }
        healthStore.execute(query)
    }
}
```

### Swift Charts - AF Burden Timeline

```swift
// Source: Apple Swift Charts Documentation
import SwiftUI
import Charts

struct AfBurdenChartView: View {
    let burdenData: [AfBurdenDataPoint]
    
    var body: some View {
        Chart(burdenData) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("AF Burden", point.burdenPercentage)
            )
            .foregroundStyle(.red)
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Date", point.date),
                y: .value("AF Burden", point.burdenPercentage)
            )
            .foregroundStyle(.red.opacity(0.1))
            .interpolationMethod(.catmullRom)
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                    }
                }
            }
        }
    }
}
```

### Local Notification for AF Detection

```swift
// Source: Apple UserNotifications Documentation
import UserNotifications

final class NotificationService {
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleAfEpisodeNotification(episode: Episode) {
        let content = UNMutableNotificationContent()
        content.title = "AF Episode Detected"
        content.body = "An atrial fibrillation episode was recorded on \(episode.startDate.formatted())"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: episode.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| **Core Data** | **SwiftData** | iOS 17 (2023) | Less boilerplate, @Query property wrapper, native Swift concurrency |
| **Manual HealthKit queries** | **Swift Concurrency + AsyncSequence** | iOS 15+ | Cleaner async/await patterns, no callback hell |
| **UIKit Charts** | **Swift Charts** | iOS 16 (2022) | Declarative, accessible by default, less code |
| **Background App Refresh** | **Foreground refresh on launch** | Now - understanding background is unreliable | More reliable data sync |

**Deprecated/outdated:**
- **HKObserverQuery for critical data** - Unreliable for heart rhythm monitoring; use as supplement only
- **Core Data for new projects** - SwiftData is the modern replacement for iOS 17+
- **Third-party charting libraries** - Swift Charts provides native equivalent with better accessibility

---

## Open Questions

1. **Minimum iOS version?**
   - What we know: SwiftData requires iOS 17+, Swift Charts requires iOS 16+
   - What's unclear: Does project target iOS 17+ or support iOS 16?
   - Recommendation: Target iOS 17+ to use SwiftData natively; otherwise use Core Data alternative

2. **AF History availability?**
   - What we know: AF burden requires user to enable AF History on Apple Watch (watchOS 9+)
   - What's unclear: How to gracefully handle users without AF History enabled
   - Recommendation: Show informative message explaining AF History requirement

3. **Emergency data storage?**
   - What we know: Apple Health stores Medical ID; EMER-01/EMER-02 require quick access
   - What's unclear: Should we read from Medical ID or store separately?
   - Recommendation: Store emergency info in-app for faster access; sync from Health if available

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (native) |
| Config file | None - use default Xcode test setup |
| Quick run command | `xcodebuild test -scheme AFOne -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AFOneTests.UnitTests -quiet` |
| Full suite command | `xcodebuild test -scheme AFOne -destination 'platform=iOS Simulator,name=iPhone 16'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FOUN-01 | Reads heart rhythm data from HealthKit | Unit | `xcodebuild test ... -only-testing:AFOneTests.HealthKitServiceTests` | ✅ Wave 0 |
| FOUN-02 | Disclaimer shown on launch | UI/Smoke | Manual verification required | ✅ Wave 0 |
| FOUN-03 | Health data stays on device | Architecture | Code review | ❌ Wave 0 |
| FOUN-04 | User controls data sharing | UI/Smoke | Manual verification required | ❌ Wave 0 |
| FOUN-05 | Works offline | Integration | `xcodebuild test ... -only-testing:AFOneTests.OfflineTests` | ❌ Wave 0 |
| DASH-01 | Current rhythm context on launch | Unit/UI | `xcodebuild test ... -only-testing:AFOneTests.DashboardTests` | ❌ Wave 0 |
| DASH-02 | 7-day AF summary | Unit | `xcodebuild test ... -only-testing:AFOneTests.AfBurdenTests` | ❌ Wave 0 |
| DASH-03 | AF burden + episode count | Unit | `xcodebuild test ... -only-testing:AFOneTests.EpisodeTests` | ❌ Wave 0 |
| OVER-01 | Rhythm monitoring overview | UI | Manual verification | ❌ Wave 0 |
| TIME-01 | Rhythm status timeline | Unit/UI | `xcodebuild test ... -only-testing:AFOneTests.TimelineTests` | ❌ Wave 0 |
| EPIS-01 | Episode history | Unit | `xcodebuild test ... -only-testing:AFOneTests.EpisodeTests` | ❌ Wave 0 |
| EPIS-02 | Episode timestamp + duration | Unit | `xcodebuild test ... -only-testing:AFOneTests.EpisodeTests` | ❌ Wave 0 |
| EPIS-03 | Heart rate during episode | Unit | `xcodebuild test ... -only-testing:AFOneTests.HeartRateTests` | ❌ Wave 0 |
| EMER-01 | Quick emergency access | UI | Manual verification | ❌ Wave 0 |
| EMER-02 | Emergency info display | UI | Manual verification | ❌ Wave 0 |
| NOTIF-01 | AF notification | Integration | `xcodebuild test ... -only-testing:AFOneTests.NotificationTests` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** Unit tests for affected components
- **Per wave merge:** Full test suite
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `AFOneTests/` - Test directory needs creation
- [ ] `HealthKitServiceTests.swift` - Tests for FOUN-01
- [ ] `DashboardViewModelTests.swift` - Tests for DASH-01, DASH-02, DASH-03
- [ ] `AfBurdenTests.swift` - Tests for BURN-01
- [ ] `EpisodeTests.swift` - Tests for EPIS-01, EPIS-02
- [ ] `TimelineTests.swift` - Tests for TIME-01
- [ ] `NotificationTests.swift` - Tests for NOTIF-01
- [ ] Mock data for HealthKit queries (since real HealthKit requires physical device)

---

## Sources

### Primary (HIGH confidence)
- Apple HealthKit Documentation - https://developer.apple.com/documentation/healthkit
- Apple SwiftData Documentation - https://developer.apple.com/documentation/swiftdata
- Apple Swift Charts Documentation - https://developer.apple.com/documentation/Charts
- Apple UserNotifications Documentation - https://developer.apple.com/documentation/usernotifications

### Secondary (MEDIUM confidence)
- Apple Developer Forums - HealthKit background delivery reliability discussions
- Medium articles on HealthKit + MVVM architecture patterns
- Stack Overflow - Real-world HealthKit implementation patterns

### Tertiary (LOW confidence)
- Various tutorial sites - basic patterns, needs verification against official docs

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Native Apple frameworks, well-documented
- Architecture: HIGH - MVVM + Clean Architecture is standard for iOS
- Pitfalls: HIGH - Confirmed via Apple Developer Forums and documentation

**Research date:** 2026-03-11
**Valid until:** 2026-04-11 (30 days for stable Apple frameworks)

---

## User Constraints (from CONTEXT.md)

### Locked Decisions
- iOS-only (Apple Watch ecosystem required)
- SwiftUI + Swift Charts + SwiftData stack
- MVVM + Clean Architecture
- Offline-first core features
- No backend/cloud
- Not a medical device disclaimers required

### OpenCode's Discretion
- Specific HealthKit data types to read
- Chart visualization designs
- Notification triggers and timing
- Emergency information display

### Deferred Ideas (OUT OF SCOPE)
- Android platform
- Cloud infrastructure
- Medical diagnosis features
- Write data to Apple Health
