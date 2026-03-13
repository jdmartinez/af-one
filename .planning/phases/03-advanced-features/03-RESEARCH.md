# Phase 3 Research — Advanced Features

**Phase:** 3 - Advanced Features  
**Research Mode:** Ecosystem  
**Completed:** 2026-03-12

---

## Executive Summary

Phase 3 requires implementing long-term trend visualization (6-month, 1-year views) and clinical report generation. Key findings:

1. **Swift Charts** is the standard approach - no external libraries needed
2. **ShareLink** (iOS 16+) replaces manual UIActivityViewController for share sheet
3. **Period-over-period comparison** is standard for trend analysis (not complex ML)
4. **HealthKit HKStatisticsCollectionQuery** is best for aggregated time-series data

**Confidence:** High  
**Risk:** Low - well-established patterns

---

## Standard Stack

### Primary Frameworks

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Charts | Swift Charts (Apple) | Native, optimized, no external dependencies |
| Share Sheet | ShareLink (iOS 16+) | SwiftUI-native, replaces UIKit wrapper |
| Date Aggregation | Foundation Calendar | Built-in, handles edge cases |
| Data Models | SwiftData | Already used in project |

### Why Not External Libraries?

- **AAChartKit**: Overkill for simple line charts, adds 1MB+ bundle
- **Charts (DGCharts)**: Objective-C heritage, unnecessary complexity
- **Any PDF library**: Text report format avoids PDF complexity entirely

---

## Architecture Patterns

### Pattern 1: Time-Series Aggregation

For long-term data (6 months, 1 year), aggregate before visualization:

```
6 months → Weekly averages (26 data points)
1 year   → Monthly averages (12 data points)
```

**Implementation approach:**
- Extend `AFBurdenCalculator.getChartData()` to handle new periods
- Use `Calendar.date(byAdding: .month, value: -n, to: Date())` for monthly bucketing
- Use `Calendar.date(byAdding: .weekOfYear, value: -n, to: Date())` for weekly bucketing

### Pattern 2: Period-over-Period Trend Comparison

Standard approach: Compare current period to equivalent previous period:

```
6-month trend:  Current 6-month burden vs Previous 6-month burden
1-year trend:   Current 1-year burden vs Previous 1-year burden
```

**Formula:** `percentChange = ((current - previous) / previous) * 100`

**Indicator mapping:**
- `> 10% increase` → ↑
- `> 10% decrease` → ↓
- `-10% to +10%` → →

### Pattern 3: Structured Text Report

Clinical summary follows standard EHR-compatible format:

```
[HEADER: AF CLINICAL SUMMARY]
[Date range: MM/DD/YYYY - MM/DD/YYYY]

[METRICS SECTION]
- AF Burden: X.X% (vs Y.Y% previous period)
- Episodes: N total (M lasting >1 hour)
- Average HR during episodes: N BPM
- Max HR during episodes: N BPM

[TRENDS SECTION]
 [↑/↓/→] AF Burden: ±X% change
 [↑/↓/→] Episode frequency: ±X% change

[SYMPTOMS SECTION]
- N symptoms logged (M during AF)
- Top triggers: A, B, C

[MEDICATIONS SECTION]
[List from HealthKit medications]
```

---

## Don't Hand-Roll

### 1. Date Manipulation

**Use:** Foundation `Calendar` API  
**Don't:** Calculate day boundaries manually

```swift
// CORRECT
let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))

// WRONG - Don't do this
let timestamp = Date().timeIntervalSince1970
let startOfMonth = timestamp - (timestamp % 2592000)
```

### 2. Chart Axis Formatting

**Use:** Swift Charts automatic axis marks  
**Don't:** Manually calculate tick positions

```swift
// CORRECT - Use automatic
.chartXAxis {
    AxisMarks(values: .automatic) { _ in
        AxisGridLine()
        AxisValueLabel()
    }
}
```

### 3. Share Sheet Presentation

**Use:** SwiftUI `ShareLink`  
**Don't:** Manually create UIActivityViewController unless needed

```swift
// CORRECT - iOS 16+
ShareLink(item: reportText) {
    Label("Export Report", systemImage: "square.and.arrow.up")
}

// Only use UIViewControllerRepresentable if:
// - Need completion handler
// - Need custom activities
```

---

## Common Pitfalls

### Pitfall 1: Over-aggregation

**Problem:** Too many data points make charts unreadable  
**Solution:** Aggregate to 12-26 points max (see table above)

### Pitfall 2: Edge Case - No Episodes

**Problem:** Division by zero when calculating change percentage  
**Solution:** Guard with `guard previous > 0 else { return nil }`

### Pitfall 3: Time Zone Handling

