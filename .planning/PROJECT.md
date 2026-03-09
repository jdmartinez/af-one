# AFOne — Clinical Atrial Fibrillation Monitor

## What This Is

AFOne is a native iPhone application (with watchOS companion) that transforms heart rate data and rhythm history recorded by Apple Watch into clinically actionable information for monitoring paroxysmal atrial fibrillation (PAF). It interprets Apple HealthKit data beyond what Apple's Health app offers — calculating AF burden, ventricular response stratification, circadian patterns, symptom-rhythm correlation, and generating structured physician reports.

**Target users:** Patients with diagnosed paroxysmal atrial fibrillation who regularly wear an Apple Watch and need objective monitoring to share with their cardiologists.

## Core Value

Transform raw Apple Watch heart rate and rhythm data into clinical metrics that enable patients to understand their AF burden, correlate symptoms with actual cardiac rhythm, assess medication effectiveness, and provide precise quantitative data to their cardiologist — the difference between knowing AF episodes occurred and understanding the clinical significance.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] iOS 26+ / watchOS 26+ native app with SwiftUI
- [ ] HealthKit integration (read-only) for HR, rhythm, ECG, HRV, SpO2, sleep, activity, medications
- [ ] AF Burden calculation (24h, 7d, 30d, 90d) with clinical threshold visualization
- [ ] Continuous rhythm map (hour-by-hour 24h reconstruction, calendar 30/90d)
- [ ] Stratified ventricular response by context (nocturnal, light activity, exertion)
- [ ] Quick symptom logging with timestamp and Watch trigger
- [ ] HealthKit medication reading with user classification by function
- [ ] Emergency PDF report (1-page, readable in 30 seconds)
- [ ] Episode detection notifications with configurable thresholds
- [ ] On-device AI features (episode onset detection, symptom classification, risk prediction)
- [ ] Cardiologist consultation report (multi-page PDF with trends, correlations, narrative)

### Out of Scope

- [Any form of diagnosis] — Not a certified medical device, informational only
- [Real-time remote monitoring by third parties] — All processing local, no backend
- [Direct emergency calling with hardcoded numbers] — Uses iOS native emergency routing only
- [Federated learning / model improvement from user data] — Future consideration only

## Context

**Technical Environment:**
- iOS 26+ / watchOS 26+ native with SwiftUI
- Apple Watch Series 4+ (ECG from S4)
- HealthKit for all data sources (read-only except symptom records)
- Core Data / SwiftData for local persistence
- PDFKit for report generation
- Core ML for on-device AI features
- All data remains on-device — no external servers

**Regulatory Context:**
- Not a certified medical device (no CE marking, no FDA clearance)
- Reports are physician communication tools, not clinical diagnoses
- Required disclaimers in onboarding and all reports

## Constraints

- **[Platform]**: iOS 26+, watchOS 26+, Apple Watch S4+ — Apple ecosystem only
- **[Privacy]**: All health data local-only, no external transmission — GDPR special category data handled on-device
- **[AI]**: All ML models on-device, Neural Engine where available, no cloud inference
- **[Regulatory]**: Must include medical disclaimers — not a diagnostic device

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| iOS-only (no Android) | HealthKit is Apple ecosystem | — Pending |
| All processing on-device | Privacy, GDPR, no backend costs | — Pending |
| SwiftUI + Charts | Native, iOS 16+ Charts covers requirements | — Pending |
| Phase 1 = MVP with real clinical value | PRD specifies clear MVP scope | — Pending |
| AI features progressive/hidden on incompatible hardware | No degraded experience, only absence of extras | — Pending |

---
*Last updated: 2026-03-09 after initialization from PRD*
