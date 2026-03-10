# AFOne

## What This Is

AFOne is an iOS application that helps patients with **paroxysmal atrial fibrillation (PAF)** understand and monitor their heart rhythm using data collected by Apple Watch and stored in Apple Health. The application transforms raw physiological measurements into **clear clinical insights** that help patients understand their condition and communicate effectively with their cardiologist. The product focuses on **interpretation and understanding**, not raw data collection. AFOne is **not a medical device** and does not diagnose or treat disease.

## Core Value

Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Dashboard with current rhythm context, recent AF activity, key summary metrics, quick actions
- [ ] Rhythm monitoring overview showing recent AF frequency and trends
- [ ] AF burden calculation across multiple time windows (daily, weekly, monthly)
- [ ] Rhythm timeline visualization showing normal/AF/unknown periods
- [ ] Episode history with timestamps, duration, heart rate behavior
- [ ] Heart rate behavior analysis during AF episodes
- [ ] Symptom logging with timestamp association
- [ ] Symptom-rhythm correlation analysis
- [ ] Medication awareness from health records
- [ ] Lifestyle trigger tracking and pattern identification
- [ ] Long-term trends visualization
- [ ] Clinical reports for cardiologist sharing
- [ ] Emergency information quick access
- [ ] Notifications for AF episodes and significant changes

### Out of Scope

- Medical diagnosis — AFOne is informational only, not a medical device
- Treatment recommendations or medication guidance
- Cloud infrastructure or backend services
- Real-time cardiac monitoring or emergency detection
- Writing data back to Apple Health (except user-entered notes)
- Android or other non-iOS platforms

## Context

- **Platform**: iOS (modern devices), Apple Watch as primary data source
- **Data Source**: Apple Health records containing heart rhythm data from Apple Watch
- **Offline-first**: Core capabilities work without network connectivity
- **Privacy-first**: All health data remains on-device under user control

## Constraints

- **Platform**: iOS only — modern iOS devices with Apple Watch integration
- **Data Dependency**: Relies on Apple Watch rhythm detection and Apple Health storage
- **Regulatory**: Not a medical device — clear disclaimer required throughout
- **Privacy**: Health data must remain on-device; no automatic sharing
- **Offline**: Core features must work without network connectivity

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| iOS-only | Apple Watch ecosystem integration required | — Pending |
| Offline-first core | Reliable access to health data, privacy by design | — Pending |
| No backend | Reduces complexity, ensures data privacy | — Pending |
| Not a medical device | Regulatory clearance would delay launch; informational focus | — Pending |

---
*Last updated: 2026-03-10 after initialization*
