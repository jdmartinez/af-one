# Requirements: AFOne

**Defined:** 2026-03-10
**Core Value:** Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

## v1 Requirements

### Dashboard & Overview

- [ ] **DASH-01**: User sees current rhythm context immediately on app launch
- [ ] **DASH-02**: User sees recent AF activity summary (episodes in last 7 days)
- [ ] **DASH-03**: User sees key summary metrics (current AF burden, episode count)
- [ ] **DASH-04**: User has quick access to important actions from dashboard
- [ ] **OVER-01**: User can view rhythm monitoring overview showing recent AF frequency
- [ ] **OVER-02**: User can understand whether situation is improving or worsening

### AF Burden & Timeline

- [ ] **BURN-01**: User can view AF burden as percentage of monitored time
- [ ] **BURN-02**: User can view AF burden across multiple time windows (daily, weekly, monthly)
- [ ] **TIME-01**: User can visualize rhythm status across time (normal/AF/unknown)
- [ ] **TIME-02**: Timeline reveals patterns (nocturnal episodes, clusters, activity-related)

### Episodes & Heart Rate

- [ ] **EPIS-01**: User can view history of all detected AF episodes
- [ ] **EPIS-02**: Each episode shows timestamp and duration
- [ ] **EPIS-03**: Each episode shows heart rate behavior during the episode
- [ ] **HR-01**: User can understand how heart rate behaves during AF episodes
- [ ] **HR-02**: User can see average and peak heart rate during AF
- [ ] **HR-03**: User can identify unusually high heart rate during episodes

### Symptom Tracking

- [x] **SYM-01**: User can quickly log symptoms when feeling unusual (palpitations, anxiety, dizziness, fatigue, shortness of breath, chest discomfort)
- [x] **SYM-02**: Each symptom record is associated with timestamp
- [x] **SYM-03**: User can view symptom history
- [ ] **CORR-01**: System analyzes historical data to show symptom-rhythm correlation
- [ ] **CORR-02**: User can see which symptoms coincide with AF
- [ ] **CORR-03**: User can see symptoms occurring without arrhythmia

### Medication & Triggers

- [ ] **MED-01**: User can view medications recorded in Apple Health records
- [ ] **MED-02**: User can see relationship between medication timing and rhythm activity
- [x] **TRIG-01**: User can log lifestyle factors that might precede episodes (alcohol, caffeine, stress, poor sleep, heavy meals, intense exercise)
- [x] **TRIG-02**: System accumulates trigger data to help identify personal patterns

### Trends & Reports

- [ ] **TRND-01**: User can observe long-term trends in AF burden
- [ ] **TRND-02**: User can see episode frequency trends over time
- [ ] **TRND-03**: User can see rhythm pattern trends
- [ ] **REPT-01**: User can generate structured clinical summary for cardiologist
- [ ] **REPT-02**: Report includes AF burden over defined period
- [ ] **REPT-03**: Report includes episode history and trends
- [ ] **REPT-04**: Report includes symptom relationships and medication context

### Emergency & Notifications

- [ ] **EMER-01**: User has quick access to essential emergency information
- [ ] **EMER-02**: Emergency info includes diagnosis, current medications, recent rhythm activity
- [ ] **NOTIF-01**: User receives notification when AF episode is detected
- [ ] **NOTIF-02**: User receives notification for episodes lasting unusually long
- [ ] **NOTIF-03**: User receives notification for significant increases in AF burden

### Foundation

- [ ] **FOUN-01**: App reads heart rhythm data from Apple Watch via Apple Health (HealthKit)
- [ ] **FOUN-02**: App clearly displays "Not a medical device" disclaimer
- [ ] **FOUN-03**: All health data remains on-device under user control
- [ ] **FOUN-04**: User explicitly controls any data sharing
- [ ] **FOUN-05**: Core features work without network connectivity

## v2 Requirements

Deferred to future release.

### Advanced Analysis

- **ADV-01**: HRV (Heart Rate Variability) analysis during AF episodes
- **ADV-02**: Automated trigger pattern detection using logged data
- **ADV-03**: Predictive episode risk estimation (short-term)

