# Roadmap: v0.3 UI Improvements

**Milestone:** v0.3  
**Goal:** Improve UI views for v1.0 MVP features - enhanced data visualization, better navigation patterns, improved accessibility  
**Phase Range:** 9-14

---

## Phases

- [x] **Phase 9: Home Screen UI** - Navigation bar, Hero card states, section headers
- [ ] **Phase 10: AF Burden Detail View** - Segmented picker, threshold colors, burden charts
- [ ] **Phase 11: Symptom Correlation View** - Timeline, event list, pattern detection
- [ ] **Phase 12: Rhythm Map View** - Dual-layer chart, coverage bar, circadian patterns
- [ ] **Phase 13: Emergency Report View** - Header, patient block, clinical sections
- [ ] **Phase 14: Data Honesty Rules** - Estimated suffixes, disclosure notes across views

---

## Phase Details

### Phase 9: Home Screen UI

**Goal:** Update Home screen navigation, Hero card states, and section header layout

**Depends on:** Phase 8 (v0.2 completion)

**Requirements:** HOME-01, HOME-02, HOME-03, HOME-04, HOME-05, HOME-06

**Success Criteria** (what must be TRUE):

1. Navigation bar displays "Resumen" as large title that collapses to inline on scroll
2. Emergency access button (exclamationmark.triangle.fill) visible in navigation bar trailing position, opens EmergencyReportView directly
3. Section headers positioned outside and above cards with HStack layout - title left (uppercase, secondary) and navigation link right (blue)
4. Hero card displays State A (Sinus Rhythm) with green dot and HeroGradient.sr when no recent episode
5. Hero card displays State B (recent episode) with amber contextual banner showing "EPISODIO RECIENTE", elapsed time, and "Ver informe" button
6. Hero card displays State C (AF Active) with red gradient, red dot, red border, and "Informe" button

**Plans:** 1 plan (09-01-PLAN.md)

---

### Phase 10: AF Burden Detail View

**Goal:** Build comprehensive AF Burden detail view with segmented time windows, clinical thresholds, and charts

**Depends on:** Phase 9

**Requirements:** BURD-01, BURD-02, BURD-03, BURD-04, BURD-05, BURD-06, BURD-07, BURD-08, BURD-09, BURD-10

**Success Criteria** (what must be TRUE):

1. Segmented picker (24h / 7 días / 30 días) controls all data in the view
2. Primary burden percentage displayed with clinical threshold coloring (Low <5.5% green, Mid 5.5-10.9% amber, High ≥11% red)
3. Threshold badge shows clinical reference (ASSERT <5.5%, ASSERT ≥5.5%, TRENDS ≥11%)
4. Progress bar displays with gradient fill and tick marks at 5.5% and 11% thresholds
5. Delta row shows change vs previous period with color coding (green down, red up)
6. Three-column window comparison displays burden for all time windows side by side
7. 14-day trend bar chart renders with threshold coloring and insufficient-data handling (40% opacity)
8. Recent episodes list shows duration, HR, SpO2, ECG chips with insufficient-data warnings
9. Clinical context section displays threshold explanations and anticoagulation note
10. Data honesty notes display "Valor estimado" and "calculado a partir de eventos irregularHeartRhythmEvent"

**Plans:** TBD

---

### Phase 11: Symptom Correlation View

**Goal:** Build symptom-rhythm correlation analysis view with timeline, event list, and pattern detection

**Depends on:** Phase 9

**Requirements:** SYMP-01, SYMP-02, SYMP-03, SYMP-04, SYMP-05, SYMP-06, SYMP-07

**Success Criteria** (what must be TRUE):

