# AFOne Roadmap

## Milestones

- ✅ **v0.1 Alpha** — Phases 1-4 (shipped 2026-03-13)
- 🚧 **v0.2 UI Enhancements** — Phase 5 complete, Phase 6 (in progress)
- 📋 **v1.0 MVP** — Phases 7+ (planned)

---

## Phases

### ✅ v0.1 Alpha (Phases 1-4) — SHIPPED 2026-03-13

- [x] Phase 1: Foundation & Core Display (6/6 plans) — completed 2026-03-11
- [x] Phase 2: User Input & Analysis (6/6 plans) — completed 2026-03-13
- [x] Phase 3: Advanced Features (4/4 plans) — completed 2026-03-13
- [x] Phase 4: UI Enhancements (4/4 plans) — completed 2026-03-13

*See .planning/milestones/v0.1-ROADMAP.md for full details*

---

### 🚧 v0.2 UI Enhancements (Phases 5-6) — IN PROGRESS

**Goal:** Improve UI/UX with iOS-native appearance, localization, and polish

**Requirements:** UI-01, UI-02, UI-03, UI-04, UI-05

#### Phase 5: Theme & Dashboard Redesign

**Goal:** Implement dark/light theme support and redesign dashboard

**Requirements:** UI-01, UI-02

**Success Criteria:**
1. App displays correctly in both light and dark mode
2. All hardcoded colors replaced with semantic colors
3. Dashboard cards redesigned with Health app-like UI
4. No duplicate back buttons in navigation
5. All views tested in both color schemes

**Plans:**
- [x] 05-01: Theme fixes (cardShadow)
- [x] 05-02: Dashboard redesign (Apple Health style)
- [x] 05-03: Navigation fixes (duplicate back buttons)

#### Phase 6: Polish & Localization

**Goal:** Add Liquid Glass effects and localization support

**Requirements:** UI-03, UI-04, UI-05

**Success Criteria:**
1. Navigation fixes complete (no duplicate back buttons)
2. Liquid Glass effect applied to tab bar
3. Tab bar collapses on scroll
4. App displays in device language
5. String catalog contains all user-facing strings

---

### 📋 v1.0 MVP (Future)

- Phase 7: Multi-window AF burden analysis
- Phase 8: Advanced timeline pattern detection
- Phase 9: Symptom-rhythm correlation
- Phase 10: Clinical report generation
- Phase 11: Enhanced notifications
- Phase 12: Long-term trends

---

## Progress

| Phase | Milestone | Plans | Status | Completed |
|-------|-----------|-------|--------|-----------|
| 1. Foundation & Core Display | v0.1 | 6/6 | Complete | 2026-03-11 |
| 2. User Input & Analysis | v0.1 | 6/6 | Complete | 2026-03-13 |
| 3. Advanced Features | v0.1 | 4/4 | Complete | 2026-03-13 |
| 4. UI Enhancements | v0.1 | 4/4 | Complete | 2026-03-13 |
| 5. Theme & Dashboard | v0.2 | 3/3 | Complete | 2026-03-14 |
| 6. Polish & Localization | v0.2 | TBD | Not started | - |
| 7. Dashboard Redesign | v1.0 | 7 | Ready | - |

### Phase 7: Dashboard Redesign Specification

**Goal:** Implement dashboard UI redesign with clinical state signaling per SPECIFICATION.md
**Requirements:** UI-01, UI-02
**Depends on:** Phase 6
**Plans:** 7 plans (02-07)

**Status:** Ready for execution.

**Plan breakdown:**
- [ ] 07-02: Color Assets & Theme System
- [ ] 07-03: Hero Card (Zone 1)
- [ ] 07-04: AF Burden Card (Zone 2)
- [ ] 07-05: 24h Rhythm Map (Zone 3)
- [ ] 07-06: Clinical Metrics Grid (Zone 4)
- [ ] 07-07: Symptom Capture Button (Zone 5)

---

*Phase 7 added with dashboard redesign specification*

*Last updated: 2026-03-14*
*For planning: `/gsd-plan-phase 6`*