### Extended Features

- **EXT-01**: Apple Watch companion app with glanceable data
- **EXT-02**: iOS Widget support for home screen
- **EXT-03**: Color-coded burden zones visualization
- **EXT-04**: Export raw data in standard formats

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Medical diagnosis | Regulatory requirement - AFOne is informational only, not a medical device |
| Treatment recommendations | Liability concerns; requires medical device classification |
| Cloud infrastructure | Violates privacy-first principle; adds unnecessary complexity |
| Real-time cardiac monitoring | Creates anxiety without clinical value for PAF patients |
| Write data to Apple Health | Accuracy concerns; Apple doesn't expect app-written rhythm data |
| Android platform | Apple Watch ecosystem required for data source |
| Direct cardiologist connectivity | HIPAA/compliance complexity; PDF export serves the purpose |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DASH-01 | Phase 1: Foundation & Core Display | Pending |
| DASH-02 | Phase 1: Foundation & Core Display | Pending |
| DASH-03 | Phase 1: Foundation & Core Display | Pending |
| DASH-04 | Phase 1: Foundation & Core Display | Pending |
| OVER-01 | Phase 1: Foundation & Core Display | Pending |
| OVER-02 | Phase 1: Foundation & Core Display | Pending |
| BURN-01 | Phase 1: Foundation & Core Display | Pending |
| BURN-02 | Phase 2: User Input & Analysis | Pending |
| TIME-01 | Phase 1: Foundation & Core Display | Pending |
| TIME-02 | Phase 2: User Input & Analysis | Pending |
| EPIS-01 | Phase 1: Foundation & Core Display | Pending |
| EPIS-02 | Phase 1: Foundation & Core Display | Pending |
| EPIS-03 | Phase 1: Foundation & Core Display | Pending |
| HR-01 | Phase 2: User Input & Analysis | Pending |
| HR-02 | Phase 2: User Input & Analysis | Pending |
| HR-03 | Phase 2: User Input & Analysis | Pending |
| SYM-01 | Phase 2: User Input & Analysis | Complete |
| SYM-02 | Phase 2: User Input & Analysis | Complete |
| SYM-03 | Phase 2: User Input & Analysis | Complete |
| CORR-01 | Phase 2: User Input & Analysis | Pending |
| CORR-02 | Phase 2: User Input & Analysis | Pending |
| CORR-03 | Phase 2: User Input & Analysis | Pending |
| MED-01 | Phase 2: User Input & Analysis | Pending |
| MED-02 | Phase 2: User Input & Analysis | Pending |
| TRIG-01 | Phase 2: User Input & Analysis | Complete |
| TRIG-02 | Phase 2: User Input & Analysis | Complete |
| TRND-01 | Phase 3: Advanced Features | Pending |
| TRND-02 | Phase 3: Advanced Features | Pending |
| TRND-03 | Phase 3: Advanced Features | Pending |
| REPT-01 | Phase 3: Advanced Features | Pending |
| REPT-02 | Phase 3: Advanced Features | Pending |
| REPT-03 | Phase 3: Advanced Features | Pending |
| REPT-04 | Phase 3: Advanced Features | Pending |
| EMER-01 | Phase 1: Foundation & Core Display | Pending |
| EMER-02 | Phase 1: Foundation & Core Display | Pending |
| NOTIF-01 | Phase 1: Foundation & Core Display | Pending |
| NOTIF-02 | Phase 2: User Input & Analysis | Pending |
| NOTIF-03 | Phase 2: User Input & Analysis | Pending |
| FOUN-01 | Phase 1: Foundation & Core Display | Pending |
| FOUN-02 | Phase 1: Foundation & Core Display | Pending |
| FOUN-03 | Phase 1: Foundation & Core Display | Pending |
| FOUN-04 | Phase 1: Foundation & Core Display | Pending |
| FOUN-05 | Phase 1: Foundation & Core Display | Pending |

**Coverage:**
- v1 requirements: 43 total
- Mapped to phases: 43
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-10*
*Last updated: 2026-03-10 after initial definition*
