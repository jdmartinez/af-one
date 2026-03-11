# AFOne Roadmap

## Project Overview

**Core Value:** Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

**Platform:** iOS (Apple Watch data via HealthKit)
**Privacy:** On-device only, offline-first
**Disclaimer:** Not a medical device

---

## Phases

- [x] **Phase 1: Foundation & Core Display** - HealthKit integration, dashboard, episode timeline, AF burden visualization
- [ ] **Phase 2: User Input & Analysis** - Symptom logging, medication awareness, trigger tracking, correlation analysis, multi-window burden
- [ ] **Phase 3: Advanced Features** - Long-term trends, clinical reports, emergency info, comprehensive notifications

---

## Phase Details

### Phase 1: Foundation & Core Display

**Goal:** Users can read Apple Health data and see their heart rhythm status, episode history, and AF burden in the app.

**Depends on:** Nothing (first phase)

**Requirements:** FOUN-01, FOUN-02, FOUN-03, FOUN-04, FOUN-05, DASH-01, DASH-02, DASH-03, DASH-04, OVER-01, OVER-02, BURN-01, TIME-01, EPIS-01, EPIS-02, EPIS-03, EMER-01, EMER-02, NOTIF-01

**Success Criteria** (what must be TRUE):
1. User can launch app and immediately see current rhythm context (normal/AF/unknown status)
2. User can view recent AF activity summary showing episodes in last 7 days
3. User can see AF burden as percentage of monitored time
4. User can view timeline showing rhythm status across time (normal/AF/unknown periods)
5. User can browse complete history of detected AF episodes with timestamps and duration
6. User can access emergency information quickly with diagnosis, medications, and recent rhythm activity
7. User receives notification when AF episode is detected
8. App displays clear "Not a medical device" disclaimer on launch
9. All health data remains on-device; user controls any sharing explicitly
10. Core features work without network connectivity

**Plans:** 6 plans

- [x] 01-01-PLAN.md — Foundation: HealthKitService, Models, App Entry, Disclaimer
- [x] 01-02-PLAN.md — Authorization + Emergency View
- [x] 01-03-PLAN.md — Dashboard + Overview
- [x] 01-04-PLAN.md — Timeline + AF Burden
- [x] 01-05-PLAN.md — Episodes List + Detail
- [x] 01-06-PLAN.md — Notifications

---

### Phase 2: User Input & Analysis

**Goal:** Users can log symptoms and lifestyle triggers, view multi-window burden analysis, and understand heart rate behavior during episodes.

**Depends on:** Phase 1

**Requirements:** BURN-02, TIME-02, HR-01, HR-02, HR-03, SYM-01, SYM-02, SYM-03, CORR-01, CORR-02, CORR-03, MED-01, MED-02, TRIG-01, TRIG-02, NOTIF-02, NOTIF-03

**Success Criteria** (what must be TRUE):
1. User can view AF burden across multiple time windows (daily, weekly, monthly)
2. Timeline reveals patterns (nocturnal episodes, clusters, activity-related)
3. User can understand how heart rate behaves during AF episodes (average, peak heart rate)
4. User can identify unusually high heart rate during episodes
5. User can quickly log symptoms when feeling unusual (palpitations, anxiety, dizziness, fatigue, shortness of breath, chest discomfort)
6. Each symptom record is automatically associated with timestamp
7. User can view complete symptom history
8. System analyzes historical data to show symptom-rhythm correlation
9. User can see which symptoms coincide with AF and which occur without arrhythmia
10. User can view medications recorded in Apple Health records
11. User can see relationship between medication timing and rhythm activity
12. User can log lifestyle factors that might precede episodes (alcohol, caffeine, stress, poor sleep, heavy meals, intense exercise)
13. System accumulates trigger data to help identify personal patterns
14. User receives notification for episodes lasting unusually long
15. User receives notification for significant increases in AF burden

**Plans:** TBD

---

### Phase 3: Advanced Features

**Goal:** Users can observe long-term trends, generate clinical reports for their cardiologist, and access comprehensive health insights.

**Depends on:** Phase 2

**Requirements:** TRND-01, TRND-02, TRND-03, REPT-01, REPT-02, REPT-03, REPT-04

**Success Criteria** (what must be TRUE):
1. User can observe long-term trends in AF burden (6-month, 1-year views)
2. User can see episode frequency trends over time
3. User can see rhythm pattern trends
4. User can generate structured clinical summary for cardiologist
5. Report includes AF burden over defined period
6. Report includes episode history and trends
7. Report includes symptom relationships and medication context

**Plans:** TBD

---

## Coverage

| Phase | Requirements | Count |
|-------|--------------|-------|
| 1 - Foundation & Core Display | FOUN-01 through FOUN-05, DASH-01 through DASH-04, OVER-01, OVER-02, BURN-01, TIME-01, EPIS-01 through EPIS-03, EMER-01, EMER-02, NOTIF-01 | 19 |
| 2 - User Input & Analysis | BURN-02, TIME-02, HR-01 through HR-03, SYM-01 through SYM-03, CORR-01 through CORR-03, MED-01, MED-02, TRIG-01, TRIG-02, NOTIF-02, NOTIF-03 | 17 |
| 3 - Advanced Features | TRND-01 through TRND-03, REPT-01 through REPT-04 | 7 |

**Total:** 43/43 requirements mapped ✓

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Core Display | 6/6 | Complete | 2026-03-11 |
| 2. User Input & Analysis | 0/1 | Not started | - |
| 3. Advanced Features | 0/1 | Not started | - |

---

## Notes

- **Coarse granularity applied:** Phases combine related features for faster delivery
- **Offline-first:** Core features verified to work without network
- **Privacy-first:** All health data remains on-device
- **Research flags:** Phase 2 may need deeper research on timeline rendering; Phase 3 may need PDF generation research

---

*Roadmap created: 2026-03-10*
*For planning: `/gsd-plan-phase 1`*
