---
phase: 07-dashboard-redesign-specification
plan: 04
subsystem: Dashboard
tags: [af-burden, ui, clinical-metrics]
dependency_graph:
  requires:
    - 07-02
  provides:
    - AF Burden Card (Zone 2)
  affects:
    - DashboardView
    - Theme
tech_stack:
  added:
    - BurdenCardView
    - BurdenTimePeriod enum
  patterns:
    - Threshold-based coloring
    - Progress bar with tick marks
    - Segmented picker for time windows
key_files:
  created:
    - AFOne/Features/Dashboard/BurdenCardView.swift
  modified:
    - AFOne/Features/Dashboard/DashboardView.swift
decisions:
  - Use local BurdenTimePeriod enum for picker (24h/7d/30d) instead of existing TimePeriod enum for cleaner UX
  - Progress bar max at 11% per SPEC.md clinical thresholds
  - Delta trend color uses RhythmAF for increase, RhythmSinusal for decrease
metrics:
  completed_date: "2026-03-14"
  tasks_completed: 3
  files_created: 1
  files_modified: 1
---

# Phase 07 Plan 04: AF Burden Card (Zone 2) Summary

## Overview

Implemented the AF Burden Card (Zone 2) per SPECIFICATION.md Section 5 - displays AF burden percentage with time window selector, progress bar with threshold markers, and trend comparison.

## One-Liner

AF Burden percentage display with clinical threshold visualization and week-over-week trend

## Implementation Details

### BurdenCardView Component

Created a new `BurdenCardView.swift` with the following features:

1. **Time Window Selector**: Segmented picker with options 24h, 7d, 30d
2. **Primary Value Display**: 52pt bold rounded font with threshold-based coloring
3. **Threshold Badge**: Shows risk category (<5.5%, 5.5-10.9%, ≥11%)
4. **Progress Bar**: 6pt height with gradient fill, capped at 11% = 100% width
5. **Threshold Tick Marks**: At 50% (5.5%) and 100% (11%) positions
6. **Legend**: Three labels with colored dots for risk levels
7. **Delta Row**: Shows trend vs previous week with color coding

### Integration with DashboardView

- Added `selectedBurdenPeriod` @State for binding to BurdenCardView
- Converted `BurdenTrend` enum to Double value for delta display
- Replaced existing burdenSection with new BurdenCardView

### Accessibility

- Time window picker: accessibilityLabel
- Burden value: accessibilityValue
- Threshold badge: accessibilityLabel
- Progress bar: accessibilityLabel with percentage

## Deviations from Plan

None - plan executed exactly as written.

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Local BurdenTimePeriod enum | Provides cleaner UX with 24h/7d/30d options vs longer labels |
| Progress bar max at 11% | Per SPEC.md clinical thresholds for ASSERT and TRENDS |
| Delta color coding | RhythmAF (red) for increase, RhythmSinusal (green) for decrease |

## Verification

- [x] BurdenCardView.swift created with all specified elements
- [x] Accessibility labels added to all interactive elements
- [x] DashboardView integrates BurdenCardView in Zone 2 position

## Files

| File | Action |
|------|--------|
| AFOne/Features/Dashboard/BurdenCardView.swift | Created |
| AFOne/Features/Dashboard/DashboardView.swift | Modified |

## Commit

`e7e4d01` - feat(07-04): implement AF Burden Card (Zone 2)
