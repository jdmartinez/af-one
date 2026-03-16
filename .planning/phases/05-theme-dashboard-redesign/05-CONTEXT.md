# Phase 5 Context: Theme & Dashboard Redesign

**Phase:** 5  
**Goal:** Implement dark/light theme support and redesign dashboard  
**Requirements:** UI-01, UI-02  
**Status:** Context defined - ready for research/planning

---

## Locked Decisions

These decisions are FINAL. Downstream agents MUST implement them exactly as specified.

### A. Color System Strategy

| Decision | Rationale |
|----------|-----------|
| **Use existing theme enums** | `AFStatusColor`, `HRColor`, `BurdenColor`, `ChartColors` already exist in Theme.swift - extend/adjust as needed |
| **Fix shadows with adaptive colors** | `Color.black.opacity(0.1)` in `cardShadow` breaks dark mode - change to use material or remove |
| **Keep system semantic colors** | `.green`, `.red`, `.orange` in SwiftUI adapt to dark mode automatically - no change needed |

**Implementation Notes:**
- Do NOT create new asset catalog colors - use existing code-defined semantic colors
- Do NOT replace `.green`/`.red` with custom colors - system colors are already adaptive

### B. Dashboard Card Design (Apple Health Style)

| Decision | Rationale |
|----------|-----------|
| **Use `.ultraThinMaterial`** | Replace `.shadow()` with `.background(.ultraThinMaterial)` for iOS-native look |
| **16pt rounded corners** | Apple Health uses 16pt corner radius - change from current 12pt |
| **Full-width cards** | Apple Health uses full-width cards, not 2x2 grid - redesign metric cards accordingly |
| **Card header layout** | Title on left, primary value on right (same line) |
| **Colored circle icons** | 8-12pt colored circles with SF Symbol inside (green/red/orange/blue) |
| **Large metric values** | Use `.system(size: 34, weight: .bold)` for primary values |
| **Move period picker inside AF Burden card** | Per UI-02.3 requirement - period picker goes inside the card header |
| **Remove toolbar reload button** | Per UI-02.4 requirement - keep only pull-to-refresh, remove `arrow.clockwise` toolbar button |

**Apple Health Card Anatomy:**
```
┌────────────────────────────────────────────────┐
│  Heart Rate              72  bpm              │  ← Header: title | value unit
├────────────────────────────────────────────────┤
│  ○ Resting            62  bpm                 │  ← Row: colored circle | label | value
│  ○ Walking            98  bpm                 │    Secondary values in smaller font
│  ○ Cardio             120  bpm                │
└────────────────────────────────────────────────┘
```

**Implementation Notes:**
- Card background: `.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))`
- Padding: 16pt horizontal, 12pt vertical
- No shadows - materials provide depth
- Metric cards: Convert from 2x2 grid to full-width stacked cards
- Icon format: `Circle()` with 10pt diameter, filled with semantic color, SF Symbol inside

### C. Navigation Architecture

| Decision | Rationale |
|----------|-----------|
| **Keep multiple NavigationStacks** | Each tab has its own NavigationStack - this is intentional for tab-based navigation |
| **Fix duplicate back buttons** | Use `.navigationBarBackButtonHidden(true)` in EmergencyView and ReportView to prevent double back button |
| **No architectural change** | Do NOT consolidate to single NavigationStack - not worth the complexity |

**Implementation Notes:**
- UI-03.1: Fix More > Emergency Information duplicate back button
- UI-03.2: Fix More > Clinical Report duplicate back button
- Both views should hide the back button explicitly since they're accessed via NavigationLink from MoreView

### D. Hardcoded Colors

| Decision | Rationale |
|----------|-----------|
| **Keep system colors as-is** | `.green`, `.red`, `.blue`, `.orange` are already adaptive in SwiftUI |
| **Only fix shadow color** | The `cardShadow` computed property is the only broken color |

**Implementation Notes:**
- Do NOT migrate to asset catalog colors - unnecessary complexity
- The existing `AFStatusColor.color(for:)` pattern is good, use it where applicable
- Focus implementation effort on the shadow fix, not color migration

---

## Code Context

### Files to Modify

| File | Changes Needed |
|------|----------------|
| `AFOne/Shared/Extensions/Theme.swift` | Update for Apple Health style (may add new card styles) |
| `AFOne/Features/Dashboard/DashboardView.swift` | Full redesign: materials, 16pt corners, full-width cards, header layout, colored icons, remove toolbar button |
| `AFOne/Features/Dashboard/MetricCardView.swift` | May need to create or modify for new card style |
| `AFOne/Features/More/MoreView.swift` | No changes needed |
| `AFOne/Features/More/EmergencyView.swift` | Add `.navigationBarBackButtonHidden(true)` |
| `AFOne/Features/Reports/ReportView.swift` | Add `.navigationBarBackButtonHidden(true)` |

### Current Patterns (Preserve These)

```swift
// Theme.swift - Keep these patterns
static var cardBackground: Color { Color(.systemBackground) }  // ✅ Works
AFStatusColor.color(for: status)  // ✅ Works
BurdenColor.color(for: burden)    // ✅ Works

// DashboardView.swift - Keep these patterns
@State private var viewModel = DashboardViewModel()
.toolbar { ... }
.refreshable { ... }
```

### What to Avoid

| Anti-Pattern | Why |
|--------------|-----|
| Creating asset catalog colors | Not needed - system colors are adaptive |
| Consolidating NavigationStack | Over-engineering for this issue |
| Replacing all hardcoded colors | System colors already work |
| Using `.cornerRadius()` modifier | Use `.clipShape(RoundedRectangle(...))` instead |

---

## Requirements Coverage

| Requirement | Implementation Approach |
|-------------|------------------------|
| UI-01 (Dark/Light theme) | Fix `cardShadow` in Theme.swift, use materials throughout |
| UI-02 (Dashboard redesign) | Full Apple Health redesign: materials, 16pt corners, full-width cards, header layout, colored circle icons |
| UI-02.1 (Card titles) | Add clear titles - already present, ensure consistency |
| UI-02.2 (Card icons) | Add colored circle icons (10pt circles with SF Symbols) using semantic colors |
| UI-02.3 (Period picker) | Move inside AF Burden card header |
| UI-02.4 (Remove reload) | Remove toolbar button, keep pull-to-refresh |
| UI-02.5 (Borders) | Use materials - no shadow/border issues |
| UI-02.6 (Toolbar labels) | Add `.help("description")` to toolbar buttons |
| UI-03 (Navigation fixes) | Add `.navigationBarBackButtonHidden(true)` to Emergency/Report views |

---

## Next Steps

1. **Research Phase:** Not needed - all technical approaches are well-understood
2. **Plan Phase:** Create execution plans for implementing the decisions above

---

*Context created: 2026-03-13*
