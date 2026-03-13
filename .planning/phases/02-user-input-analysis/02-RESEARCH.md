# Phase 2 Research: User Input & Analysis

**Phase:** 02-user-input-analysis  
**Researched:** 2026-03-11  
**Mode:** ecosystem

---

## Phase Overview

Phase 2 enables users to log symptoms and lifestyle triggers, view multi-window burden analysis, and understand heart rate behavior during episodes. This builds on Phase 1's foundation (HealthKitService, TabView, basic displays).

---

## Standard Stack

### SwiftData (iOS 17+)

**Use SwiftData @Model for all user-entered data:**

```swift
import SwiftData

@Model
final class SymptomLog {
    var id: UUID
    var symptomType: String  // palpitations, anxiety, dizziness, etc.
    var timestamp: Date
    var notes: String?
    
    init(symptomType: String, timestamp: Date = .now, notes: String? = nil) {
        self.id = UUID()
        self.symptomType = symptomType
        self.timestamp = timestamp
        self.notes = notes
    }
}

@Model
final class TriggerLog {
    var id: UUID
    var triggerType: String  // alcohol, caffeine, stress, etc.
    var timestamp: Date
    var intensity: String?    // mild, moderate, high
    var notes: String?
    
    init(triggerType: String, timestamp: Date = .now, intensity: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.triggerType = triggerType
        self.timestamp = timestamp
        self.intensity = intensity
        self.notes = notes
    }
}
```

**Setup in App:**
```swift
@main
struct AFOneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SymptomLog.self, TriggerLog.self])
    }
}
```

**Query with @Query:**
```swift
@Query(sort: \SymptomLog.timestamp, order: .reverse)
private var symptoms: [SymptomLog]
```

### Swift Charts (iOS 16+)

**Multi-window burden chart:**
```swift
struct BurdenChartView: View {
    let burdenData: [BurdenDataPoint]
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        Chart(burdenData) { dataPoint in
            switch selectedPeriod {
            case .day:
                BarMark(x: .value("Hour", dataPoint.date),
                        y: .value("Burden", dataPoint.percentage))
            case .week, .month:
                LineMark(x: .value("Date", dataPoint.date),
                         y: .value("Burden", dataPoint.percentage))
                PointMark(x: .value("Date", dataPoint.date),
                          y: .value("Burden", dataPoint.percentage))
            }
        }
    }
}
```

**Overlay symptom markers:**
```swift
Chart {
    // Burden data marks...
    
    ForEach(symptoms) { symptom in
        PointMark(x: .value("Time", symptom.timestamp),
                  y: .value("Level", 100))
        .symbol(.circle)
        .foregroundStyle(symptom.isAfRelated ? .red : .green)
    }
}
```

### HealthKit Medications

**iOS 18+ Medications API (WWDC 2025):**
```swift
import HealthKit

// Query user's medications
func fetchMedications() async throws -> [HKUserAnnotatedMedication] {
    let descriptor = HKUserAnnotatedMedicationQueryDescriptor()
    return try await withCheckedThrowingContinuation { continuation in
        // Execute query...
    }
}

// Query medication dose events (when taken)
func fetchDoseEvents() async throws -> [HKMedicationDoseEvent] {
    // Use HKSampleQuery with medication dose
}
```

** typeiOS 17 and earlier:** Read from clinical records (FHIR) or use HKCategorySample for medication dosing. Note: Full medication list requires user to add medications in Health app.

### iOS Local Notifications

**Setup and scheduling:**
```swift
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func scheduleLongEpisodeNotification(episodeDuration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Long AF Episode Detected"
        content.body = "Your AF episode has lasted over \(Int(episodeDuration / 60)) minutes."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, 
                                           content: content, 
                                           trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

**Check on app foreground:**
```swift
.onChange(of: scenePhase) { _, newPhase in
    if newPhase == .active {
        // Check episode duration and burden changes
        Task {
            await checkForLongEpisodes()
            await checkForBurdenIncrease()
        }
    }
}
```

---

## Architecture Patterns

### Feature Structure (Continue Phase 1 pattern)

```
AFOne/
├── Core/
│   ├── HealthKit/
│   │   └── HealthKitService.swift    # Add: fetchMedications(), fetchDoseEvents()
│   └── Analysis/
│       ├── AFBurdenCalculator.swift  # Update: multi-window support
│       └── CorrelationAnalyzer.swift # NEW: symptom-AF correlation
├── Models/
│   ├── SymptomLog.swift              # NEW: SwiftData @Model
│   └── TriggerLog.swift              # NEW: SwiftData @Model
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift       # Add: FAB, burden period picker
│   │   └── DashboardViewModel.swift
│   ├── Log/                         # NEW: Symptom + Trigger logging
│   │   ├── LogView.swift             # Bottom sheet
│   │   └── LogViewModel.swift
│   ├── Timeline/
│   │   └── TimelineView.swift        # Add: symptom overlay markers
│   └── Analysis/                    # NEW: Patterns & correlations
│       ├── AnalysisView.swift
│       └── AnalysisViewModel.swift
└── Shared/
    └── Components/
        ├── SymptomChip.swift          # NEW: multi-select chip
        └── TriggerChip.swift          # NEW: trigger selection
