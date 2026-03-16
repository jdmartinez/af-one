---
phase: 07-dashboard-redesign-specification
plan: 07-03
subsystem: Dashboard
tags: [symptom-capture, ui, fix]
dependency_graph:
  requires:
    - 07-07 (Symptom Capture Button)
  provides:
    - Fixed button positioning with safe area
affects: [DashboardView, SymptomCaptureButton]
---

# Phase 07 Fix Plan 03: Symptom Capture Button Positioning

## Problem

Symptom Capture Button:
- Shows without background color (due to Color.afOne not loading)
- Hidden half behind navigation tab bar at bottom

## Root Cause

1. Button background uses Color.afOne.rhythmSinusal.opacity(0.08) which fails to load
2. Button positioned at bottom of ScrollView without safeAreaInset

## Solution

### 1. Fix color loading (covered by Plan 07-01)

Once Theme.swift colors are fixed, the background will work.

### 2. Add safe area padding in DashboardView

Wrap SymptomCaptureButton in a safeAreaInset or add bottom padding:

```swift
// In DashboardView.swift - symptomSection computed property
private var symptomSection: some View {
    VStack(spacing: 0) {
        SymptomCaptureButton(...)
    }
    .safeAreaInset(edge: .bottom) {  // Add this
        Color.clear.frame(height: 1)
    }
    .padding(.bottom, 32)  // Add extra padding
}
```

Or move the button inside a container with proper bottom padding:

```swift
.padding(.bottom, 34)  // Extra for home indicator + tab bar
```

### Verification

1. Build and run app
2. Scroll to bottom of dashboard
3. Verify SymptomCaptureButton is fully visible above tab bar

## Files to Modify

- `AFOne/Features/Dashboard/DashboardView.swift` - Add safe area handling