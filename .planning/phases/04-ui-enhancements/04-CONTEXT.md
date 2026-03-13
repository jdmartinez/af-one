# Phase 4 Context - UI Enhancements

**Phase:** 4 - UI Enhancements  
**Created:** 2026-03-13  
**Purpose:** Decisions that guide research and planning for Phase 4 implementation

---

## Decisions

### 1. Theme System Implementation

**Decision:** Color scheme detection using `@Environment(\.colorScheme)` + Color extension

**Rationale:**
- SwiftUI's built-in environment provides clean detection
- Color extension keeps global styling centralized
- Data-specific colors (AF severity) stay hardcoded for medical clarity

**Implementation:**
```swift
// Shared/Extensions/Theme.swift
import SwiftUI

extension Color {
    static var cardBackground: Color {
        Color(.systemBackground)
    }
    
    static var secondaryText: Color {
        Color(.secondaryLabel)
    }
    
    static var cardShadow: Color {
        Color.black.opacity(0.1)
    }
}

// Usage in views
CardView()
    .background(Color.cardBackground)
```

**Non-adaptive colors (stays hardcoded):**
- AF status: `.red` (always means AF)
- Normal rhythm: `.green` (always means normal)
- High HR warning: `.orange`
- Medical thresholds: consistent across themes

---

### 2. Dashboard Card Redesign

**Decision:** 2-column grid layout with expanded card details

**Rationale:**
- 2-column grid easier to scan than horizontal scroll
- PAF patients need quick clarity, not gamification
- Expanded details with time context prevent confusion

**Implementation:**
```swift
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
    MetricCardView(...)
    MetricCardView(...)
}
```

**Card Enhancements:**
- Add time context: "Last 7 days", "Last 24h"
- Add comparison to previous period where available
- Keep trend arrows (↑↓→)
- Consider adding "last updated" timestamp more prominently

**Comparison Badge Pattern:**
```swift
HStack {
    Text("12.3%")
    Text("vs last week: +2%")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

---

### 3. Additional UI Improvements

**Decision:** Empty states + Loading indicators (transitions = standard iOS)

**Rationale:**
- Empty states critical for just-joined users (no HealthKit data yet)
- Loading states prevent confusion during HealthKit queries
- Standard transitions are sufficient, no custom animations needed

**Empty State Implementation:**
```swift
if viewModel.dataEmpty {
    VStack {
        Image(systemName: "heart.text.square")
            .font(.largeTitle)
        Text("No heart rhythm data yet")
            .font(.headline)
        Text("Open Health app to enable heart monitoring")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}
```

**Per-View Empty Messages:**
| View | Empty Message |
|------|---------------|
| Dashboard | "No recent heart data. Keep Apple Watch on to monitor." |
| Episodes | "No AF episodes detected. That's good news!" |
| Timeline | "No rhythm data available yet." |
| Trends | "Need at least 7 days of data for trends." |

**Loading State:**
```swift
if viewModel.isLoading {
    ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

---

### 4. Hybrid Global/Local Styling

**Decision:** Global Color extension for UI chrome, local semantic constants for data

**Rationale:**
- Global: Card backgrounds, dividers, text colors - adapt to theme
- Local: AF severity, HR ranges - semantically meaningful, don't change by theme

**File Structure:**
```
AFOne/
├── Shared/
│   └── Extensions/
│       └── Theme.swift    // NEW: Color extension
```

**Theme.swift Contents:**
```swift
import SwiftUI

// Global - adapts to color scheme
extension Color {
    static var cardBackground: Color { Color(.systemBackground) }
    static var secondaryText: Color { Color(.secondaryLabel) }
    static var cardShadow: Color { Color.black.opacity(0.1) }
    static var divider: Color { Color(.separator) }
}

// Local - stays constant (data-specific)
enum AFStatusColor {
    static let normal = Color.green
    static let af = Color.red
    static let unknown = Color.gray
}

enum HRColor {
    static let normal = Color.green
    static let elevated = Color.orange
    static let high = Color.red
}
```

---

## Code Context

### Project Structure (Phase 4)

```
AFOne/
├── Shared/
│   └── Extensions/
│       └── Theme.swift              # NEW: Color extension + semantic enums
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift      # UPDATE: Grid layout, empty states
│   │   └── DashboardViewModel.swift # UPDATE: isLoading, dataEmpty states
│   ├── Episodes/
│   │   └── EpisodeListView.swift    # UPDATE: Empty state
│   ├── Timeline/
│   │   └── TimelineView.swift       # UPDATE: Empty state
│   └── Trends/
│       └── TrendsView.swift         # UPDATE: Empty state + loading
```

### Key Implementation Notes

1. **Theme.swift** centralized color definitions
2. **@Environment(\.colorScheme)** accessed via Color computed properties
3. **Data-specific colors** (AF, HR) remain hardcoded - medical clarity
4. **Empty states** per-view with context-appropriate messages
5. **Loading states** using ProgressView (simple, sufficient)
6. **Grid layout** uses `LazyVGrid` with 2 columns

---

## Prior Context References

- **Phase 1 CONTEXT.md:** Navigation (TabView), Authorization UX, Timeline viz, Data sync, Emergency info
- **Phase 2 CONTEXT.md:** TimePeriod enum, BurdenChartView, multi-window burden, FAB + bottom sheet
- **Phase 3 CONTEXT.md:** Long-term trends, clinical report format, Swift Charts patterns
- **PROJECT.md:** Privacy-first, offline-first, not a medical device
- **STATE.md:** Pending todos: dark/light theme, dashboard redesign

---

## Requirements Coverage (from STATE.md pending todos)

| Todo | Feature | Decision |
|------|---------|----------|
| 1 | Dark/light theme support | Color scheme detection + Theme.swift |
| 2 | Dashboard redesign | 2-column grid + expanded details |

---

## Next Steps

**For Research Agent:**
- SwiftUI LazyVGrid performance patterns
- Empty state UX best practices
- HealthKit query loading handling

**For Planning Agent:**
- Task breakdown for Phase 4
- Theme.swift creation → Dashboard update → Other views empty states
- Consider 2-3 plans for Phase 4

---

*Context created: 2026-03-13*
*Discuss-phase completed*