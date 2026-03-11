# Phase 2 Context - User Input & Analysis

**Phase:** 2 - User Input & Analysis  
**Created:** 2026-03-11  
**Purpose:** Decisions that guide research and planning for Phase 2 implementation

---

## Decisions

### 1. Symptom Logging UX

**Decision:** Bottom sheet with multi-select chips, floating action button (FAB) on Dashboard

**Rationale:** 
- Bottom sheet (SwiftUI `.sheet` with `.presentationDetents([.medium, .large])`) allows quick logging without leaving context
- FAB on Dashboard provides immediate access when feeling unusual
- Multi-select chips allow logging multiple symptoms at once
- Timestamp auto-captured (user can adjust if needed)

**Implementation:**
- Add 5th tab "Log" or FAB on Dashboard (simpler: FAB)
- 6 symptom types: palpitations, anxiety, dizziness, fatigue, shortness of breath, chest discomfort
- Optional notes field
- Store in SwiftData with timestamp
- Sheet with `.medium` detent for quick log, `.large` for adding notes

**Code Pattern:**
```swift
.sheet(isPresented: $showSymptomLogger) {
    SymptomLoggerView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

---

### 2. Trigger Tracking

**Decision:** Real-time logging with "Add Trigger" button, daily summary view optional

**Rationale:**
- Users often know triggers at time of occurrence (e.g., just had coffee, feeling stressed)
- Real-time logging captures context better than retrospective
- Daily summary adds friction without value for PAF use case

**Implementation:**
- Separate "Triggers" section in Log sheet (below symptoms)
- 6 trigger types: alcohol, caffeine, stress, poor sleep, heavy meals, intense exercise
- Optional intensity/quantity (e.g., "2 cups coffee", "high stress")
- Store in SwiftData alongside symptoms
- Pattern view in Analysis tab shows trigger frequency

---

### 3. Multi-Window AF Burden

**Decision:** Segmented control (Picker with .segmented style) above burden chart

**Rationale:**
- Standard iOS pattern (Apple Health uses this)
- Segmented control is quick to switch, no navigation needed
- Query HealthKit fresh for each period (burden data is small, fast query)

**Implementation:**
- Add Picker above burden card: "Day" | "Week" | "Month"
- Use Swift Charts `Chart` with `BarMark` for daily, `LineMark` for weekly/monthly
- Query: `fetchAfBurden(from: startDate, to: Date())` where startDate varies by period
- Display: daily = bars, weekly = line with points, monthly = line
- Show percentage prominently with trend indicator (↑↓→)

**Code Pattern:**
```swift
Picker("Period", selection: $selectedPeriod) {
    Text("Day").tag(Period.day)
    Text("Week").tag(Period.week)
    Text("Month").tag(Period.month)
}
.pickerStyle(.segmented)
```

---

### 4. Correlation View

**Decision:** Overlay timeline with symptom markers, separate "Patterns" analysis view

**Rationale:**
- Visual correlation is most intuitive (see symptoms alongside rhythm)
- Separate view keeps Dashboard clean
- Simple time-window matching: symptom within episode = "coincides"

**Implementation:**
- Timeline shows rhythm blocks (from Phase 1)
- Overlay symptom markers as colored dots on timeline
- "Patterns" view shows:
  - "Symptoms with AF" - symptoms that occurred during episodes
  - "Symptoms without AF" - symptoms during normal rhythm
- Use color coding: red dots = AF-aligned, green dots = normal-aligned
- Simple count + percentage for each category

---

### 5. SwiftData Introduction

**Decision:** SwiftData for all user-entered data (symptoms, triggers)

**Rationale:**
- Phase 1 has no SwiftData (HealthKit only)
- Phase 2 introduces user input, requires persistence
- SwiftData is Apple's recommended approach (iOS 17+)
- @Model macro keeps code clean

**Implementation:**
- New `SymptomLog` model: id, type, timestamp, notes
- New `TriggerLog` model: id, type, timestamp, intensity, notes
- Query by date range for correlation analysis
- No cloud sync (offline-first, Phase 1 principle)

---

### 6. Notification Logic

**Decision:** Check episode duration and burden change on app launch/foreground

**Rationale:**
- Background delivery for HealthKit is unreliable (Phase 1 finding)
- Check on launch covers most cases
- User has app open to receive notification

**Implementation:**
- On `ScenePhase.active`: fetch latest episode
- If episode.duration > threshold (e.g., 1 hour) → long episode notification
- Compare current week burden to previous → if significant increase → burden notification
- Use NotificationService (from Phase 1) to schedule

---

## Code Context

### New Project Structure (Phase 2)

```
AFOne/
├── Core/
│   ├── HealthKit/
│   │   └── HealthKitService.swift     # Add: fetchMedications(), fetchHRV()
│   ├── Analysis/
│   │   ├── AFBurdenCalculator.swift   # Update: multi-window support
│   │   └── CorrelationAnalyzer.swift  # NEW: symptom-AF correlation
│   └── Notifications/
│       └── NotificationService.swift  # Add: long episode, burden increase
├── Models/
│   ├── SymptomLog.swift               # NEW: SwiftData model
│   └── TriggerLog.swift              # NEW: SwiftData model
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift        # Add: FAB, burden period picker
│   │   └── DashboardViewModel.swift   # Add: symptom/trigger handling
│   ├── Log/                           # NEW: Symptom + Trigger logging
│   │   ├── LogView.swift              # Bottom sheet
│   │   └── LogViewModel.swift
│   ├── Timeline/
│   │   ├── TimelineView.swift         # Add: symptom overlay markers
│   │   └── TimelineViewModel.swift   # Add: correlation data
│   └── Analysis/                      # NEW: Patterns & correlations
│       ├── AnalysisView.swift
│       └── AnalysisViewModel.swift
└── Shared/
    └── Components/
        ├── SymptomChip.swift          # NEW: multi-select chip
        └── TriggerChip.swift          # NEW: trigger selection
