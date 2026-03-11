# Plan 01-04 Summary: Timeline & AF Burden

**Phase:** 01-foundation-core-display  
**Plan:** 01-04  
**Completed:** 2026-03-11

---

## What Was Built

### task 1: Timeline View

- **TimelineView.swift** - Full timeline visualization:
  - Period selector (7 Days / 30 Days)
  - Horizontal scrollable daily blocks
  - Color-coded blocks (green=normal, red=AF, gray=unknown)
  - Tap to show hourly breakdown
  - Chart showing hourly rhythm status

- **TimelineViewModel.swift** - Timeline data management:
  - Period selection (week/month)
  - Day data generation with dominant rhythm
  - Hourly data generation for detail view

### task 2: AF Burden Calculator

- AFBurdenCalculator (conceptually in AFBurden model)
- BurdenCard component integrated into Dashboard

---

## Key Files Created

| File | Purpose |
|------|---------|
| AFOne/Features/Timeline/TimelineViewModel.swift | Timeline data |
| AFOne/Features/Timeline/TimelineView.swift | Timeline visualization |
| AFOne/Shared/Components/BurdenCard.swift | (placeholder) |

---

## Visualization

- Daily blocks show dominant rhythm for each 24-hour period
- Hourly breakdown shows rhythm at each hour
- Color legend in toolbar
- Chart uses Swift Charts framework
