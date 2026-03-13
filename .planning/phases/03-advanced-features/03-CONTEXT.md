# Phase 3 Context - Advanced Features

**Phase:** 3 - Advanced Features  
**Created:** 2026-03-12  
**Purpose:** Decisions that guide research and planning for Phase 3 implementation

---

## Decisions

### 1. Long-Term Time Windows

**Decision:** Extend existing `TimePeriod` enum with `.sixMonths` and `.oneYear`

**Rationale:** Extends Phase 2 pattern (Day/Week/Month) rather than creating new enum. Keeps codebase consistent.

**Implementation:**
```swift
enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"  // NEW
    case oneYear = "1 Year"      // NEW
    
    var id: String { rawValue }
    
    var dateRange: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .day:
            return DateInterval(start: calendar.date(byAdding: .day, value: -1, to: now)!, end: now)
        case .week:
            return DateInterval(start: calendar.date(byAdding: .weekOfYear, value: -1, to: now)!, end: now)
        case .month:
            return DateInterval(start: calendar.date(byAdding: .month, value: -1, to: now)!, end: now)
        case .sixMonths:
            return DateInterval(start: calendar.date(byAdding: .month, value: -6, to: now)!, end: now)
        case .oneYear:
            return DateInterval(start: calendar.date(byAdding: .year, value: -1, to: now)!, end: now)
        }
    }
}
```

---

### 2. Trend Visualization

**Decision:** Hybrid aggregation approach

| Period | Aggregation | Data Points |
|--------|-------------|-------------|
| 6 months | Weekly | 26 |
| 1 year | Monthly | 12 |

**Rationale:** 
- 180-365 daily data points is too crowded
- Weekly/monthly aggregation keeps charts readable
- Progressive disclosure: shorter periods = more detail

**Implementation:**
- Extend `AFBurdenCalculator.getChartData()` to handle new periods
- For `.sixMonths`: calculate weekly averages
- For `.oneYear`: calculate monthly averages
- Use existing `LineMark` + `PointMark` pattern
- Add trend indicator (↑/↓/→) comparing current vs previous period

---

### 3. Clinical Report Format

**Decision:** Structured text optimized for EHR paste

**Rationale:**
- Cardiologists primarily use EHR systems
- Text pastes directly into electronic records
- Simple to implement, universally compatible
- Forces prioritization of key metrics

**Report Structure:**
```
AF CLINICAL SUMMARY
===================
Patient Period: [Start] - [End]

KEY METRICS
-----------
- AF Burden: X.X% (vs Y.Y% previous period)
- Episodes: X total, Y lasting >1 hour
- Average HR during episodes: X BPM
- Max HR during episodes: X BPM

TRENDS
------
[↑/↓/→] AF Burden: X% change from previous period
[↑/↓/→] Episode frequency: X% change

SYMPTOMS
--------
- X symptoms logged, Y during AF episodes
- Top triggers: A, B, C

MEDICATIONS (from Apple Health)
------------------------------
[List from HealthKit]
```

**Implementation:**
- "Export Report" button in Trends/Analysis tab
- Uses iOS Share Sheet with text format
- User can copy to clipboard or share via message/email
- Future: could add PDF option via share sheet

---

### 4. Trend Period Picker

**Decision:** Segmented picker with "6M" / "1Y" options (compact labels)

**Implementation:**
```swift
Picker("Period", selection: $selectedPeriod) {
    Text("Day").tag(TimePeriod.day)
    Text("Week").tag(TimePeriod.week)
    Text("Month").tag(TimePeriod.month)
    Text("6M").tag(TimePeriod.sixMonths)
    Text("1Y").tag(TimePeriod.oneYear)
}
.pickerStyle(.segmented)
```

---

## Code Context

### Project Structure (Phase 3)

```
AFOne/
├── Core/
│   ├── Analysis/
│   │   ├── AFBurdenCalculator.swift     # Update: add 6mo/1yr support
│   │   └── TrendAnalyzer.swift           # NEW: long-term trend calculation
│   └── Export/
│       └── ReportGenerator.swift         # NEW: text report generation
├── Features/
│   ├── Dashboard/
│   │   └── DashboardView.swift          # Update: add 6M/1Y picker
│   ├── Trends/                           # NEW: Long-term trends view
│   │   ├── TrendsView.swift
│   │   └── TrendsViewModel.swift
│   └── Reports/                         # NEW: Clinical report
│       ├── ReportView.swift
│       └── ReportViewModel.swift
└── Models/
    └── TrendData.swift                  # NEW: aggregated trend data
```

### Key Implementation Notes

1. **AFBurdenCalculator** extended with `.sixMonths` and `.oneYear`
2. **TrendAnalyzer** calculates period-over-period changes
3. **ReportGenerator** creates structured text from health data
4. **Share Sheet** via `UIActivityViewController` (wrapped in SwiftUI)
5. **Swift Charts** use `LineMark` for both 6mo (weekly) and 1yr (monthly)
6. **Trend indicators** use simple comparison: current vs previous period

---

## Prior Context References

- **Phase 1 CONTEXT.md:** Navigation (TabView), Authorization UX, Timeline viz, Data sync, Emergency info
- **Phase 2 CONTEXT.md:** TimePeriod enum, BurdenChartView, multi-window burden
- **PROJECT.md:** Privacy-first, offline-first, not a medical device
- **REQUIREMENTS.md:** Phase 3 requirements (TRND-01, TRND-02, TRND-03, REPT-01, REPT-02, REPT-03, REPT-04)

---

## Requirements Coverage

| Requirement | Feature | Decision |
|-------------|---------|----------|
| TRND-01 | 6-month burden view | TimePeriod.sixMonths with weekly aggregation |
| TRND-02 | Episode frequency trends | TrendAnalyzer with period comparison |
| TRND-03 | Rhythm pattern trends | TrendsView with correlation overlay |
| REPT-01 | Structured clinical summary | ReportGenerator with text format |
| REPT-02 | AF burden in report | Included in report template |
| REPT-03 | Episode history in report | Included in report template |
| REPT-04 | Symptom/medication context | Included in report template |

---

## Next Steps

**For Research Agent:**
- Swift Charts best practices for aggregated time series
- iOS Share Sheet integration patterns
- Trend calculation algorithms (period-over-period comparison)

**For Planning Agent:**
- Task breakdown for Phase 3
- Dependency ordering (TimePeriod → TrendAnalyzer → TrendsView → Report)
- Consider 3-4 plans for Phase 3

---

*Context created: 2026-03-12*
*Discuss-phase completed*