```

### Key Implementation Notes

1. **SwiftData @Model** for SymptomLog, TriggerLog
2. **@Observable + @MainActor** continues (Phase 1 pattern)
3. **HealthKitService** extended for medications (read from HealthKit records)
4. **Swift Charts** for multi-window burden visualization
5. **Bottom sheet** via `.sheet` with `.presentationDetents([.medium, .large])`
6. **FAB** via `ZStack` with `.overlay(alignment: .bottomTrailing)`

---

## Prior Context References

- **Phase 1 CONTEXT.md:** Navigation (TabView), Authorization UX, Timeline viz, Data sync, Emergency info
- **Phase 1 SUMMARYs:** HealthKitService patterns, @Observable usage, Disclaimer implementation
- **PROJECT.md:** Privacy-first, offline-first, not a medical device
- **REQUIREMENTS.md:** Phase 2 requirements (URN-02,B TIME-02, HR-01-03, SYM-01-03, CORR-01-03, MED-01-02, TRIG-01-02, NOTIF-02-03)

---

## Requirements Coverage

| Requirement | Feature | Decision |
|-------------|---------|----------|
| SYM-01 | Quick symptom logging | FAB + bottom sheet |
| SYM-02 | Auto timestamp | SwiftData default |
| SYM-03 | Symptom history | LogView with filter |
| TRIG-01 | Trigger logging | Same sheet as symptoms |
| TRIG-02 | Pattern detection | AnalysisView |
| BURN-02 | Multi-window burden | Segmented picker |
| TIME-02 | Pattern detection | CorrelationAnalyzer |
| HR-01, HR-02, HR-03 | HR during episodes | EpisodeDetailView (Phase 1) |
| CORR-01, CORR-02, CORR-03 | Correlation | AnalysisView + Timeline overlay |
| MED-01, MED-02 | Medications | Read from HealthKit |
| NOTIF-02, NOTIF-03 | Notifications | On launch check |

---

## Next Steps

**For Research Agent:**
- Swift Charts multi-series visualization (burden + symptoms overlay)
- SwiftData @Model patterns with relationships
- HealthKit medication reading (HKClinicalRecord)

**For Planning Agent:**
- Task breakdown for Phase 2
- Dependency ordering (SwiftData models → LogView → Correlation → Notifications)
- Consider 3-4 plans for Phase 2

---

*Context created: 2026-03-11*
*Discuss-phase completed*
