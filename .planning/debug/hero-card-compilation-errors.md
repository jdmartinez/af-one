---
status: resolved
trigger: "Hero Card Compilation Errors"
created: 2026-03-14T00:00:00Z
updated: 2026-03-14T00:00:00Z
---

## Current Focus
hypothesis: All types exist but are not properly imported - HeroCardView.swift only imports SwiftUI and doesn't import the modules containing the referenced types
test: Examining import statements and type definitions across Phase 07 files
expecting: Find that types are defined but not accessible due to missing imports or missing Color Assets
next_action: Report root cause

## Symptoms
expected: Dashboard displays Hero Card (Zone 1) at top. When in normal rhythm (SR), shows green "Sinusal" indicator. When in AF, shows red gradient with "AF Activo" banner.
actual: Compilation errors - app won't build
errors:
  - "Cannot find 'DashboardViewModel', 'HeroCardView', 'BurdenCardView', 'RhythmMapView', 'ClinicalMetricsGridView', 'SymptomCaptureButton'"
  - "Cannot find 'RhythmStatus', 'RhythmEpisode', 'TimePeriod', 'BurdenDataPoint', 'ClinicalMetricsData', 'HourlyRhythmData'"
  - "Cannot find 'HealthKitService', 'AFBurdenCalculator'"
  - "Type 'Color' has no member 'afOne'"
reproduction: Test 1 in UAT
started: Discovered during UAT

## Eliminated
- hypothesis: Files don't exist
  evidence: All 45 Swift files exist in AFOne module including all Phase 07 deliverables

## Evidence
- timestamp: 2026-03-14
  checked: HeroCardView.swift imports
  found: Only imports "SwiftUI" - no import for other AFOne modules
  implication: Types in other files (HealthKitService, AFBurdenCalculator, Models) not accessible

- timestamp: 2026-03-14
  checked: Type definitions
  found: |
    - RhythmStatus: defined in HealthKitService.swift (line 42)
    - RhythmEpisode: defined in Models/RhythmEpisode.swift (line 4)
    - TimePeriod: defined in AFBurdenCalculator.swift (line 5)
    - BurdenDataPoint: defined in AFBurdenCalculator.swift (line 77)
    - ClinicalMetricsData: defined in ClinicalMetricsGridView.swift (line 5)
    - HourlyRhythmData: defined in RhythmMapView.swift (line 4)
  implication: All types ARE defined - just not accessible to HeroCardView

- timestamp: 2026-03-14
  checked: Color Assets
  found: No .colorset files exist in Assets.xcassets
  implication: Color.afOne relies on named colors (e.g., "AFOne/RhythmSinusal") that don't exist

- timestamp: 2026-03-14
  checked: Theme.swift Color.afOne usage
  found: "Color.afOne.rhythmSinusal" and "Color.afOne.rhythmAF" defined but require Color Assets
  implication: Named colors must be added to Assets.xcassets with proper color set definitions

## Resolution
root_cause: |
  MISLEADING DIAGNOSIS - The "compilation errors" are LSP errors from SourceKit-LSP, NOT actual Swift compilation failures.
  
  Root cause: **The Xcode project is missing a scheme file (.xcscheme)**
  
  Evidence:
  1. All 45 Swift files exist and are properly added to the Xcode project (verified via project.pbxproj)
  2. All referenced types ARE defined within the same module:
     - RhythmStatus: HealthKitService.swift line 42
     - RhythmEpisode: Models/RhythmEpisode.swift line 4
     - TimePeriod: AFBurdenCalculator.swift line 5
     - BurdenDataPoint: AFBurdenCalculator.swift line 77
     - ClinicalMetricsData: ClinicalMetricsGridView.swift line 5
     - HourlyRhythmData: RhythmMapView.swift line 4
  3. Actual xcodebuild fails with "Signing for AFOne requires a development team" (code signing issue, not compilation)
  4. The project has SDKROOT=iphoneos but no scheme file exists at xcuserdata/jdmartinez.xcuserdatad/xcschemes/
  
  Why LSP shows errors:
  - Without a scheme, SourceKit-LSP cannot resolve SwiftUI framework types properly
  - "Reference to member 'systemBackground' cannot be resolved" = LSP can't find iOS SDK
  - This causes cascade of "cannot find type" errors for ALL types
  
  Secondary issue: Color Assets missing
  - Color.afOne requires named colors in Assets.xcassets (AFOne/RhythmSinusal, AFOne/RhythmAF, etc.)
  - These don't exist - would cause runtime/compile errors even with proper scheme

fix: |
  1. Create an Xcode scheme file for the AFOne target
     - Or open project in Xcode and let it create the scheme automatically
  
  2. Add Color Assets to Assets.xcassets:
     - Create folder: Assets.xcassets/AFOne.colorset
     - Add color sets: RhythmSinusal (green), RhythmAF (red), BurdenLow, BurdenMid, BurdenHigh

verification: |
  After adding scheme, run xcodebuild and LSP should resolve types properly

files_changed: []
