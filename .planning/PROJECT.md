# AFOne

## What This Is

AFOne is an iOS application that helps patients with **paroxysmal atrial fibrillation (PAF)** understand and monitor their heart rhythm using data collected by Apple Watch and stored in Apple Health. The application transforms raw physiological measurements into **clear clinical insights** that help patients understand their condition and communicate effectively with their cardiologist. The product focuses on **interpretation and understanding**, not raw data collection. AFOne is **not a medical device** and does not diagnose or treat disease.

## Core Value

Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

## Current State: v0.3 (Complete)

**Completed milestones:**
- v0.1 Alpha — Core health data integration and basic dashboard
- v0.2 UI Enhancements — Theme, dashboard redesign, color palette
- v0.3 UI Improvements — Multi-window analysis, clinical views, data honesty

**In progress:** Planning v0.4

---

## Milestone History

| Version | Name | Phases | Date |
|---------|------|--------|------|
| v0.1 | Alpha | 1-4 | 2026-03-13 |
| v0.2 | UI Enhancements | 5-8 | 2026-03-16 |
| v0.3 | UI Improvements | 9-14 | 2026-03-19 |

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

### Validated (v0.2 UI Enhancements)

- ✓ Dark/light theme support with semantic colors
- ✓ Dashboard cards with Apple Health-style UI (ultraThinMaterial, 16pt corners)
- ✓ Liquid Glass tab bar with scroll collapse
- ✓ Color palette with Color Set references throughout
- ✓ Clinical metrics grid and symptom capture button
- ✓ Zone-based dashboard layout (Hero, AF Burden, Metrics, Symptom)
- ✓ Hero gradient color system (SR green, AF red)
- ✓ Text opacity ViewModifiers and localized UI

### Validated (v0.3 UI Improvements)

- ✓ Multi-window AF burden analysis UI (24h/7d/30d) with clinical thresholds (ASSERT, TRENDS)
- ✓ Advanced timeline pattern detection (nocturnal, cluster, symptomatic vs silent AF)
- ✓ Symptom-rhythm correlation analysis with ±30min window detection
- ✓ Comprehensive emergency report with 10 clinical sections and tel://112 link
- ✓ Rhythm map with dual-layer chart (rhythm bars + HR trend line) and circadian patterns
- ✓ Data coverage tracking with insufficient-data opacity rules (35% for <3 samples)
- ✓ Data honesty framework: "(est.)" suffixes, "Sin dato" for nil SpO2, "Desde último dato de Apple Watch" disclosures, "Declarada por el paciente" badges
- ✓ Hero card with 3 states: Sinus Rhythm, Recent Episode (amber banner), AF Active

### Active (v0.4)

- [ ] Enhanced notifications for AF burden changes
- [ ] Long-term trends UI (6-month, 1-year views)
- [ ] AI Insights panel
- [ ] Medication management view

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
- **Shipped LOC**: ~10,900 Swift

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| iOS-only | Apple Watch ecosystem integration required | ✓ Validated |
| Offline-first core | Reliable access to health data, privacy by design | ✓ Validated |
| No backend | Reduces complexity, ensures data privacy | ✓ Validated |
| Not a medical device | Regulatory clearance would delay launch | ✓ Validated |
| SwiftData @Model | Apple's recommended persistence for iOS 17+ | ✓ Validated |
| BarMark for day, LineMark for week/month | Optimal visualization for each time granularity | ✓ Validated |
| Semantic colors + Color Set assets | Per SPECIFICATION.md Section 2 - iOS HIG compliance | ✓ Validated |
| Zone-based dashboard layout | Hero Card transforms between SR and AF Active states | ✓ Validated |
| Theme.swift Color Set references | Replace hardcoded RGB with Color Set assets | ✓ Validated |
| AI token color palette | Violet base with confidence indicators for future AI features | ✓ Validated |
| Dual-layer Chart (BarMark + LineMark) | Rhythm bars + HR trend line on same axes | ✓ v0.3 Phase 12 |
| Circadian block aggregation (8×3h) | AF onset frequency by 3-hour blocks | ✓ v0.3 Phase 12 |
| 35% opacity for insufficient data (<3 samples) | DATA-05 data honesty rule | ✓ v0.3 Phase 12 |
| "est." suffix for estimated values | Data transparency per DATA-01 | ✓ v0.3 Phase 14 |
| DataHonestyHelper component | Centralized honesty formatting utilities | ✓ v0.3 Phase 14 |
| ±30min correlation window | Symptom-AF temporal correlation detection | ✓ v0.3 Phase 11 |

---

*Last updated: 2026-03-19 after v0.3 UI Improvements milestone*
