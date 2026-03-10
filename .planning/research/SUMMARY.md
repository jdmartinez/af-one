# Project Research Summary

**Project:** AFOne - iOS Heart Rhythm Monitoring App
**Domain:** iOS Health Monitoring / AFib Tracking Application
**Researched:** 2026-03-10
**Confidence:** HIGH

## Executive Summary

AFOne is an iOS application for monitoring paroxysmal atrial fibrillation (PAF) using data from Apple Watch. The app reads heart rhythm data via HealthKit—the only pathway to Apple Watch's AF detection, ECG readings, and heart rate data—and presents it in an accessible format for patients and their cardiologists. The recommended technology stack is entirely native Apple frameworks: SwiftUI for UI, Swift Charts for visualization, SwiftData for local caching, and Swift Observation (@Observable) for state management, targeting iOS 17+.

The research reveals three critical risks that must shape the roadmap. First, Apple Watch provides opportunistic sampling, not continuous monitoring—users must be educated about data gaps to avoid confusion. Second, background sync via HKObserverQuery is unreliable; the app should rely on foreground refresh on launch. Third, regulatory boundaries are strict—the app must never claim to "detect" or "diagnose" AF, only display Apple Watch data with clear disclaimers. The architecture should center on a HealthKitService facade that handles all data access, with pure business logic in an AnalysisEngine for testability.

## Key Findings

### Recommended Stack

**Core technologies:**

- **SwiftUI** (iOS 18 target, iOS 16+ minimum) — Industry standard for modern health apps. Native Charts integration, declarative syntax aligned with health data patterns. iOS 18 adds 3D chart capabilities.
- **Swift 5.9+** — Required for Observation framework and modern SwiftUI features.
- **HealthKit** — The sole data source. Reads AF burden (iOS 16+), ECG readings, and heart rate data. Key types: `HKQuantityTypeIdentifier.heartRate`, `HKQuantityTypeIdentifier.atrialFibrillationBurden`, `HKElectrocardiogram`.
- **SwiftData** (iOS 17+) — Local caching of symptoms and computed metrics. Replaces Core Data for new projects.
- **Swift Charts** (iOS 16+, iOS 18 enhanced) — Primary visualization framework. Native, actively developed by Apple, integrates with SwiftUI. Use DGCharts only if specific requirements emerge.
- **Swift Observation** (@Observable, iOS 17+) — Modern state management replacing Combine-based ObservableObject. Better performance for frequent health data updates.
- **MVVM + Clean Architecture** — Industry standard for health apps. Presentation (Views/ViewModels) → Domain (Use Cases/Entities) → Data (Repositories/Services).

**Minimum deployment:** iOS 17+ recommended (enables SwiftData, Swift Observation). iOS 16+ acceptable for broader device support.

### Expected Features

**Must have (table stakes):**
- Dashboard with rhythm context — immediate insight into current heart status
- AF burden percentage — core metric from Apple Watch, weekly calculated by iOS
- Episode history timeline — timestamps, duration, frequency of AF events
- Heart rate visualization — understand episode severity and behavior patterns
- Apple Health integration — read-only data access foundation
- Clear non-medical-device disclaimer — regulatory requirement, builds trust

**Should have (competitive):**
- Symptom-rhythm correlation — link logged symptoms to AF episodes by time
- Lifestyle trigger tracking — log caffeine, alcohol, stress, sleep, exercise
- Clinical report PDF export — concise 3-page summary for cardiologist
- Multiple burden time windows — daily, weekly, monthly views
- Medication awareness from Health Records — contextual insight

**Defer (v2+):**
- Long-term trends (6-month, 1-year) — requires accumulated data
- Color-coded burden zones — UI enhancement
- HR behavior analysis during AF — deeper analytics
- Widget support — iOS home screen integration
- Apple Watch companion app — glanceable data

### Architecture Approach

The recommended architecture uses **MVVM with @Observable** and **Clean Architecture** principles. A single `HealthKitService` wraps all HealthKit interactions (authorization, queries, data transformation), providing a clean API to the rest of the app. Business logic lives in a stateless `AnalysisEngine` with pure functions for burden calculation, trend detection, and pattern analysis—highly testable without UI or HealthKit dependencies.

**Major components:**

1. **HealthKitService** — All HealthKit interactions. Singleton with HKHealthStore, async/await query methods, authorization management.
2. **AnalysisEngine** — Pure business logic. Stateless calculations for AF burden, trend analysis, pattern detection.
3. **ViewModels (@Observable)** — DashboardViewModel, RhythmViewModel, EpisodeViewModel. Aggregate state, handle user actions, coordinate with services.
4. **Domain Models** — Pure Swift structs (RhythmEpisode, HeartRateReading, AFBurden). Independent of HealthKit and SwiftUI.

### Critical Pitfalls

1. **Apple Watch Data Collection Model** — Users expect continuous monitoring but Apple Watch uses opportunistic sampling. Design UI to show data coverage windows, educate users upfront, handle empty states gracefully.

2. **Background Data Sync Unreliability** — HKObserverQuery doesn't fire reliably in background. Implement foreground-only refresh on launch, use BGTaskScheduler for periodic refresh (not guaranteed), rely on Apple Health app as primary data source.

