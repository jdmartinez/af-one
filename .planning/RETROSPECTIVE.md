# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v0.3 — UI Improvements

**Shipped:** 2026-03-19
**Phases:** 6 | **Plans:** 8 | **Sessions:** ~3

### What Was Built
- Multi-window AF burden analysis with clinical thresholds (ASSERT, TRENDS)
- Symptom-rhythm correlation with ±30min window detection
- Dual-layer rhythm map (BarMark + LineMark) with circadian patterns
- Comprehensive emergency report (10 sections) with tel://112
- Data honesty framework: "(est.)" suffixes, "Sin dato" for SpO2, disclosures
- Hero card with 3 states (Sinus Rhythm, Recent Episode, AF Active)

### What Worked
- GSD wave-based execution kept momentum high — phases chained seamlessly from 12→13→14
- Auto-approve (yolo mode) with auto_advance=true enabled rapid multi-phase throughput
- Established patterns (BurdenPeriod enum, SectionHeaderView) reused across phases reduced planning overhead
- TDD approach in plan templates gave executors clear test expectations before implementation

### What Was Inefficient
- Some phases had no CONTEXT.md — planning agent spent time on context gathering that could have been pre-done
- Pre-existing LSP errors (SymptomChip, LogView, TimelineView) remain unresolved — should address before v0.4
- HealthKit limitation discovered mid-phase (no AF condition fetching API) caused rework in Phase 13

### Patterns Established
- `RhythmPeriod` mirrors `BurdenPeriod` — period selection enum pattern now standardized
- `DataHonestyHelper` centralizes transparency utilities — reuse across views
- Circadian block aggregation (8×3h) from CorrelationAnalyzer adapted to RhythmMapDetailViewModel
- `@Observable` MVVM with `@State private var viewModel` injection pattern consistently applied

### Key Lessons
1. Auto-chain with `--auto` flag enables end-to-end milestone execution without manual intervention between phases
2. Gap closure phase pattern (`--gaps-only`) provides surgical fix capability for verification failures
3. Pre-existing code issues (LSP errors) should be tracked as tech debt before next milestone
4. HealthKit limitations (no AF condition queries) require fallback to sample data for patient-facing features

### Cost Observations
- Model mix: ~100% sonnet (executor/verifier/planner)
- Sessions: ~3 (Phase 12, Phase 13, Phase 14 chains)
- Notable: Full milestone (phases 9-14) executed in ~3 hours of agent time across 3 sessions

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v0.1 | ~? | 4 | Foundation, basic GSD workflow |
| v0.2 | ~? | 4 | Theme system, dashboard redesign |
| v0.3 | ~3 | 6 | Auto-chain, gap closure, full milestone execution |

### Cumulative Quality

| Milestone | LOC | Phases | Key Change |
|-----------|-----|--------|------------|
| v0.1 | ~4,000 | 4 | Core health integration |
| v0.2 | ~7,000 | 4 | UI polish, semantic colors |
| v0.3 | ~10,900 | 6 | Clinical views, data honesty |

### Top Lessons (Verified Across Milestones)

1. iOS-only with HealthKit is the right scope — Apple Watch integration provides unique value
2. Offline-first + on-device data privacy is a non-negotiable constraint
3. Auto-advance chains dramatically reduce friction between phases

---
