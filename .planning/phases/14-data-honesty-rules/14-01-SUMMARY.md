---
phase: 14-data-honesty-rules
plan: "01"
subsystem: UI/Data-Honesty
tags: [DATA-01, DATA-02, DATA-03, DATA-04, DATA-05, phase-14, v0.3]
dependency_graph:
  requires: []
  provides: [DATA-01, DATA-02, DATA-03, DATA-04, DATA-05]
  affects: [HeroCardView, BurdenDetailView, RhythmMapDetailView, SymptomCorrelationView, EpisodeListView, EpisodeDetailView, EmergencyView, DataHonestyHelper]
tech_stack:
  added: []
  patterns: [Data Honesty, Transparency Messaging]
key_files:
  created: [AFOne/Shared/Components/DataHonestyHelper.swift]
  modified: [AFOne/Features/Dashboard/HeroCardView.swift, AFOne/Features/Dashboard/BurdenDetailView.swift, AFOne/Features/Dashboard/RhythmMapDetailView.swift, AFOne/Features/Analysis/SymptomCorrelationView.swift, AFOne/Features/Episodes/EpisodeListView.swift, AFOne/Features/Episodes/EpisodeDetailView.swift, AFOne/Features/More/EmergencyView.swift]
decisions: []
metrics:
  duration_minutes: 5
  completed_date: "2026-03-19"
  tasks_completed: 3
  files_created: 1
  files_modified: 6
  requirements_completed: 5
---

# Phase 14 Plan 01: Data Honesty Rules Summary

**One-liner:** Applied consistent data honesty principles across all views — estimated value suffixes, SpO2 nil/0 handling, timer disclosures, and user-declared data badges.

## What Was Built

Implemented all five DATA requirements (DATA-01 through DATA-05) across 8 files:

### DATA-01: Estimated Value Suffixes ("est.")
- **HeroCardView:** Timer now shows `HH:MM:SS (est.)` in AF Active banner
- **BurdenDetailView:** Burden percentage shows `(est.)` on main value
- **RhythmMapDetailView:** Stats row (RS%, FA%, Sin datos) all show `(est.)`
- **SymptomCorrelationView:** Methodological note updated to include `(est.)`
- **EpisodeListView:** Added honesty note about `irregularHeartRhythmEvent` estimates
- **EpisodeDetailView:** Added honesty note for HR values from Apple Watch

### DATA-02: SpO2 "Sin dato" (not "0%")
- **EmergencyView:** `episode.currentSpO2 ?? 0` replaced with `DataHonestyHelper.formatSpO2()` which returns `"Sin dato"` for nil/zero values

### DATA-03: Timer Disclosure
- **HeroCardView:** Disclosure text updated to `"Desde último dato de Apple Watch"`
- **EmergencyView:** Added disclosure below "Desde inicio" label with orange styling

### DATA-04: User-Declared Data Notes
- **EmergencyView medications section:** Added `UserDeclaredBadge` below medication list
- **EmergencyView history section:** Added `UserDeclaredBadge` below history timeline

### DATA-05: Rhythm Map Low Sample Opacity
- Already implemented in Phase 12 — RhythmMapDetailView line 110 shows `0.35` opacity for `<3` samples

## Key Files

| File | Change |
|------|--------|
| `DataHonestyHelper.swift` | **New** — Reusable helper with `formatSpO2()`, `formatEstimatedValue()`, `spo2Chip()`, `UserDeclaredBadge` |
| `HeroCardView.swift` | Timer `(est.)` + timer disclosure text |
| `BurdenDetailView.swift` | Burden % `(est.)` suffix |
| `RhythmMapDetailView.swift` | Stats row `(est.)` suffixes |
| `SymptomCorrelationView.swift` | Methodological note with `(est.)` |
| `EpisodeListView.swift` | Data honesty note for episode counts |
| `EpisodeDetailView.swift` | HR honesty note |
| `EmergencyView.swift` | DATA-02 SpO2 fix, DATA-03 disclosure, DATA-04 badges |

## Commits

| Hash | Message |
|------|---------|
| `7645ed2` | feat(phase-14): add DataHonestyHelper component |
| `5bd3434` | feat(phase-14): add est. suffix to all views (DATA-01) |
| `5e8c67b` | fix(phase-14): add disclosures and user-declared notes to EmergencyView (DATA-02 to DATA-04) |

## Deviations from Plan

None — plan executed exactly as written.

## Verification

- ✅ Build succeeded: `xcodebuild ... build` — **BUILD SUCCEEDED**
- ✅ 10 occurrences of `(est.)` across views
- ✅ SpO2 handled via `DataHonestyHelper.formatSpO2()`
- ✅ Timer disclosures present in HeroCardView and EmergencyView
- ✅ User-declared badges in EmergencyView medications and history sections
- ✅ DATA-05 35% opacity confirmed in RhythmMapDetailView line 110

## Self-Check

- ✅ `DataHonestyHelper.swift` exists
- ✅ All 6 modified views have `(est.)` or honesty notes
- ✅ EmergencyView has all 3 fixes (DATA-02, DATA-03, DATA-04)
- ✅ Build succeeds
- ✅ 3 commits created
