---
phase: 02-user-input-analysis
plan: 04
subsystem: analysis
tags: [swiftui, swiftdata, healthkit, correlation, charts]

# Dependency graph
requires:
  - phase: 02-01
    provides: SwiftData models (SymptomLog, TriggerLog)
  - phase: 02-02
    provides: Symptom/Trigger logging UI
provides:
  - CorrelationAnalyzer with symptom-AF correlation logic
  - AnalysisViewModel for loading correlation data
  - AnalysisView with symptom, trigger, and HR analysis tabs
  - TimelineView with symptom query and legend indicator
affects: [future analysis features, export functionality]

# Tech tracking
tech-stack:
  added: []
  patterns: [MVVM with @Observable, SwiftData @Query, Swift Charts]

key-files:
  created:
    - AFOne/Core/Analysis/CorrelationAnalyzer.swift
    - AFOne/Features/Analysis/AnalysisViewModel.swift
    - AFOne/Features/Analysis/AnalysisView.swift
  modified:
    - AFOne/Features/Timeline/TimelineView.swift

key-decisions:
  - Used tabbed interface for AnalysisView (symptoms/triggers/HR)

patterns-established:
  - Actor-based analyzers for thread-safe data processing

requirements-completed: [TIME-02, CORR-01, CORR-02, CORR-03, HR-01, HR-02, HR-03]

# Metrics
duration: 8min
completed: 2026-03-12
---

# Phase 02-04: Symptom-Burden Correlation Analysis Summary

**Symptom-AF correlation analysis with heart rate behavior insights, accessible via tabbed Analysis view**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-12T07:50:00Z
- **Completed:** 2026-03-12T07:58:00Z
- **Tasks:** 4
- **Files modified:** 4

## Accomplishments
- Created CorrelationAnalyzer actor with symptom/trigger correlation and HR analysis
- Built AnalysisViewModel to fetch and process correlation data from SwiftData and HealthKit
- Implemented AnalysisView with three tabs: Symptoms, Triggers, and Heart Rate
- Added SwiftData query for symptoms in TimelineView with legend indicator

## task Commits

Each task was committed atomically:

1. **task 1: Create CorrelationAnalyzer** - `19a2920` (feat)
2. **task 2: Create AnalysisViewModel** - `19a2920` (feat)
3. **task 3: Create AnalysisView** - `19a2920` (feat)
4. **task 4: Add symptom markers to TimelineView** - `19a2920` (feat)

**Plan metadata:** `19a2920` (docs: complete plan)

## Files Created/Modified
- `AFOne/Core/Analysis/CorrelationAnalyzer.swift` - Symptom/trigger correlation logic with HR analysis
- `AFOne/Features/Analysis/AnalysisViewModel.swift` - ViewModel for loading analysis data
- `AFOne/Features/Analysis/AnalysisView.swift` - Tabbed view for correlation insights
- `AFOne/Features/Timeline/TimelineView.swift` - Added symptom query and legend indicator

## Decisions Made
- Used tabbed interface for AnalysisView to organize three analysis categories
- Added symptom query to TimelineView for future symptom marker overlay support

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None - all tasks completed as specified.

## Next Phase Readiness
- Correlation analysis complete for Phase 2
- Ready for next plan in Phase 2 (02-05) or proceed to Phase 3

---
*Phase: 02-user-input-analysis*
*Completed: 2026-03-12*
