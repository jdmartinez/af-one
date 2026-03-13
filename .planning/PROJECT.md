# AFOne

## What This Is

AFOne is an iOS application that helps patients with **paroxysmal atrial fibrillation (PAF)** understand and monitor their heart rhythm using data collected by Apple Watch and stored in Apple Health. The application transforms raw physiological measurements into **clear clinical insights** that help patients understand their condition and communicate effectively with their cardiologist. The product focuses on **interpretation and understanding**, not raw data collection. AFOne is **not a medical device** and does not diagnose or treat disease.

## Core Value

Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

## Current State

**Shipped:** v0.1 Alpha (2026-03-13)
- 4 phases, 20 plans, 73 files, +7,780 LOC Swift
- Core display, user input, analysis, and UI enhancements complete
- See .planning/milestones/v0.1-ROADMAP.md for details

## Requirements

### Validated (v0.1 Alpha)

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

### Active (v1.0 MVP)

- [ ] Multi-window AF burden analysis (daily, weekly, monthly)
- [ ] Advanced timeline pattern detection (nocturnal, clusters)
- [ ] Symptom-rhythm correlation analysis
- [ ] Medication awareness from health records
- [ ] Long-term trends (6-month, 1-year views)
- [ ] Clinical report generation for cardiologist
- [ ] Enhanced notifications (long episodes, burden changes)

### Out of Scope

- Medical diagnosis — AFOne is informational only, not a medical device
- Treatment recommendations or medication guidance
- Cloud infrastructure or backend services
- Real-time cardiac monitoring or emergency detection
- Writing data back to Apple Health
- Android or other non-iOS platforms

## Context

- **Platform**: iOS (modern devices), Apple Watch as primary data source
- **Data Source**: Apple Health records containing heart rhythm data from Apple Watch
- **Offline-first**: Core capabilities work without network connectivity
- **Privacy-first**: All health data remains on-device under user control

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| iOS-only | Apple Watch ecosystem integration required | ✓ Validated |
| Offline-first core | Reliable access to health data, privacy by design | ✓ Validated |
| No backend | Reduces complexity, ensures data privacy | ✓ Validated |
| Not a medical device | Regulatory clearance would delay launch | ✓ Validated |
| SwiftData @Model | Apple's recommended persistence for iOS 17+ | ✓ Validated |
| BarMark for day, LineMark for week/month | Optimal visualization for each time granularity | ✓ Validated |

---

*Last updated: 2026-03-13 after v0.1 Alpha milestone*