3. **Regulatory Boundary Violation** — Never claim to "detect" or "diagnose" AF. Use explicit disclaimers: "Not a medical device / For informational purposes only." Frame as "rhythm interpretation" not diagnosis.

4. **Query Performance with Large Datasets** — HKStatisticsCollectionQuery can be slow. Query in 30-day chunks, use lower resolution (hourly vs minute), implement progressive loading, cache computed results.

5. **Data Source Attribution Ambiguity** — Cannot reliably distinguish ECG from PPG data. Don't make claims about data source quality in UI; treat all rhythm data as equivalent.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation & Data Layer
**Rationale:** Cannot build any features without HealthKit integration and domain models. This phase establishes the data architecture that all subsequent features depend on.

**Delivers:**
- HealthKitService with authorization and basic queries
- Domain models (RhythmEpisode, HeartRateReading, AFBurden)
- Basic SwiftUI view scaffold with empty states
- Onboarding flow with HealthKit permission request and disclaimer

**Addresses:**
- Feature: Apple Health integration
- Pitfalls: #1 (data model education), #3 (disclaimers), #6 (permission handling)

### Phase 2: Core Visualization
**Rationale:** Once data layer works, build the primary value proposition—showing users their heart rhythm data.

**Delivers:**
- Dashboard with current rhythm context
- Episode history timeline
- Heart rate visualization during episodes
- AF burden calculation (weekly)

**Addresses:**
- Features: Dashboard, Episode timeline, HR viz, AF burden (all P1)
- Pitfalls: #4 (query performance with chunked loading), #5 (data attribution)

### Phase 3: User-Generated Data
**Rationale:** Symptom logging and lifestyle tracking add significant user value and differentiate from Apple Health.

**Delivers:**
- Symptom logging with timestamp
- Lifestyle trigger tracking (caffeine, alcohol, stress, sleep)
- Burden views for multiple time windows (daily/monthly)

**Addresses:**
- Features: Symptom logging, lifestyle tracking, burden windows (P2)
- Pitfalls: #2 (foreground sync handles new user data)

### Phase 4: Advanced Analysis
**Rationale:** Correlation and reporting features provide the highest differentiation and clinical value.

**Delivers:**
- Symptom-rhythm correlation analysis
- Trend visualization
- Clinical report PDF export

**Addresses:**
- Features: Symptom-rhythm correlation, clinical report export (P2)
- Pitfalls: #8 (source filtering for reports)

### Phase 5: Platform Integration (v2+)
**Rationale:** Nice-to-have features that require accumulated data and user demand.

**Delivers:**
- Long-term trends (6-month, 1-year)
- Color-coded burden zones
- Emergency information quick access
- Widget support
- Apple Watch app

### Phase Ordering Rationale

- **Dependency order:** HealthKitService → Models → ViewModels → Views. This follows standard architecture build patterns.
- **Feature grouping:** Core visualization before user input ensures the app has value before asking users to log data.
- **Pitfall avoidance:** Query chunking implemented early (#4), disclaimers built into onboarding (#3), empty states designed from start (#1).

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2:** Complex timeline rendering with Swift Charts—may need research on large dataset visualization
- **Phase 4:** PDF generation for clinical reports—research PDF library options and accessibility standards

Phases with standard patterns (skip research-phase):
- **Phase 1:** HealthKit integration—well-documented Apple APIs, straightforward implementation
- **Phase 3:** SwiftData for symptom logging—standard patterns, no complex integration

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Based on Apple documentation and 2025-2026 iOS trends. All native frameworks with clear support. |
| Features | MEDIUM | Based on competitor analysis and App Store research. Some differentiation features unproven for this domain. |
| Architecture | HIGH | Standard MVVM + Clean Architecture for iOS health apps. Well-documented patterns. |
| Pitfalls | MEDIUM-HIGH | Multiple documented sources including Apple Developer Forums. Background sync issues well-known. Regulatory boundaries clear from FDA documentation. |

**Overall confidence:** HIGH

### Gaps to Address

- **Query performance benchmarks:** Need actual device testing to validate chunk size recommendations (30-day vs 14-day vs 7-day).
- **Regulatory validation:** Legal review of disclaimers before Phase 1 completion.
- **Background refresh strategy:** Decision needed on whether to implement BGTaskScheduler or rely on foreground-only.
- **AF burden accuracy:** Research how Apple's calculated burden differs from app-calculated burden from raw samples.

## Sources

### Primary (HIGH confidence)
- Apple HealthKit Documentation — https://developer.apple.com/documentation/healthkit
- Swift Charts Documentation — https://developer.apple.com/documentation/Charts
- HealthKit AF Burden Type — https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/atrialfibrillationburden
- FDA Apple AFib History MDDT qualification — Regulatory context

### Secondary (MEDIUM confidence)
- App Store: Heart History, ECG+, Cardiogram, AFib Manager — Competitor feature analysis
- Apple Support: Track your AFib History with Apple Watch (2024)
- JACC: Enhanced Detection and Prompt Diagnosis of Atrial Fibrillation Using Apple Watch (2025)
- Create with Swift: Reading data from HealthKit in a SwiftUI app

### Tertiary (LOW confidence)
- Community articles on MVVM in SwiftUI — General patterns, need validation with health app specifics

---

*Research completed: 2026-03-10*
*Ready for roadmap: yes*
