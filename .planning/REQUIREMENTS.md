# Requirements: AFOne v0.2 UI Enhancements

**Defined:** 2026-03-13  
**Core Value:** Transform Apple Watch heart rhythm data into clear, clinically meaningful insights

---

## v0.2 Requirements

### UI Theme

- [x] **UI-01**: Make UI compatible with iOS dark and light theme
- [ ] **UI-01.1**: Create asset catalog colors with dark mode variants
- [ ] **UI-01.2**: Replace hardcoded colors with semantic colors throughout
- [ ] **UI-01.3**: Test all views in both light and dark mode

### Dashboard Redesign

- [x] **UI-02**: Redesign dashboard cards with Health app-like UI
- [ ] **UI-02.1**: Add clear titles to all metric cards
- [ ] **UI-02.2**: Add icons to card headers using semantic colors
- [ ] **UI-02.3**: Move period picker inside AF Burden card header
- [ ] **UI-02.4**: Remove redundant reload button (keep pull-to-refresh)
- [ ] **UI-02.5**: Fix card border rendering issues
- [ ] **UI-02.6**: Add labels/tooltips to toolbar buttons

### Navigation Fixes

- [ ] **UI-03**: Remove duplicate back button in More views
- [ ] **UI-03.1**: Fix More > Emergency Information duplicate back button
- [ ] **UI-03.2**: Fix More > Clinical Report duplicate back button

### Liquid Glass Tab Bar

- [ ] **UI-04**: Implement collapsible Liquid Glass tab bar
- [ ] **UI-04.1**: Add Liquid Glass effect to navigation bar
- [ ] **UI-04.2**: Implement collapse on scroll behavior
- [ ] **UI-04.3**: Add availability checks for iOS 26 APIs

### Localization

- [ ] **UI-05**: Localize the app based on iOS language
- [ ] **UI-05.1**: Create Localizable.xcstrings string catalog
- [ ] **UI-05.2**: Wrap all user-facing strings in Text() or String(localized:)
- [ ] **UI-05.3**: Use locale-aware date/time formatting
- [ ] **UI-05.4**: Test RTL layout readiness

---

## Future Requirements

### v1.0 MVP (Deferred)

- Multi-window AF burden analysis (daily, weekly, monthly)
- Advanced timeline pattern detection (nocturnal, clusters)
- Symptom-rhythm correlation analysis
- Medication awareness from health records
- Long-term trends (6-month, 1-year views)
- Clinical report generation for cardiologist
- Enhanced notifications (long episodes, burden changes)

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| Medical diagnosis | AFOne is informational only, not a medical device |
| Treatment recommendations | Liability concerns |
| Cloud infrastructure | Violates privacy-first principle |
| Real-time cardiac monitoring | Creates anxiety without clinical value |
| Android platform | Apple Watch ecosystem required |

---

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| UI-01 | v0.2 | Complete |
| UI-02 | v0.2 | Complete |
| UI-03 | v0.2 | Pending |
| UI-04 | v0.2 | Pending |
| UI-05 | v0.2 | Pending |

**Coverage:**
- v0.2 requirements: 5 total
- Mapped to phases: 5
- Unmapped: 0 ✓

---

*Requirements defined: 2026-03-13*
