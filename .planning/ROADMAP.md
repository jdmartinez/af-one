# AFOne Roadmap

## Milestones

- ✅ **v0.1 Alpha** — Phases 1-4 (shipped 2026-03-13)
- ✅ **v0.2 UI Enhancements** — Phase 6 complete
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
6/5 plans complete
- [x] 05-02: Dashboard redesign (Apple Health style)
- [x] 05-03: Navigation fixes (duplicate back buttons)
- [ ] 05-04: Fix back buttons (gap closure)
- [ ] 05-05: Dynamic theme switching (gap closure)

### ✅ Phase 6: Polish & Localization

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
| 5. Theme & Dashboard | v0.2 | 6/5 | Complete | 2026-03-14 |
| 6. Polish & Localization | v0.2 | 2/2 | Complete | 2026-03-14 |
| 7. Dashboard Redesign | v1.0 | Complete    | 2026-03-14 | 7/7 |

**Plans:**
- [x] 06-01: Liquid Glass tab bar with collapse
- [x] 06-02: Localization foundation and string catalog

### Phase 7: Dashboard Redesign Specification

**Goal:** Implement dashboard UI redesign with clinical state signaling per SPECIFICATION.md
**Requirements:** UI-01, UI-02
**Depends on:** Phase 6
**Plans:** 5/7 plans complete

**Status:** Complete.

**Plan breakdown:**
- [x] 07-02: Color Assets & Theme System
- [x] 07-03: Hero Card (Zone 1)
- [x] 07-04: AF Burden Card (Zone 2)
- [x] 07-05: 24h Rhythm Map (Zone 3) - skipped
- [x] 07-06: Clinical Metrics Grid (Zone 4)
- [x] 07-07: Symptom Capture Button (Zone 5)

### Phase 8: New Color Palette

**Goal:** Implement color palette from SPECIFICATION.md - replace hardcoded RGB values with Color Set references
**Requirements:** UI-01, UI-02
**Depends on:** Phase 7
**Plans:** 7/5 plans complete

**Status:** In Progress.

**Plan breakdown:**
- [x] 08-01: Theme.swift Color Set references (Wave 1)
- [x] 08-02: AI Token Color Sets (Wave 2)
- [x] 08-03: Gradient Color Sets (Wave 2)
- [x] 08-04: Text Opacity Modifiers (Wave 3)
- [ ] 08-05: Hardcoded Color Sweep (Wave 4)

---

*Phase 8 planned: color palette implementation*

*Last updated: 2026-03-15*
*For execution: `/gsd-execute-phase 8`*
