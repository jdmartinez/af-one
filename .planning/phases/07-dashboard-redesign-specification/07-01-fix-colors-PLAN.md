---
phase: 07-dashboard-redesign-specification
plan: 07-01
subsystem: Theme
tags: [color-system, swiftui, fix]
dependency_graph:
  requires:
    - 07-02 (Color System Foundation)
  provides:
    - Working Color.afOne colors in SwiftUI
affects: [All dashboard components using brand colors]
---

# Phase 07 Fix Plan 01: Theme.swift Color Resolution

## Problem

Color.afOne colors defined in Theme.swift don't resolve in SwiftUI:
```swift
let rhythmSinusal = Color("AFOne/RhythmSinusal")  // Fails to load
```

The Color("AssetName") syntax doesn't work the same as UIKit's.

## Root Cause

SwiftUI's Color("BundlePath") requires specific asset catalog configuration that isn't working. The asset catalog colors exist but aren't being found.

## Solution

Replace Color("AFOne/X") with inline Color definitions using RGBA:

### Changes to Theme.swift

```swift
extension Color {
    static var cardBackground: Color {
        Color(.systemBackground)
    }
    
    static var secondaryText: Color {
        Color.secondary
    }
    
    static var secondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var divider: Color {
        Color(.separator)
    }
    
    static var cardShadow: Color {
        Color.primary.opacity(0.1)
    }
    
    // MARK: - AFOne Brand Colors (Inline definitions)
    static let afOne = AFOneColors()
    
    struct AFOneColors {
        // Green for Sinusal rhythm - from asset catalog values
        let rhythmSinusal = Color(red: 0.204, green: 0.757, blue: 0.373)
        // Red for AF rhythm
        let rhythmAF = Color(red: 0.839, green: 0.267, blue: 0.267)
        // Green for low burden
        let burdenLow = Color(red: 0.204, green: 0.757, blue: 0.373)
        // Amber for mid burden
        let burdenMid = Color(red: 0.976, green: 0.733, blue: 0.086)
        // Red for high burden
        let burdenHigh = Color(red: 0.839, green: 0.267, blue: 0.267)
        
        func burdenColor(for percentage: Double) -> Color {
            switch percentage {
            case ..<5.5:
                return burdenLow
            case 5.5..<11.0:
                return burdenMid
            default:
                return burdenHigh
            }
        }
    }
}
```

### Verification

1. Build the project
2. Check HeroCardView shows green dot for SR state
3. Check BurdenCardView shows threshold colors (green/amber/red)
4. Check ClinicalMetricsGridView icons have colors
5. Check SymptomCaptureButton shows background tint

## Files to Modify

- `AFOne/Shared/Extensions/Theme.swift` - Replace Color("AFOne/X") with inline definitions