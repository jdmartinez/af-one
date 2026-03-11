# Phase 1 Context - Foundation & Core Display

**Phase:** 1 - Foundation & Core Display  
**Created:** 2026-03-10  
**Purpose:** Decisions that guide research and planning for Phase 1 implementation

---

## Decisions

### 1. Navigation Structure

**Decision:** TabView + NavigationStack (like Apple's Health app)

**Rationale:** Standard pattern for health apps with multiple primary sections. TabView provides quick access to 4 main sections, NavigationStack handles drill-down within each tab.

**Implementation:**
- 4 tabs: Dashboard, Timeline, Episodes, More (emergency, settings)
- Each tab has its own NavigationStack for push navigation
- Emergency info accessible from both Dashboard (quick action) and More tab

---

### 2. Authorization UX

**Decision:** Upfront full request on first launch

**Rationale:** Users need HealthKit data to see anything meaningful. Deferring authorization would show empty states that confuse users.

**Implementation:**
- On first launch, show brief explanation screen
- Request all required HealthKit permissions in single prompt:
  - Heart rate
  - AF burden (iOS 16+)
  - ECG readings
  - Heart rate variability
- After authorization, proceed to Dashboard
- Handle denied state with clear "Enable in Settings" guidance

---

### 3. Timeline Visualization

**Decision:** Daily blocks (24h segments)

**Rationale:** 24-hour blocks provide clear rhythm status overview without overwhelming detail. Color-coded (green=normal, red=AF, gray=unknown) aligns with Apple's Health app patterns.

**Implementation:**
- Horizontal scrollable timeline
- Each day is one "block" showing dominant rhythm
- Tap block to see hourly breakdown
- Default view: last 7 days
- Filter options: 7 days, 30 days, custom range

---

### 4. Data Sync Strategy

**Decision:** Always fresh query

**Rationale:** HealthKit is the single source of truth. Apple Watch continuously syncs. Querying on every launch ensures latest data without caching complexity.

**Implementation:**
- On app launch: query latest data (parallel async queries)
- On view appear: refresh if stale (>5 min old)
- No local caching of raw health data
- SwiftData only for user-entered data (symptoms in Phase 2, not Phase 1)

---

### 5. Emergency Information

**Decision:** Read from HealthKit Medical ID

**Rationale:** Users already maintain Medical ID in Apple Health. No need to duplicate or manage separate storage. Emergency responders know to check Medical ID.

**Implementation:**
- Read emergency contact, medical conditions, medications from HealthKit
- Display in Emergency tab with clear "From Medical ID" attribution
- No editing capability (direct user to Health app)
- Additional free-text notes allowed (stored in SwiftData)

---

## Code Context

### Project Structure (Phase 1)

```
AFOne/
├── App/
│   ├── AFOneApp.swift           # App entry, TabView root
│   └── ContentView.swift        # TabView with 4 tabs
├── Core/
│   ├── HealthKit/
│   │   ├── HealthKitService.swift       # Singleton, all HK interactions
│   │   ├── HealthKitTypes.swift         # Type definitions
│   │   └── HealthKitError.swift         # Error types
│   └── Analysis/
│       └── AFBurdenCalculator.swift     # Phase 1: basic burden calc
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── DashboardViewModel.swift
│   ├── Timeline/
│   │   ├── TimelineView.swift
│   │   └── TimelineViewModel.swift
│   ├── Episodes/
│   │   ├── EpisodeListView.swift
│   │   ├── EpisodeDetailView.swift
│   │   └── EpisodeViewModel.swift
│   └── More/
│       ├── MoreView.swift               # Settings, About
│       └── EmergencyView.swift          # Read from Medical ID
├── Models/
│   ├── RhythmEpisode.swift
│   ├── HeartRateReading.swift
│   └── AFBurden.swift
└── Shared/
    ├── Components/
    │   ├── MetricCard.swift
    │   └── RhythmBlockView.swift        # 24h timeline block
    └── Extensions/
        └── Date+Extensions.swift
```

### Key Implementation Notes

1. **HealthKitService** is the only component that touches HKHealthStore
2. **@Observable + @MainActor** for all ViewModels
3. **async/await** for all HealthKit queries (modern HKSampleQueryDescriptor)
4. **No SwiftData** in Phase 1 (only HealthKit reads)
5. **Disclaimer** shown on launch and in Settings (FOUN-02)

---

## Prior Context References

- PROJECT.md: Core value, privacy-first, offline-first principles
- REQUIREMENTS.md: FOUN-01 through FOUN-05, DASH-01 through DASH-04, OVER-01, OVER-02, BURN-01, TIME-01, EPIS-01 through EPIS-03, EMER-01, EMER-02, NOTIF-01
- RESEARCH/STACK.md: SwiftUI, HealthKit, SwiftData, Swift Charts
- RESEARCH/ARCHITECTURE.md: MVVM + Clean Architecture patterns

---

## Next Steps

**For Research Agent:**
- HealthKit query patterns for AF burden (iOS 16+ specific)
- Swift Charts timeline rendering examples
- Background notification setup for AF episodes

**For Planning Agent:**
- Task breakdown for Phase 1 implementation
- Sprint/iteration planning
- Dependency ordering (HealthKitService → Models → ViewModels → Views)

---

*Context created: 2026-03-10*