1. Three-column summary grid displays "Síntomas con FA" (green), "Síntomas sin FA" (amber), "FA silente" (red) counts
2. Daily timeline uses segmented picker (Hoy / 7 días / 30 días)
3. Dual-track timeline shows rhythm bar track and symptom pin markers with correlation highlighting
4. Event list displays badges ("FA confirmada", "Sin correlación", "FA silente"), timestamps, and rhythm pills
5. Event detail sheet shows symptom captured, rhythm in ±30min window, and clinical note
6. Detected patterns section shows nocturnal symptoms without AF, symptoms preceding AF, and asymptomatic AF count
7. Methodological note explains ±30min correlation window and Apple Watch limitations

**Plans:** TBD

---

### Phase 12: Rhythm Map View

**Goal:** Build rhythm visualization view with dual-layer chart, data coverage, and circadian patterns

**Depends on:** Phase 9

**Requirements:** RHYM-01, RHYM-02, RHYM-03, RHYM-04, RHYM-05, RHYM-06, RHYM-07, RHYM-08

**Success Criteria** (what must be TRUE):

1. Scenario buttons allow switching between days (today, yesterday, high-burden day)
2. Segmented picker (Día / Semana / Mes) controls view granularity
3. Dual-layer chart renders bar layer (rhythm by hour) and line layer (HR trend)
4. Bars with <3 samples render at 35% opacity with warning tooltip
5. Stats row shows SR%, AF%, No data%, Episode count
6. Episode list displays duration, mean HR, SpO2, ECG chip, insufficient-data warnings
7. Data coverage bar shows percentage of hours with data (color coded)
8. Circadian pattern histogram shows AF onset frequency by 3-hour blocks

**Plans:** TBD

---

### Phase 13: Emergency Report View

**Goal:** Build comprehensive emergency report view with patient data, episode details, and clinical sections

**Depends on:** Phase 9

**Requirements:** EMER-01, EMER-02, EMER-03, EMER-04, EMER-05, EMER-06, EMER-07, EMER-08, EMER-09, EMER-10

**Success Criteria** (what must be TRUE):

1. Full-bleed red header displays urgency badge, app name, timestamp
2. Patient block shows name, age, sex, known diagnosis
3. Episode strip displays elapsed time since onset, current HR, SpO2 with timestamps
4. Current episode details section shows onset time, duration, mean HR, SpO2, symptoms, ECG result
5. AF history section shows 30-day burden timeline, episode count, mean duration, burden %, AF type
6. Active medication section displays medication rows with class badges (Anticoagulante, β-bloqueante, Antiarrítmico)
7. Relevant history timeline shows diagnosis, cardioversions, allergies, referring cardiologist
8. Limitations banner explains Apple Watch detection limitations
9. Source footer displays version, timestamp, legal disclaimer
10. tel://112 link present inside report (not as primary home screen action)

**Plans:** TBD

---

### Phase 14: Data Honesty Rules

**Goal:** Apply data honesty principles consistently across all views

**Depends on:** Phase 10, Phase 11, Phase 12, Phase 13

**Requirements:** DATA-01, DATA-02, DATA-03, DATA-04, DATA-05

**Success Criteria** (what must be TRUE):

1. All estimated values display "est." suffix in every view where estimation occurs
2. SpO2 displays "Sin dato" when no coincident reading, never shows out-of-window value
3. Episode timer displays mandatory disclosure "Desde último dato de Apple Watch"
4. User-declared data (medication, history) displays "Declarada por el paciente" note
5. Rhythm map bars with <3 samples render at 35-40% opacity with tooltip warning

**Plans:** TBD

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 9. Home Screen UI | 1/1 | ✓ | - |
| 10. AF Burden Detail View | 0/1 | Not started | - |
| 11. Symptom Correlation View | 0/1 | Not started | - |
| 12. Rhythm Map View | 0/1 | Not started | - |
| 13. Emergency Report View | 0/1 | Not started | - |
| 14. Data Honesty Rules | 0/1 | Not started | - |

---

## Coverage

- v0.3 requirements: 45 total
- Mapped to phases: 45
- Unmapped: 0

---

*Roadmap created: 2026-03-16*