**Problem:** Calendar calculations can be inconsistent across time zones  
**Solution:** Always use `Calendar.current` consistently, never mix timeInterval calculations

### Pitfall 4: HealthKit Data Delay

**Problem:** Apple Watch may sync episodes hours later  
**Solution:** Include 24-hour buffer when querying, warn users about data freshness

### Pitfall 5: Report Completeness

**Problem:** Empty sections if no symptoms/medications logged  
**Solution:** Always show "No data available" placeholder, never omit sections

---

## Code Examples

### Example 1: Extended TimePeriod Enum

```swift
enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
    
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
    
    // NEW: aggregation interval for chart data points
    var aggregationInterval: Calendar.Component {
        switch self {
        case .day: return .hour
        case .week: return .day
        case .month: return .day
        case .sixMonths: return .weekOfYear
        case .oneYear: return .month
        }
    }
    
    // NEW: number of data points for visualization
    var chartPointCount: Int {
        switch self {
        case .day: return 24
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 26
        case .oneYear: return 12
        }
    }
}
```

### Example 2: Trend Calculation

```swift
struct TrendIndicator {
    let direction: TrendDirection
    let percentChange: Double
    
    enum TrendDirection {
        case increasing  // ↑
        case decreasing  // ↓
        case stable      // →
    }
    
    static func calculate(current: Double, previous: Double) -> TrendIndicator? {
        guard previous > 0 else { return nil }
        
        let change = ((current - previous) / previous) * 100
        
        let direction: TrendDirection
        if change > 10 {
            direction = .increasing
        } else if change < -10 {
            direction = .decreasing
        } else {
            direction = .stable
        }
        
        return TrendIndicator(direction: direction, percentChange: change)
    }
}
```

### Example 3: ShareLink for Text Report

```swift
import SwiftUI

struct ReportExportView: View {
    let reportText: String
    
    var body: some View {
        ShareLink(item: reportText, subject: Text("AF Clinical Summary")) {
            Label("Export Report", systemImage: "square.and.arrow.up")
        }
    }
}
```

### Example 4: Aggregated Chart Data

```swift
func getAggregatedChartData(for period: TimePeriod) async throws -> [BurdenDataPoint] {
    let interval = period.dateRange
    let calendar = Calendar.current
    var dataPoints: [BurdenDataPoint] = []
    
    let pointCount = period.chartPointCount
    
    for i in 0..<pointCount {
        let offset: Int
        let component: Calendar.Component
        
        switch period {
        case .sixMonths:
            offset = -i
            component = .weekOfYear
        case .oneYear:
            offset = -i
            component = .month
        default:
            offset = -i
            component = period.aggregationInterval
        }
        
        guard let periodEnd = calendar.date(byAdding: component, value: offset, to: interval.end),
              let periodStart = calendar.date(byAdding: component, value: offset - 1, to: interval.end) else {
            continue
        }
        
        let burden = try await calculateBurden(from: periodStart, to: periodEnd)
        dataPoints.append(BurdenDataPoint(date: periodEnd, percentage: burden))
    }
    
    return dataPoints.reversed()
}
```

---

## Implementation Recommendations

### Plan Structure

Based on the context decisions and code patterns, recommend 3-4 plans:

1. **Plan 01:** Extend TimePeriod + AFBurdenCalculator for 6M/1Y
2. **Plan 02:** Create TrendAnalyzer + TrendsView UI
3. **Plan 03:** Create ReportGenerator + ReportView UI  
4. **Plan 04:** Integration testing and verification

### Dependencies

```
TimePeriod extension → AFBurdenCalculator updates → TrendAnalyzer → TrendsView
                                          ↘︎
                                   ReportGenerator → ReportView
```

### Key Files to Modify

| File | Change |
|------|--------|
| `AFBurdenCalculator.swift` | Add sixMonths/oneYear to enum, add aggregation logic |
| `BurdenChartView.swift` | Add new case handling for long periods |
| `ContentView.swift` | Add Trends tab if needed |

### Key Files to Create

| File | Purpose |
|------|---------|
| `TrendAnalyzer.swift` | Period-over-period calculations |
| `TrendsView.swift` | Long-term trends UI |
| `TrendsViewModel.swift` | Trends state management |
| `ReportGenerator.swift` | Text report generation |
| `ReportView.swift` | Report display + share |
| `ReportViewModel.swift` | Report state management |
| `TrendData.swift` | Aggregated trend data models |

---

## Sources

1. Apple SwiftUI Documentation - Charts framework
2. Create with Swift - Share Sheet article (2025)
3. BleepingSwift - Share completion detection (2025)
4. STRV - HealthKit Developer Guide (2025)
5. Beda Software - HealthKit Pitfalls
6. Apple Health App patterns (native reference)

---

*Research completed for Phase 3 planning*
