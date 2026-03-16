# Phase 7: Dashboard Redesign Specification - Context

**Gathered:** 2026-03-14
**Status:** Ready for planning
**Source:** SPECIFICATION.md (Phase Requirements)

<domain>
## Phase Boundary

This phase implements the AFOne Dashboard UI redesign based on Apple Human Interface Guidelines. The dashboard has two primary states:
- **Normal Rhythm (SR):** Sinus rhythm confirmed - green clinical indicator
- **Active AF:** Atrial fibrillation in progress - red clinical indicator

The UI is organized into 5 zones in a ScrollView:
1. Hero Card - current rhythm status (always above fold)
2. AF Burden Card - burden percentage with time window selector (always above fold)
3. 24h Rhythm Map - bar chart showing hourly classification (partially visible)
4. Clinical Metrics Grid - 2-column LazyVGrid with clinical values (requires scroll)
5. Symptom Capture Button - full-width tappable element (requires scroll)

Key constraint: Dark appearance is fixed (`.preferredColorScheme(.dark)`), not a toggle.

</domain>

<decisions>
## Implementation Decisions

### Color System
- Use iOS semantic colors (`.primary`, `.secondary`, `.systemBackground`, etc.) for all structural UI
- Define custom clinical colors in Assets.xcassets with Any/Dark/High Contrast appearances:
  - `AFOne/RhythmSinusal` - SR state indicator (green)
  - `AFOne/RhythmAF` - AF state indicator (red)
  - `AFOne/BurdenLow` - < 5.5% burden
  - `AFOne/BurdenMid` - 5.5-10.9% burden  
  - `AFOne/BurdenHigh` - ≥ 11% burden
- NO hardcoded hex/RGB values anywhere
- NO custom colors except the 5 brand assets

### Typography System
- Use SF Pro (system font) exclusively via SwiftUI text styles
- Use Dynamic Type text styles throughout (`.caption`, `.footnote`, `.subheadline`, `.title`, etc.)
- Fixed size exception: Burden primary value uses `.system(size: 52, weight: .bold, design: .rounded)`
- Font weights: Bold/Heavy for values, Semibold for labels, Regular for sub-labels

### Layout & Geometry
- Card corner radius: 20pt (RoundedRectangle)
- Card padding: 20pt horizontal, 18pt vertical
- Screen margin: 16pt
- Vertical gap between cards: 12pt
- Bottom padding: 32pt (clear home indicator)

### Accessibility
- Minimum touch targets: 44×44pt
- All interactive elements require `.accessibilityLabel()` and `.accessibilityHint()`
- Respect `@Environment(\.accessibilityReduceMotion)` for animations
- Dynamic Type must not break at accessibilityExtraExtraExtraLarge

### Data Integrity
- Values inferred by AFOne (not direct HealthKit) must be labeled as "est." (estimado)
- 24h Rhythm Map bars with < 3 samples render at 40% opacity with warning in tooltip
- Episode timer displays "From last Apple Watch data" disclosure label

### State Management
- Hero card transforms entirely between SR and AF Active states
- Symptom capture area shows second button with red tint during AF Active

</decisions>

<specifics>
## Specific Technical Requirements

### Zone 1 - Hero Card
- Pulsing animation on rhythm dot (scale 1.0 → 0.85, 2s ease-in-out)
- Glow effect via `.shadow(color:radius:)`
- Stats row: 3 equal columns with Divider separators
- Episode banner (AF Active only): timer + emergency call button (tel://112)

### Zone 2 - AF Burden
- Segmented Picker: 24h / 7d / 30d
- Progress bar: 6pt height, cap at 11% = 100% width
- Threshold tick marks at 5.5% and 11%

### Zone 3 - 24h Rhythm Map
- 24 bars, 2pt gap, max height 36pt
- Bar colors: systemBlue 50% (SR), RhythmAF 90% (AF), systemFill (no data)
- Interaction: Tap card → detail view, tap bar → popover with tooltip

### Zone 4 - Clinical Metrics Grid
- 2-column LazyVGrid, 10pt spacing
- Cards: icon (SF Symbol), label (uppercase), value, sub-label
- Wide card (gridCellColumns: 2) for unmatched symptoms count

### Zone 5 - Symptom Capture Button
- Full-width Button with custom ButtonStyle
- 44pt minimum touch target
- Sheet presentation (not full-screen push)

</specifics>

<deferred>
## Deferred Ideas

The SPECIFICATION explicitly covers only the home screen dashboard. The following are out of scope:
- Detail views for Burden trends, Rhythm Map, Clinical Metrics, Symptom Correlation, Medication
- These are marked for future phases

</deferred>

---

*Phase: 07-dashboard-redesign-specification*
*Context gathered: 2026-03-14 from SPECIFICATION.md*