```

### State Management

**Continue @Observable + @MainActor pattern from Phase 1:**
```swift
@Observable
@MainActor
class LogViewModel {
    var selectedSymptoms: Set<SymptomType> = []
    var selectedTriggers: Set<TriggerType> = []
    var notes: String = ""
    
    func saveLog() {
        // Save to SwiftData via ModelContext
    }
}
```

### Bottom Sheet Pattern

```swift
.sheet(isPresented: $showLogSheet) {
    LogView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
}
```

### FAB Pattern

```swift
ZStack {
    DashboardView()
    
    VStack {
        Spacer()
        HStack {
            Spacer()
            Button(action: { showLogSheet = true }) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
    }
}
```

---

## Don't Hand-Roll

1. **SwiftData persistence** — Use @Model macro, ModelContainer, ModelContext. Don't build custom SQLite wrappers.

2. **Charts** — Use Swift Charts (Apple's framework). Don't use DGCharts or ChartsCocoaPods.

3. **HealthKit queries** — Use HKSampleQueryDescriptor and async/await. Don't use older callback-based query APIs.

4. **Notifications** — Use UNUserNotificationCenter. Don't build custom local notification systems.

5. **Bottom sheets** — Use native .sheet() with presentationDetents. Don't build custom sheet implementations.

6. **Date handling** — Use Foundation Date, DateInterval, Calendar. Don't parse date strings manually.

---

## Common Pitfalls

### SwiftData

| Pitfall | Solution |
|---------|----------|
| Model not saving | Call `modelContext.save()` after modifications |
| @Query not updating | Ensure modelContainer is set at App level |
| Date comparisons failing | Use `Calendar.current.dateComponents()` for precision |

### Swift Charts

| Pitfall | Solution |
|---------|----------|
| Chart not rendering | Ensure data conforms to Identifiable |
| X-axis labels overlapping | Use `chartXAxis` with `.labels` rotation |
| Memory pressure with large datasets | Use data subsampling before charting |

### HealthKit

| Pitfall | Solution |
|---------|----------|
| Authorization denied | Show clear guidance to Settings |
| No medications showing | User must add medications in Health app |
| Clinical records empty | User must download records from healthcare provider |

### Notifications

| Pitfall | Solution |
|---------|----------|
| Permission denied | Check authorization status before scheduling |
| Notification not firing in simulator | Use actual device for testing |
| Duplicate notifications | Use unique identifiers, check existing requests |

---

## Code Examples

### Multi-Select Chips

```swift
struct SymptomChip: View {
    let symptom: SymptomType
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            Text(symptom.displayName)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                .foregroundStyle(isSelected ? .accentColor : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
                )
        }
    }
}
```

### Correlation Analysis Algorithm

```swift
struct CorrelationResult {
    let symptomsWithAf: Int
    let symptomsWithoutAf: Int
    let totalSymptoms: Int
    
    var afCooccurrenceRate: Double {
        guard totalSymptoms > 0 else { return 0 }
        return Double(symptomsWithAf) / Double(totalSymptoms)
    }
}

func analyzeCorrelation(symptoms: [SymptomLog], episodes: [RhythmEpisode]) -> CorrelationResult {
    var withAf = 0
    var withoutAf = 0
    
    for symptom in symptoms {
        let occursDuringEpisode = episodes.contains { episode in
            symptom.timestamp >= episode.startDate && symptom.timestamp <= episode.endDate
        }
        
        if occursDuringEpisode {
            withAf += 1
        } else {
            withoutAf += 1
        }
    }
    
    return CorrelationResult(symptomsWithAf: withAf, 
                            symptomsWithoutAf: withoutAf, 
                            totalSymptoms: symptoms.count)
}
```

### Burden Calculation by Period

```swift
enum TimePeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    
    var dateRange: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .day:
            return DateInterval(start: calendar.date(byAdding: .day, value: -1, to: now)!, end: now)
        case .week:
            return DateInterval(start: calendar.date(byAdding: .weekOfYear, value: -1, to: now)!, end: now)
        case .month:
            return DateInterval(start: calendar.date(byAdding: .month, value: -1, to: now)!, end: now)
        }
    }
}
```

---

## Confidence Assessment

| Topic | Confidence | Notes |
|-------|------------|-------|
| SwiftData @Model | High | Standard iOS 17 pattern, well-documented |
| Swift Charts | High | Apple framework, mature in iOS 16+ |
| HealthKit medications | Medium | New iOS 18 APIs, clinical records more complex |
| Local notifications | High | Standard UserNotifications framework |
| Bottom sheets | High | Native SwiftUI since iOS 16 |
| Correlation analysis | High | Simple time-interval matching algorithm |

---

*Research completed: 2026-03-11*
*Mode: ecosystem*
