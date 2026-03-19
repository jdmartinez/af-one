# Requirements: AFOne

**Defined:** 2026-03-16
**Core Value:** Transform Apple Watch heart rhythm data into clear, clinically meaningful insights that help PAF patients understand their condition, recognize patterns, and communicate effectively with their cardiologist.

## v0.3 Requirements

### Home Screen (Resumen)

- [x] **HOME-01**: Navigation bar displays "Resumen" as large title that collapses to inline on scroll, with trailing emergency access button (exclamationmark.triangle.fill) that opens EmergencyReportView
- [x] **HOME-02**: Section headers (AF Burden, Rhythm Map, Clinical Metrics) positioned outside and above cards with HStack layout - title left (uppercase, secondary), navigation link right (blue)
- [x] **HOME-03**: Hero card displays State A (Sinus Rhythm - no recent episode) with green dot and HeroGradient.sr
- [x] **HOME-04**: Hero card displays State B (Sinus Rhythm with recent episode) - amber contextual banner below rhythm row showing "EPISODIO RECIENTE" with elapsed time and "Ver informe" button
- [x] **HOME-05**: Hero card displays State C (AF Active) with red gradient, red dot, red border, and "Informe" button (not tel://112)
- [x] **HOME-06**: Toolbar emergency button visible regardless of rhythm state, opens EmergencyReportView directly

### AF Burden Detail View

- [ ] **BURD-01**: Segmented picker (24h / 7 días / 30 días) controls all data in view
- [ ] **BURD-02**: Primary burden percentage displayed with clinical threshold coloring (Low <5.5%, Mid 5.5-10.9%, High ≥11%)
- [ ] **BURD-03**: Threshold badge shows clinical reference (ASSERT <5.5%, ASSERT ≥5.5%, TRENDS ≥11%)
- [ ] **BURD-04**: Progress bar with gradient fill and tick marks at 5.5% and 11%
- [ ] **BURD-05**: Delta row shows change vs previous period with color coding
- [ ] **BURD-06**: Three-column window comparison showing burden for all time windows
- [ ] **BURD-07**: 14-day trend bar chart with threshold coloring and insufficient-data handling (40% opacity)
- [ ] **BURD-08**: Recent episodes list with duration, HR, SpO2, ECG chips and insufficient-data warnings
- [ ] **BURD-09**: Clinical context section with threshold explanations and anticoagulation note
- [ ] **BURD-10**: Data honesty notes displayed ("Valor estimado", "calculado a partir de eventos irregularHeartRhythmEvent")

### Symptom Correlation View

- [x] **SYMP-01**: Three-column summary grid showing "Síntomas con FA" (green), "Síntomas sin FA" (amber), "FA silente" (red)
- [x] **SYMP-02**: Daily timeline with segmented picker (Hoy / 7 días / 30 días)
- [x] **SYMP-03**: Dual-track timeline showing rhythm bar track and symptom pin markers with correlation highlighting
- [x] **SYMP-04**: Event list with badges ("FA confirmada", "Sin correlación", "FA silente"), timestamps, and rhythm pills
- [x] **SYMP-05**: Event detail sheet showing symptom captured, rhythm in ±30min window, and clinical note
- [x] **SYMP-06**: Detected patterns section (nocturnal symptoms without AF, symptoms preceding AF, asymptomatic AF count)
- [x] **SYMP-07**: Methodological note explaining ±30min correlation window and Apple Watch limitations

### Rhythm Map View

- [x] **RHYM-01**: Scenario buttons for switching between days (today, yesterday, high-burden day)
- [x] **RHYM-02**: Segmented picker (Día / Semana / Mes)
- [x] **RHYM-03**: Dual-layer chart with bar layer (rhythm by hour) and line layer (HR trend)
- [x] **RHYM-04**: Bars with <3 samples rendered at 35% opacity with warning tooltip
- [x] **RHYM-05**: Stats row showing SR%, AF%, No data%, Episode count
- [x] **RHYM-06**: Episode list with duration, mean HR, SpO2, ECG chip, insufficient-data warnings
- [x] **RHYM-07**: Data coverage bar showing percentage of hours with data (color coded)
- [x] **RHYM-08**: Circadian pattern histogram showing AF onset frequency by 3-hour blocks

### Emergency Report View

- [ ] **EMER-01**: Full-bleed red header with urgency badge, app name, timestamp
- [ ] **EMER-02**: Patient block showing name, age, sex, known diagnosis
- [ ] **EMER-03**: Episode strip showing elapsed time since onset, current HR, SpO2 with timestamps
- [ ] **EMER-04**: Current episode details section with onset time, duration, mean HR, SpO2, symptoms, ECG result
- [ ] **EMER-05**: AF history section with 30-day burden timeline, episode count, mean duration, burden %, AF type
- [ ] **EMER-06**: Active medication section with medication rows and class badges (Anticoagulante, β-bloqueante, Antiarrítmico)
- [ ] **EMER-07**: Relevant history timeline with diagnosis, cardioversions, allergies, referring cardiologist
- [ ] **EMER-08**: Limitations banner explaining Apple Watch detection limitations
- [ ] **EMER-09**: Source footer with version, timestamp, legal disclaimer
- [ ] **EMER-10**: tel://112 link present inside report (not as primary home screen action)

### Data Honesty Rules

- [x] **DATA-01**: All estimated values display "est." suffix in every view
- [x] **DATA-02**: SpO2 shows "Sin dato" when no coincident reading, never out-of-window value
- [x] **DATA-03**: Episode timer displays mandatory disclosure "Desde último dato de Apple Watch"
- [x] **DATA-04**: User-declared data (medication, history) displays "Declarada por el paciente" note
- [x] **DATA-05**: Rhythm map bars with <3 samples render at 35-40% opacity with tooltip warning

## v0.4+ Requirements

Deferred to future release. Tracked but not in current roadmap.

### Trends

- **TRND-01**: 6-month trend charts
- **TRND-02**: 1-year trend charts

### Notifications

- **NOTF-01**: Enhanced notifications for long episodes
- **NOTF-02**: Notifications for burden threshold changes

### Additional Views

- **VIEW-01**: Clinical Metrics detail (HRV, SpO2, Ventricular Response, Duration)
- **VIEW-02**: AI Insights panel
- **VIEW-03**: Medication view
- **VIEW-04**: Settings view

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Enhanced notifications | Deferred to v0.4 - requires notification infrastructure |
| Long-term trends (6-month, 1-year) | Deferred to v0.4 - requires data aggregation layer |
| AI Insights panel | Requires ML model integration, defer to future |
| Medication management view | User-declared only in v0.3 Emergency Report |
| Settings view | Not in v0.3 scope |
| Real-time ECG streaming | Apple Watch limitation, not achievable |
| Cloud sync | Offline-first design principle |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| HOME-01 | Phase 9 | Complete |
| HOME-02 | Phase 9 | Complete |
| HOME-03 | Phase 9 | Complete |
| HOME-04 | Phase 9 | Complete |
| HOME-05 | Phase 9 | Complete |
| HOME-06 | Phase 9 | Complete |
| BURD-01 | Phase 10 | Pending |
| BURD-02 | Phase 10 | Pending |
| BURD-03 | Phase 10 | Pending |
| BURD-04 | Phase 10 | Pending |
| BURD-05 | Phase 10 | Pending |
| BURD-06 | Phase 10 | Pending |
| BURD-07 | Phase 10 | Pending |
| BURD-08 | Phase 10 | Pending |
| BURD-09 | Phase 10 | Pending |
| BURD-10 | Phase 10 | Pending |
| SYMP-01 | Phase 11 | Pending |
| SYMP-02 | Phase 11 | Pending |
| SYMP-03 | Phase 11 | Pending |
| SYMP-04 | Phase 11 | Pending |
| SYMP-05 | Phase 11 | Pending |
| SYMP-06 | Phase 11 | Pending |
| SYMP-07 | Phase 11 | Pending |
| RHYM-01 | Phase 12 | Complete |
| RHYM-02 | Phase 12 | Complete |
| RHYM-03 | Phase 12 | Complete |
| RHYM-04 | Phase 12 | Complete |
| RHYM-05 | Phase 12 | Complete |
| RHYM-06 | Phase 12 | Complete |
| RHYM-07 | Phase 12 | Complete |
| RHYM-08 | Phase 12 | Complete |
| EMER-01 | Phase 13 | Pending |
| EMER-02 | Phase 13 | Pending |
| EMER-03 | Phase 13 | Pending |
| EMER-04 | Phase 13 | Pending |
| EMER-05 | Phase 13 | Pending |
| EMER-06 | Phase 13 | Pending |
| EMER-07 | Phase 13 | Pending |
| EMER-08 | Phase 13 | Pending |
| EMER-09 | Phase 13 | Pending |
| EMER-10 | Phase 13 | Pending |
| DATA-01 | Phase 14 | Complete |
| DATA-02 | Phase 14 | Complete |
| DATA-03 | Phase 14 | Complete |
| DATA-04 | Phase 14 | Complete |
| DATA-05 | Phase 14 | Complete |

**Coverage:**
- v0.3 requirements: 45 total
- Mapped to phases: 45 ✓
- Unmapped: 0 ✓

---

*Requirements defined: 2026-03-16*
*Last updated: 2026-03-16 after v0.3 milestone initialization*
