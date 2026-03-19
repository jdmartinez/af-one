# Phase 11: Symptom Correlation View - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Build a symptom-rhythm correlation analysis view where users can understand whether their reported symptoms coincide with AF episodes, identify silent AF, and see auto-detected patterns. Users tap into this view from the app's navigation to answer: "Did my symptoms match AF episodes? Are there hidden patterns?"

Scope: Three-column summary, dual-track timeline with symptom markers, event list with correlation badges, event detail sheet, pattern detection, and methodological note.
Scope excludes: symptom logging (already exists in LogView), medication tracking, long-term trend charts.

</domain>

<decisions>
## Implementation Decisions

### Summary Grid Interaction (SYMP-01)
- **Tap to filter:** Tapping a summary number filters the event list below to that category
- **Active highlighted:** Filtered column highlighted; other two dimmed (not collapsed)
- **Clear filter:** Tap the active column again to clear
- **Visual style:** Hero-style gradient card (dark gradient background, large numbers, color-coded borders — matching BurdenDetailView hero aesthetic)
- **Column order:** Clinical priority left-to-right — Síntomas con FA (green) → Síntomas sin FA (amber) → FA silente (red)
- **FA silente count:** Computed as episodes without coincident symptoms (not from CorrelationAnalyzer — that tracks symptoms-with-episode, not episodes-without-symptoms)

### Timeline Track Layout (SYMP-02, SYMP-03)
- **Segmented picker:** 24h / 7 días / 30 días — same as BurdenDetailView
- **Track arrangement:** Overlay pins above bars — symptom markers float above the rhythm bar track
- **Correlation highlighting:** Symptom pin turns red when within ±30min of an AF episode; a bracket spans the AF episode window
- **Symptom pin style:** Symbol + abbreviated label (e.g., 'P' for palpitations). Tapping reveals full symptom type
- **Correlation window:** ±30min around symptom timestamp — symptom is "correlated" if any AF episode overlaps that window

### Event List (SYMP-04)
- **Row tap:** Tap anywhere on the row to open the detail sheet
- **Badge style:** Compact pill badges — "FA confirmada" (green), "Sin correlación" (amber), "FA silente" (red)
- **List length:** Paginated / LazyVStack — load more as user scrolls
- **Row content:** Date, time, duration, HR, symptom type, correlation badge
- **Sort order:** Most recent first

### Event Detail Sheet (SYMP-05)
- **Sheet content:** Symptom type + user notes + rhythm visualization (rhythm state in ±30min window) + clinical interpretation note
- **Rhythm visualization:** Simple inline rhythm indicator showing AF/SR/unknown for the ±30min window
- **Clinical note:** Brief interpretation text ("Este síntoma coincide con un episodio de FA — posible relación")
- **Presentation:** Standard `.sheet` presentation

### Pattern Detection Section (SYMP-06)
- **Display:** Collapsed expandable cards — always visible but collapsed by default
- **Expanded content:** Pattern name + count + clinical interpretation sentence
- **Pattern set:** Three core patterns (nocturnal symptoms without AF, symptoms preceding AF, asymptomatic AF count) PLUS any auto-detected patterns from CorrelationAnalyzer
- **No patterns found:** Show neutral message — "No se han detectado patrones significativos" — section still visible
- **Clinical note examples:**
  - Nocturnal without AF: "Síntomas nocturnos sin FA — pueden tener causas no relacionadas con arritmia"
  - Symptoms preceding AF: "Síntomas previos a FA — pueden ser señales de aviso"
  - Silent AF: "FA silente: episodios de FA sin síntomas reportados — considere revisar su registro de síntomas"

### Methodological Note (SYMP-07)
- **Placement:** Bottom of the view, above the fold
- **Style:** Info-style card (similar to DataHonestyNote from ThresholdComponents)
- **Content:** "La correlación se basa en una ventana de ±30 minutos. Apple Watch no realiza un ECG continuo — los episodios detectados pueden no ser exhaustivos."
- **Visibility:** Always shown (not collapsed)

### Navigation Entry Point
- **Decision deferred to planning.** Options: standalone tab, section on Resumen, navigation from Timeline tab. Planners to evaluate based on information architecture.

</decisions>

<specifics>
## Specific Ideas

- "The summary grid should feel premium — like the BurdenDetail hero card, not a basic stats row"
- "Symptom pins on the timeline should feel integrated, not pasted on top"
- "FA silente is the most clinically interesting column — users often don't know about asymptomatic episodes"
- "The pattern detection section should read like clinical observations, not raw data"
- CorrelationAnalyzer already exists but uses exact episode overlap — planners must extend it to ±30min window

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- **CorrelationAnalyzer.swift** (Core/Analysis/): Actor for symptom-AF correlation analysis. Returns CorrelationResult, SymptomCorrelation[], TriggerCorrelation[]. NOTE: Uses exact episode overlap — must be extended for ±30min window correlation
- **SymptomLog.swift** (Models/): SwiftData model with symptomType, timestamp, notes
- **SymptomChip.swift** (Shared/Components/): Reusable chip for symptom tags
- **TimelineView.swift** (Features/Timeline/): Day blocks + hourly bar charts. Base for dual-track timeline
- **EpisodeListView.swift** (Features/Episodes/): Event list pattern to adapt
- **EpisodeDetailView.swift** (Features/Episodes/): Detail sheet pattern
- **BurdenDetailView.swift** (Features/Dashboard/): Hero gradient card, segmented picker, clinical styling
- **ThresholdComponents.swift** (Shared/Components/): DataHonestyNote reusable component for methodological note
- **Theme.swift**: Color semantics for green/amber/red clinical colors

### Established Patterns
- **Segmented picker:** Picker with .segmented style, .onChange reloads view data
- **Hero gradient cards:** RoundedRectangle with LinearGradient fill, large typography
- **Clinical pill badges:** Capsule shape, colored background, matching foreground
- **Sheet presentation:** .sheet modifier with .presentationDetents([.medium, .large])
- **SwiftData @Query:** For local symptom logs
- **HealthKitService.shared:** For rhythm episodes and heart rate data
- **Color coding:** Green (low/symptoms without AF), Amber (mid/no correlation), Red (high/FA confirmed or silent)

### Integration Points
- New view needs: SymptomLog data (SwiftData @Query), RhythmEpisode data (HealthKitService), CorrelationAnalyzer output
- FA silente requires computing episodes-without-symptoms separately (CorrelationAnalyzer doesn't track this)
- Navigation: Planners to decide entry point — tab, section link, or Timeline integration

### Key Technical Gap
- CorrelationAnalyzer currently checks: `symptom.timestamp >= episode.startDate && symptom.timestamp <= episode.endDate`
- Phase 11 requires: `|symptom.timestamp - episodeTimestamp| <= 30 minutes`
- Planners must extend CorrelationAnalyzer or create a new method for window-based correlation

</code_context>

<deferred>
## Deferred Ideas

- **Navigation entry point:** Not discussed — planners to evaluate (standalone tab vs section link vs Timeline integration)
- **FA silente computation:** Episodes-without-symptoms is a separate computation from CorrelationAnalyzer's symptoms-with-episode logic — needs dedicated approach
- Detail sheet rhythm visualization style (simple inline vs mini chart) — deferred to planning

---

*Phase: 11-symptom-correlation-view*
*Context gathered: 2026-03-19*
