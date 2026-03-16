# Technical Concerns

**Analysis Date:** 2026-03-14

## Overview
The AFOne dashboard heavily relies on asynchronous data fetching from HealthKit and a custom AF Burden calculator. While the implementation works, several technical concerns have been identified that could affect maintainability, reliability, and user experience.

## 1. Error Handling & Fallbacks
- **HealthKit errors** are caught generically and replaced with sample data. This masks real failures and does not inform the user.
- **No user-facing error state**: the UI shows a loading view or empty state, but never a *“Something went wrong”* message.
- **Potential data loss**: If HealthKit fetching fails partially (e.g., only episodes), the current code still proceeds with whatever data was retrieved, possibly leading to inconsistent UI.

## 2. Async Concurrency
- **Sequential awaits** in `loadData()` (status → burden → episodes → heart rate) can be parallelized to reduce load time.
- **No cancellation**: If the view disappears while loading, the tasks continue and may update a deallocated view model.
- **Missing `Task` cancellation tokens**: `Task` created in `refresh()` is not cancellable.

## 3. Dependency Injection & Testability
- **Hard‑coded singletons** (`HealthKitService.shared`, `AFBurdenCalculator.shared`) make unit testing difficult.
- **No protocol abstraction** for these services; mocking would require subclassing or method swizzling.
- **ViewModel lacks injectable dependencies**, so tests cannot replace real services with fakes.

## 4. UI & Accessibility
- **Dynamic type**: The dashboard uses many hard‑coded font sizes (e.g., `font(.system(size: 36, weight: .bold))`). These should respect the user's preferred text size.
- **Color contrast**: Custom semantic colors (`AFOne/RhythmSinusal`, `AFOne/RhythmAF`) are used for icons and backgrounds without explicit contrast checks.
- **VoiceOver labels**: Many UI elements (e.g., status icons) lack `.accessibilityLabel` or `.accessibilityHint`.

## 5. Performance & Memory
- **Large data fetches**: `fetchHeartRateSamples` pulls all samples for the past week; this could be heavy on older devices.
- **Repeated chart data generation**: `loadBurden()` fetches chart data each time the period changes, even if the data hasn't changed.
- **Potential memory leak**: The view model holds onto arrays (`recentEpisodes`, `burdenData`) that grow unbounded if not trimmed.

## 6. Security & Permissions
- **HealthKit permission flow** is not visible in the view model; if permissions are denied, the app will silently fail.
- **No handling of sensitive data**: Heart rate and rhythm episodes are personal health information; the code does not log or expose these beyond the UI.

## 7. Testing Gaps
- **No unit tests** for `DashboardViewModel`; critical functions like `calculateTrend()` and `loadBurden()` lack coverage.
- **No UI tests** for the dashboard navigation or refresh action.
- **No integration tests** for the HealthKit service.

## 8. Documentation
- **Missing inline documentation** for public methods and properties.
- **No README** describing the expected data flow or how to mock services.

## Recommendations
1. **Introduce protocols** (`HealthKitProviding`, `AFBurdenCalculating`) and inject them into the view model.
2. **Parallelize data fetching** using `async let` or `TaskGroup`.
3. **Add cancellation** for ongoing tasks when the view disappears.
4. **Implement user‑visible error handling** (e.g., a banner or modal).
5. **Replace hard‑coded font sizes** with `font(.title2)` etc., and ensure dynamic type scaling.
6. **Add accessibility labels** to all interactive UI elements.
7. **Add unit tests** for all view model logic and **UI tests** for the dashboard.
8. **Document permission handling** and provide a fallback UI when HealthKit access is denied.
9. **Audit color contrast** for custom semantic colors.
10. **Limit data retention** to avoid unbounded growth of arrays.

---
*This file is generated from the current codebase and design specification. It should be reviewed and updated as the project evolves.*
