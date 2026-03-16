---
status: diagnosed
phase: 07-dashboard-redesign-specification
source: 07-02-SUMMARY.md, 07-03-SUMMARY.md, 07-04-SUMMARY.md, 07-06-SUMMARY.md, 07-07-SUMMARY.md
started: 2026-03-14T17:45:00Z
updated: 2026-03-14T18:35:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Hero Card Rhythm State Display
expected: Dashboard displays Hero Card (Zone 1) at top. When in normal rhythm (SR), shows green "Sinusal" indicator with confidence badge and 3-column stats. When in AF, shows red gradient with "AF Activo" banner.
result: pass

### 2. Hero Card Pulsing Animation
expected: When in AF Active state, the rhythm indicator pulses with a smooth animation. Animation respects Accessibility Reduce Motion setting.
result: pass

### 3. AF Episode Real-Time Timer
expected: During AF episode, a timer displays counting up (e.g., "00:15:32" for 15 min 32 sec). Timer updates in real-time.
result: skipped
reason: "Cannot trigger AF episode to test - requires actual AF event"

### 4. Emergency Call Button
expected: In AF Active state, an emergency call button is visible. Tapping it opens the phone dialer with 112 pre-filled (tel://112).
result: skipped
reason: "Cannot trigger AF episode to test - requires actual AF event"

### 5. AF Burden Card Color Coding
expected: AF Burden Card (Zone 2) shows percentage with color coding: green for <5.5%, amber for 5.5-10.9%, red for ≥11%. Colors match clinical thresholds.
result: issue
reported: "Color issues, no percentage value at all, progress bar without any color"
severity: major

### 6. AF Burden Time Period Picker
expected: AF Burden Card has segmented picker with 24h, 7d, 30d options. Selecting different periods updates the displayed burden value.
result: issue
reported: "No value is displayed"
severity: major

### 7. AF Burden Progress Bar
expected: AF Burden Card shows progress bar with gradient fill. Progress bar has tick marks at 5.5% and 11% positions. Legend shows risk levels.
result: issue
reported: "Progress bar is present with no fill or tick marks"
severity: major

### 8. AF Burden Delta Trend
expected: AF Burden Card shows delta comparison vs previous week (e.g., "+3.2%" or "-1.5%"). Color indicates increase (red) or decrease (green).
result: issue
reported: "Delta missing"
severity: major

### 9. Clinical Metrics Grid Layout
expected: Zone 4 shows Clinical Metrics Grid with 5 cards in 2-column layout: SpO₂, HRV, ventricular response, episode duration, unmatched symptoms.
result: issue
reported: "All cards displayed but in with grid and different heights. Icons too big and not coloured. HRV card aligned vertically. Sympthoms card takes one column (left) when it should take two"
severity: minor

### 10. Symptom Capture Button
expected: At bottom of dashboard (Zone 5), full-width button labeled "Capturar síntoma" with subtitle "Registrar + iniciar ECG de 30s". Tapping opens symptom log sheet.
result: issue
reported: "Full width without background colour and it hides half of it because is behind navigation tab bar"
severity: major

### 11. Symptom Button AF Active State
expected: When rhythm is AF Active, button appearance changes: shows "Episodio en curso — Capturar contexto" with red tint overlay and border.
result: skipped
reason: "Cannot trigger AF episode to test - requires actual AF event"

### 12. Color Theme Adaptation
expected: All colors (brand colors, metric colors, status indicators) respond correctly to light/dark mode. App uses semantic iOS colors for backgrounds.
result: issue
reported: "Light mode cards have light grey colour and dark grey in dark color. No dot at all in sinusal rhythm card. Only color displayed are bars in Rythm map card"
severity: major

## Summary

total: 12
passed: 2
issues: 7
pending: 0
skipped: 3

## Gaps

- truth: "AF Burden Card shows percentage with threshold-based color coding"
  status: failed
  reason: "User reported: Color issues, no percentage value at all, progress bar without any color"
  severity: major
  test: 5
  root_cause: "Color.afOne colors not loading from asset catalog - Color('AFOne/RhythmSinusal') doesn't resolve in SwiftUI. Also currentBurden is 0.0 in ViewModel."
  artifacts:
    - path: "AFOne/Shared/Extensions/Theme.swift"
      issue: "Color extension uses Color('AFOne/RhythmSinusal') which may not resolve correctly in SwiftUI"
    - path: "AFOne/Features/Dashboard/DashboardViewModel.swift"
      issue: "currentBurden initialized to 0.0, needs to load from HealthKit"
  missing:
    - "Fix Color extension to use inline colors or Color.accentColor instead of asset catalog references"
    - "Populate currentBurden from HealthKit data"

- truth: "AF Burden Time Period Picker shows options and updates value"
  status: failed
  reason: "User reported: No value is displayed"
  severity: major
  test: 6
  root_cause: "Same root cause as test 5 - Color.afOne colors not loading, and burden data not populated from HealthKit"
  artifacts:
    - path: "AFOne/Shared/Extensions/Theme.swift"
      issue: "Color.afOne.* colors not resolving"
  missing:
    - "Fix color loading in Theme.swift"
    - "Ensure burden data is loaded from HealthKit"

- truth: "AF Burden Progress Bar shows gradient fill and tick marks"
  status: failed
  reason: "User reported: Progress bar is present with no fill or tick marks"
  severity: major
  test: 7
  root_cause: "Same as test 5 - burdenColor function returns non-functional colors when Color.afOne fails to load"
  artifacts:
    - path: "AFOne/Shared/Extensions/Theme.swift"
      issue: "burdenColor() uses Color.afOne which fails to load"
  missing:
    - "Fix Color.afOne color loading"

- truth: "AF Burden Delta Trend shows week-over-week comparison"
  status: failed
  reason: "User reported: Delta missing"
  severity: major
  test: 8
  root_cause: "Same root cause - delta row uses Color.afOne.rhythmAF and rhythmSinusal which fail to load"
  artifacts:
    - path: "AFOne/Features/Dashboard/BurdenCardView.swift"
      issue: "deltaColor uses failing Color.afOne colors"
  missing:
    - "Fix Color.afOne color loading"

- truth: "Clinical Metrics Grid shows 5 cards in proper 2-column layout with correct styling"
  status: failed
  reason: "User reported: Icons too big, not coloured, wrong heights, Symptoms card not spanning 2 columns"
  severity: minor
  test: 9
  root_cause: "MetricCard component sizing and grid layout configuration not matching SPEC"
  artifacts:
    - path: "AFOne/Features/Dashboard/ClinicalMetricsGridView.swift"
      issue: "Icons not colored, uneven heights, Symptoms card grid span incorrect"
  missing:
    - "Add icon colors using Color.afOne.*"
    - "Fix grid span for Symptoms card"
    - "Standardize card heights"

- truth: "Symptom Capture Button displays correctly at bottom with proper background and spacing"
  status: failed
  reason: "User reported: Full width without background colour and it hides half of it because is behind navigation tab bar"
  severity: major
  test: 10
  root_cause: "Button background uses Color.afOne.rhythmSinusal.opacity(0.08) which fails to load, and missing safeArea padding"
  artifacts:
    - path: "AFOne/Features/Dashboard/SymptomCaptureButton.swift"
      issue: "Background overlay uses Color.afOne which fails to load"
    - path: "AFOne/Features/Dashboard/DashboardView.swift"
      issue: "SymptomCaptureButton positioned without bottom safeArea padding"
  missing:
    - "Fix Color.afOne loading or use fallback colors"
    - "Add .safeAreaInset(bottom:) or padding to avoid tab bar"

- truth: "Color Theme Adaptation - brand colors display correctly in light/dark mode"
  status: failed
  reason: "User reported: Light mode cards have light grey colour, no dot in sinusal rhythm card, only bars show in Rhythm map"
  severity: major
  test: 12
  root_cause: "Color.afOne colors in Theme.swift extension not resolving from asset catalog - SwiftUI Color('AFOne/X') doesn't work the same as UIKit"
  artifacts:
    - path: "AFOne/Shared/Extensions/Theme.swift"
      issue: "Uses Color('AFOne/RhythmSinusal') which doesn't resolve in SwiftUI"
  missing:
    - "Use inline Color definitions or NSColor conversion"