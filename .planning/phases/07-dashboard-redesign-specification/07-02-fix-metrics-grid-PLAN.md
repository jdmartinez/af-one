---
phase: 07-dashboard-redesign-specification
plan: 07-02
subsystem: Dashboard
tags: [clinical-metrics, ui, fix]
dependency_graph:
  requires:
    - 07-06 (Clinical Metrics Grid)
  provides:
    - Fixed grid layout matching SPEC
affects: [ClinicalMetricsGridView]
---

# Phase 07 Fix Plan 02: Clinical Metrics Grid Layout

## Problem

Clinical Metrics Grid shows:
- Icons too big and not colored
- Uneven card heights
- Symptoms card taking one column instead of two
- HRV card aligned vertically instead of horizontally

## Root Cause

MetricCard component and ClinicalMetricsGridView don't match SPEC.md Section 7 specifications.

## Solution

### 1. Fix icon sizing and coloring in MetricCard

Update icon sizing to be smaller and add Color.afOne colors.

### 2. Fix grid span for Symptoms card

The "unmatched symptoms" card should span 2 columns using `.gridCellColumns(2)`

### 3. Standardize card heights

All cards should have consistent minimum heights.

### Changes to ClinicalMetricsGridView.swift

```swift
// At the top of the view definition
struct ClinicalMetricsGridView: View {
    // Add fixed icon size constant
    private let iconSize: CGFloat = 24  // Was likely larger
    
    // In the unmatched symptoms card section:
    .gridCellColumns(2)  // Make it span 2 columns
}

// Inside MetricCard or inline
// Fix icon sizing:
// Change from .font(.title) to .font(.body)
// Change frame from 44x44 to 28x28 or similar
```

### Verification

1. Build and run app
2. Check all 5 cards display with consistent heights
3. Check icons are smaller and colored
4. Check Symptoms card spans full width

## Files to Modify

- `AFOne/Features/Dashboard/ClinicalMetricsGridView.swift`