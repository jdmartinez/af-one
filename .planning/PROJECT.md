# AFOne

## What This Is

AFOne is an iOS application that helps patients with **paroxysmal atrial fibrillation (PAF)** understand and monitor their heart rhythm using data collected by Apple Watch and stored in Apple Health. The application transforms raw physiological measurements into **clear clinical insights** that help patients understand their condition and communicate effectively with their cardiologist. The product focuses on **interpretation and understanding**, not raw data collection. AFOne is **not a medical device** and does not diagnose or treat disease.

## Core Value

Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

## Current State: v0.3 (In Progress)

**In progress:** UI Improvements milestone
- Phase 9: Home Screen UI (ready for planning)
- Phase 10: AF Burden Detail View (pending)
- Phase 11: Symptom Correlation View (pending)
- Phase 12: Rhythm Map View (pending)
- Phase 13: Emergency Report View (pending)
- Phase 14: Data Honesty Rules (pending)

---

## Current Milestone: v0.3 UI Improvements

**Goal:** Improve UI views for v1.0 MVP features - enhanced data visualization, better navigation patterns, improved accessibility

**Target features:**
- Multi-window AF burden analysis UI (daily, weekly, monthly)
- Advanced timeline pattern detection UI (nocturnal, clusters)
- Symptom-rhythm correlation analysis UI
- Clinical report generation UI
- Enhanced notifications UI
- Long-term trends UI (6-month, 1-year)

## Requirements

### Validated (v0.1 Alpha + v0.2)

- ✓ Dashboard with current rhythm context and summary metrics
- ✓ Rhythm monitoring overview with AF frequency
- ✓ AF burden calculation (basic)
- ✓ Timeline visualization (normal/AF/unknown periods)
- ✓ Episode history with timestamps, duration
- ✓ Heart rate behavior during episodes
- ✓ Symptom logging with timestamps
- ✓ Lifestyle trigger tracking
- ✓ Emergency information quick access
- ✓ HealthKit integration
- ✓ Notifications for AF episodes
- ✓ Dark/light theme support
- ✓ Dashboard cards with Apple Health-style UI
- ✓ Liquid Glass tab bar with collapse
- ✓ Color palette with Color Set references
- ✓ Semantic color system throughout

### Active (v0.3 UI Improvements)

- [ ] Multi-window AF burden analysis UI (daily, weekly, monthly)
- [ ] Advanced timeline pattern detection UI (nocturnal, clusters)
- [ ] Symptom-rhythm correlation analysis UI
- [ ] Clinical report generation UI
- [ ] Enhanced notifications UI
- [ ] Long-term trends UI (6-month, 1-year views)

### Out of Scope

- Medical diagnosis — AFOne is informational only, not a medical device
- Treatment recommendations or medication guidance
- Cloud infrastructure or backend services
- Real-time cardiac monitoring or emergency detection
- Writing data back to Apple Health
- Android or other non-iOS platforms

## Context

- **Platform**: iOS 17+ (modern devices), Apple Watch as primary data source
- **Data Source**: Apple Health records containing heart rhythm data from Apple Watch
- **Offline-first**: Core capabilities work without network connectivity
- **Privacy-first**: All health data remains on-device under user control
- **Tech Stack**: SwiftUI, Swift Charts, SwiftData, MVVM + Clean Architecture
- **Shipped LOC**: ~10,000+ Swift

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| iOS-only | Apple Watch ecosystem integration required | ✓ Validated |
| Offline-first core | Reliable access to health data, privacy by design | ✓ Validated |
| No backend | Reduces complexity, ensures data privacy | ✓ Validated |
| Not a medical device | Regulatory clearance would delay launch | ✓ Validated |
| SwiftData @Model | Apple's recommended persistence for iOS 17+ | ✓ Validated |
| BarMark for day, LineMark for week/month | Optimal visualization for each time granularity | ✓ Validated |
| Semantic colors + Color Set assets | Per SPECIFICATION.md Section 2 - iOS HIG compliance and accessibility | ✓ Validated |
| Zone-based dashboard layout | Hero Card transforms between SR and AF Active states per SPEC.md Section 4 | ✓ Validated |
| Theme.swift Color Set references | Replace hardcoded RGB with Color Set assets in Assets.xcassets per SPEC.md | ✓ Validated |
| AI token color palette | Violet base with confidence indicators for future AI features | ✓ Validated |

---

*Last updated: 2026-03-16 after v0.2 UI Enhancements milestone*

---

*Last updated: 2026-03-16 — Milestone v0.3 UI Improvements started*
