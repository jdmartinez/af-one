---
phase: 07-dashboard-redesign-specification
plan: 07
subsystem: Dashboard UI
tags: [ui, dashboard, symptom-capture, zone-5]
dependency_graph:
  requires:
    - 07-02 (Color System Foundation)
  provides:
    - SymptomCaptureButton component
  affects:
    - DashboardView
tech_stack:
  added:
    - SymptomCaptureButton.swift
  patterns:
    - Full-width button with custom styling per SPEC Section 8
    - Dual-state button (SR/AF Active)
    - Sheet presentation pattern
key_files:
  created:
    - AFOne/Features/Dashboard/SymptomCaptureButton.swift
  modified:
    - AFOne/Features/Dashboard/DashboardView.swift
decisions:
  - Button implemented as Button with custom styling (not ZStack+TapGesture) per SPEC Section 8
  - AF Active state shows second button with red tint overlay
metrics:
  duration: ""
  completed_date: "2026-03-14"
---

# Phase 07 Plan 07: Symptom Capture Button - Summary

## Objective
Implement Zone 5 - Symptom Capture Button per SPECIFICATION.md Section 8. Full-width tappable element with sheet presentation.

## Completed Tasks

| # | Task | Status | Commit |
|---|------|--------|--------|
| 1 | Create SymptomCaptureButton component | Complete | f9a74f8 |
| 2 | Add accessibility support | Complete | f9a74f8 |
| 3 | Integrate into DashboardView, replace FAB | Complete | abc9fd5 |

## Implementation Details

### SymptomCaptureButton Component
- **Full-width button** with custom styling at Zone 5 of dashboard
- **SR State:**
  - Background: `Color(.secondarySystemBackground)` + RhythmSinusal tint at 8% opacity
  - Border: 1pt separator color
  - Corner radius: 18
  - Icon container: 44x44pt, tertiarySystemFill, cornerRadius 14
  - Icon: `plus.circle.fill`, title3, systemBlue
  - Labels: "Capturar síntoma" (headline), "Registrar + iniciar ECG de 30s" (subheadline)
  - Trailing: chevron.right, caption, tertiary
- **Touch target:** Minimum 44pt height with `.contentShape(RoundedRectangle(cornerRadius: 18))`
- **Action:** Presents modal sheet via `.sheet(isPresented:)`

### AF Active State
- Shows second button **above** primary button
- Uses `Color.afOne.rhythmAF.opacity(0.08)` for tint overlay
- Label: "Episodio en curso — Capturar contexto"
- Sub-label: "Registrar síntomas durante el episodio activo"
- Border: 1pt with AF color at 30% opacity

### Dashboard Integration
- Replaced floating action button (FAB) with full-width SymptomCaptureButton
- Positioned at bottom of ScrollView content (Zone 5)
- 32pt bottom padding for home indicator clearance
- Wired `showLogSheet` binding to existing sheet presentation
- Passed `isAFActive` based on `viewModel.currentStatus == .af`

### Accessibility
- Primary button: `.accessibilityLabel("Capturar síntoma")` + `.accessibilityHint()`
- AF Active button: `.accessibilityLabel("Episodio en curso — Capturar contexto")` + `.accessibilityHint()`
- Minimum 44pt touch target ensured via `.frame(minHeight: 44)`

## Deviation from Plan

None - plan executed exactly as written.

## Auth Gates

None - no authentication required.

## Self-Check

- [x] SymptomCaptureButton.swift exists with both states
- [x] Accessibility labels added to both button states
- [x] DashboardView replaces FAB with SymptomCaptureButton
- [x] Both commits verified in git log

---

*Plan: 07-07 | Phase: 07-dashboard-redesign-specification*
*Completed: 2026-03-14*
