# Research: Phase 6 - Polish & Localization

**Phase:** 6  
**Goal:** Add Liquid Glass effects and localization support  
**Requirements:** UI-03, UI-04, UI-05  
**Researched:** 2026-03-14

---

## Executive Summary

Phase 6 requires implementing three main features:
1. **UI-03:** Navigation fixes (already completed in Phase 5)
2. **UI-04:** Liquid Glass tab bar with collapse on scroll
3. **UI-05:** Full localization support

This research provides implementation guidance for UI-04 and UI-05, with confirmation that UI-03 is already complete.

---

## 1. iOS 26 Liquid Glass APIs for TabView

### Available APIs

SwiftUI's Material system provides glassy backgrounds:
- `.ultraThinMaterial`, `.thinMaterial`, `.regularMaterial`, `.thickMaterial`, `.barMaterial`
- These work with backgrounds and overlays for liquid glass aesthetics

### Implementation Approaches

**Option A: Apply glass to built-in TabView**
- Use a container with material background behind the TabView
- Pros: Minimal code changes
- Cons: Limited control over tab bar appearance

**Option B: Custom Glass Bottom Bar (Recommended)**
- Create a bespoke bottom bar with Material background
- Full control over animation, blur, and collapse behavior
- Matches Phase 5's ultraThinMaterial patterns
- Cons: More code to implement

### Implementation Pattern

```swift
// GlassBottomBar component
struct GlassBottomBar: View {
    let selection: Int
    let onSelect: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7) { index in
                tabButton(for: index)
            }
        }
        .frame(height: 49)
        .background(.ultraThinMaterial)  // Liquid Glass effect
    }
}
```

### Availability Checks

```swift
var body: some View {
    if #available(iOS 26.0, *) {
        // Use enhanced Liquid Glass APIs
        GlassBottomBar(...)
    } else {
        // Fallback to standard material
        StandardBottomBar(...)
    }
}
```

---

## 2. Tab Bar Collapse on Scroll (UI-04.2)

### Core Concept
Hide the tab bar as user scrolls down to maximize vertical space, reveal on scroll up.

### Implementation Pattern

**Step 1: Create scroll offset publisher**

```swift
// ScrollOffsetTracker.swift
import SwiftUI

struct ScrollOffsetTracker: ViewModifier {
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
                }
            )
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

**Step 2: Track offset in child views and propagate**

```swift
// In DashboardView or other scrollable views
@State private var scrollOffset: CGFloat = 0
@State private var isTabBarVisible: Bool = true

var body: some View {
    ScrollView {
        // content
    }
    .onPreferenceChange(ScrollOffsetKey.self) { newOffset in
        // Hide tab bar when scrolling down past threshold
        withAnimation(.easeInOut(duration: 0.3)) {
            isTabBarVisible = newOffset > -50 && scrollOffset < newOffset
            scrollOffset = newOffset
        }
    }
}
```

**Step 3: Custom tab bar responds to visibility state**

```swift
struct GlassBottomBar: View {
    let isVisible: Bool
    
    var body: some View {
        GlassBottomBarContent()
            .offset(y: isVisible ? 0 : 100)  // Animate in/out
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}
```

### Alternative: Custom Tab View with Scroll Detection

Create a custom tab container that manages both content switching and tab bar visibility:

```swift
struct GlassTabContainer: View {
    @State private var selectedTab: Int = 0
    @State private var isTabBarVisible: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            tabContent
            
            // Glass bottom bar
            GlassBottomBar(
                selection: selectedTab,
                isVisible: isTabBarVisible
            )
        }
    }
}
```

---

## 3. Localization Strategy (UI-05)

### Localization Approach

**Primary: Localizable.xcstrings (Modern Xcode)**
- JSON-based string catalog
- Supports multiple languages
- Easy to edit and maintain

**Alternative: Localizable.strings (Traditional)**
- Key-value pairs in .strings files
- Requires folder structure (en.lproj, fr.lproj, etc.)

### Create String Catalog

1. In Xcode: File → New → String Catalog
2. Name: `Localizable`
3. Add translations for each language

### Code Patterns

**Pattern 1: SwiftUI automatic localization**
```swift
// SwiftUI uses Localizable automatically
Label("Dashboard", systemImage: "house.fill")
// No changes needed - uses catalog automatically
```

**Pattern 2: Dynamic strings**
```swift
String(localized: "Checking HealthKit...")
```

**Pattern 3: Locale-aware formatting**
```swift
// Dates
let formatter = DateFormatter()
formatter.dateStyle = .medium
formatter.timeStyle = .short

// Numbers
let numberFormatter = NumberFormatter()
numberFormatter.numberStyle = .decimal
```

### Required Strings

From ContentView.swift:
- "Dashboard"
- "Timeline"
- "Episodes"
- "Medications"
- "Analysis"
- "Trends"
- "More"
- "Checking HealthKit..."

From other views, identify all user-facing strings:
- Card titles and labels
- Button labels
- Error messages
- Tooltips

### RTL Layout Readiness

- Use `.leading` and `.trailing` instead of `.left` and `.right`
- Use `LayoutDirection` to test
- SwiftUI handles RTL automatically with semantic layouts

---

## 4. UI-03 Status (Navigation Fixes)

**Status: COMPLETE**

Phase 5 already implemented UI-03 fixes:
- `EmergencyView.swift` has `.navigationBarBackButtonHidden(true)`
- `ReportView.swift` has `.navigationBarBackButtonHidden(true)`

No additional work required for UI-03.

---

## 5. Implementation Plan Summary

### Plan 1: Liquid Glass Tab Bar with Collapse
- Create GlassBottomBar component
- Add scroll offset tracking
- Implement collapse/expand animation
- Add iOS 26 availability checks

### Plan 2: Localization Foundation
- Create Localizable.xcstrings
- Add all user-facing strings
- Test locale-aware formatting
- Verify RTL readiness

### Plan 3: String Catalog Population
- Audit all Swift files for strings
- Add translations for key languages
- Verify in simulator with different locales

---

## 6. Dependencies

- Phase 5 theme system (ultraThinMaterial) - established
- ContentView.swift TabView structure - baseline
- No new external dependencies required

---

## 7. Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| iOS 26 APIs not available | Use `#available` guards with fallback to material |
| Custom tab bar complexity | Start with overlay approach, simplify if needed |
| Incomplete string coverage | Audit all views systematically |
| RTL layout issues | Test with VoiceOver and RTL locales |

---

## 8. Validation Approach

- **UI-04:** Manual test scroll in Dashboard/Timeline, verify tab bar hides/shows
- **UI-05:** Change simulator language, verify UI updates
- **Availability:** Test on iOS 26 simulator and iOS 25 device/simulator

---

*Research completed: 2026-03-14*
*Next: Create execution plans for Phase 6*