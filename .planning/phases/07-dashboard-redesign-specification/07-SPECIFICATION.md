# AFOne — Dashboard Redesign Specification

**Milestone:** v0.2
**Date:** 2026-03-14
**Scope:** Dashboard UI — two states: Normal Rhythm (Sinus rhythm - SR) and Active Atrial Fibrillation (AF)
**Compliance:** Apple Human Interface Guidelines for iOS

---

## A note on this document's conventions

All color references use **iOS semantic color tokens** (UIKit / SwiftUI APIs), not hardcoded hex values. Apple explicitly prohibits hardcoding system color values because they fluctuate between OS releases and must adapt to Light Mode, Dark Mode, and increased contrast accessibility settings automatically.

All typography references use **Dynamic Type text styles**, not fixed point sizes. This ensures the interface scales correctly when the user changes their preferred text size in Settings, which is a requirement for App Store compliance and accessibility.

Custom colors needed for clinical state signaling (SR green, AF red, burden amber) are defined as **Color Set assets** in `Assets.xcassets` with separate Any / Dark / High Contrast appearances, following Apple's recommended approach for brand or semantic custom colors.

---

## 1. Design Principles

- **Hierarchy of urgency.** Information is ordered by clinical immediacy. A physician picking up the patient's phone must read the situation in under 3 seconds.
- **State-driven layout.** The AF Active state is a reconfiguration of the SR state, not a separate screen. Shared zones preserve spatial memory; critical zones expand.
- **System-first.** Standard iOS system colors and components are used wherever possible. Custom colors are the exception, not the rule, and are limited to clinical state indicators.
- **HealthKit-honest labeling.** Values inferred by AFOne rather than sourced directly from HealthKit are labeled accordingly in the UI and in any clinical export.
- **Dark appearance as primary.** AFOne targets dark appearance as its fixed presentation (`.preferredColorScheme(.dark)` on the root view), consistent with health and medical apps such as Apple Health, ECG app, and Sleep. This is a deliberate product decision, not a Dark Mode implementation — the app will not flip to light appearance based on system preference.

---

## 2. Screen Structure

The home screen is a single `ScrollView` with five fixed zones, presented inside a `NavigationStack`. The navigation bar is hidden on this screen to maximize vertical space.

```
┌─────────────────────────────┐
│  Status bar (system)        │
├─────────────────────────────┤
│  ① HERO                     │  ← always above the fold
├─────────────────────────────┤
│  ② AF BURDEN (CARGA DE FA)  │  ← always above the fold
├─────────────────────────────┤
│  ③ 24H RHYTHM MAP           │  ← partially visible, invites scroll
├─────────────────────────────┤
│  ④ CLINICAL METRICS GRID    │  ← requires scroll
├─────────────────────────────┤
│  ⑤ SYMPTOM CAPTURE BUTTON   │  ← requires scroll
└─────────────────────────────┘
```

Zones ① and ② must be fully visible on launch without scrolling on any iPhone display ≥ 390 pt (iPhone 14 baseline and all larger models).

---

## 2. Color System

### 2.1 System semantic colors (iOS API — use always for structural UI)

These colors adapt automatically to appearance and accessibility settings. Never replace them with hardcoded values.

| Role                              | SwiftUI                             | UIKit                               |
| --------------------------------- | ----------------------------------- | ----------------------------------- |
| Primary text                      | `.primary`                          | `UIColor.label`                     |
| Secondary text                    | `.secondary`                        | `UIColor.secondaryLabel`            |
| Tertiary text                     | —                                   | `UIColor.tertiaryLabel`             |
| Quaternary text                   | —                                   | `UIColor.quaternaryLabel`           |
| Screen background                 | `Color(.systemBackground)`          | `UIColor.systemBackground`          |
| Elevated card background          | `Color(.secondarySystemBackground)` | `UIColor.secondarySystemBackground` |
| Tertiary fill (subtle containers) | `Color(.tertiarySystemBackground)`  | `UIColor.tertiarySystemBackground`  |
| Grouped background                | `Color(.systemGroupedBackground)`   | `UIColor.systemGroupedBackground`   |
| Separator                         | —                                   | `UIColor.separator`                 |
| Link / interactive accent         | `.accentColor`                      | `UIColor.link`                      |
| System red                        | `Color(.systemRed)`                 | `UIColor.systemRed`                 |
| System green                      | `Color(.systemGreen)`               | `UIColor.systemGreen`               |
| System orange                     | `Color(.systemOrange)`              | `UIColor.systemOrange`              |
| System yellow                     | `Color(.systemYellow)`              | `UIColor.systemYellow`              |
| System blue                       | `Color(.systemBlue)`                | `UIColor.systemBlue`                |

### 2.2 Custom semantic colors (AFOne brand — defined in Assets.xcassets)

These four custom colors are the only non-system colors in AFOne. Each is a Color Set asset with three appearances: Any (Light), Dark, and High Contrast.

| Asset name            | Purpose                                       | Clinical meaning           |
| --------------------- | --------------------------------------------- | -------------------------- |
| `AFOne/RhythmSinusal` | SR state indicator, positive delta            | Sinus rhythm confirmed     |
| `AFOne/RhythmAF`      | AF state indicator, episode banner, emergency | Atrial fibrillation active |
| `AFOne/BurdenLow`     | Burden bar and value below ASSERT threshold   | Burden < 5.5%              |
| `AFOne/BurdenMid`     | Burden bar and value in ASSERT risk zone      | Burden 5.5% – 10.9%        |
| `AFOne/BurdenHigh`    | Burden bar and value at TRENDS threshold      | Burden ≥ 11%               |

> **Implementation note:** Do not approximate these with `systemGreen`, `systemRed`, etc. The clinical meaning of these colors must remain stable and unambiguous regardless of OS changes to system color values. Define them explicitly in the asset catalog.

### 2.3 Prohibited practices

- No hardcoded hex or RGB values anywhere in SwiftUI views or UIKit code.
- No use of `UIColor(red:green:blue:alpha:)` for any color that maps to a semantic role.
- No custom colors for anything other than the five assets listed in 2.2.
- No colors that only work in dark appearance without a defined light appearance variant.

---

## 3. Typography System

AFOne uses **San Francisco (SF Pro)** exclusively — the iOS system font, applied automatically when using `.font(.system(...))` or SwiftUI text styles. No custom typefaces.

All text in the app uses **Dynamic Type text styles**. Fixed point sizes are prohibited except for the two cases noted below.

### 3.1 Dynamic Type text style mapping

| UI element                                | Text style  | SwiftUI                                                     | Notes                                                |
| ----------------------------------------- | ----------- | ----------------------------------------------------------- | ---------------------------------------------------- |
| Section labels (e.g., "ESTADO DEL RITMO") | Caption 2   | `.font(.caption2)`                                          | All-caps via `.textCase(.uppercase)`                 |
| Metric sub-labels, timestamps             | Caption 1   | `.font(.caption)`                                           |                                                      |
| Confidence badge, threshold badge         | Caption 1   | `.font(.caption)`                                           |                                                      |
| Stats column labels                       | Footnote    | `.font(.footnote)`                                          |                                                      |
| Card section titles (e.g., "AF BURDEN")   | Subheadline | `.font(.subheadline)`                                       |                                                      |
| Hero stats values (FC, episodes)          | Title 3     | `.font(.title3)`                                            |                                                      |
| Episode onset label, burden unit          | Title 3     | `.font(.title3)`                                            |                                                      |
| Rhythm label ("Ritmo Sinusal")            | Title 1     | `.font(.title)`                                             |                                                      |
| FAB primary label                         | Headline    | `.font(.headline)`                                          |                                                      |
| Episode timer                             | —           | `.font(.system(.title, design: .monospaced))`               | Monospaced to prevent layout shifts during countdown |
| Burden primary value                      | —           | `.font(.system(size: 52, weight: .bold, design: .rounded))` | ⚠️ Fixed size exception — see note                    |

> **Fixed size exception:** The AF Burden percentage value is a single large numeric display, not body text. It uses a fixed size with `.rounded` design for visual impact. This is consistent with how Apple's own Clock, Health, and Activity apps handle large numeric KPI displays. It must still pass a minimum contrast ratio of 4.5:1 against its background.

> **SF Pro Display vs SF Pro Text:** The system handles this distinction automatically at runtime. In Xcode previews and design mockups, use SF Pro Text for text styles that resolve to ≤ 19 pt, and SF Pro Display for those that resolve to ≥ 20 pt at the default accessibility size.

### 3.2 Font weight usage

- **Bold / Heavy:** Primary numeric values only (burden value, episode timer).
- **Semibold:** Section labels, card titles, FAB primary label, rhythm label.
- **Regular:** All sub-labels, timestamps, secondary descriptions.
- Do not use Ultralight, Thin, or Light — they fail contrast requirements at small sizes.

---

## 4. Zone ① — Hero Card

The dominant element. Communicates current rhythm status unambiguously. Its background, indicator color, and content change entirely between states.

### 4.1 Card geometry

- Container: `RoundedRectangle(cornerRadius: 20)` — 20 pt corner radius, consistent with iOS system card convention.
- Background: `Color(.secondarySystemBackground)` overlaid with a subtle linear gradient using the state-appropriate custom color at low opacity (10–15%). The gradient adds clinical context without overriding the adaptive background.
- Padding: 20 pt horizontal, 18 pt vertical.
- Margin from screen edges: 16 pt (standard iOS content margin).

### 4.2 SR State

**Section label:** "CURRENT RHYTHM" — `.caption2`, `.textCase(.uppercase)`, `.foregroundStyle(.tertiary)`.

**Rhythm indicator row:**

- Animated dot: 10 pt circle filled with `AFOne/RhythmSinusal`. Pulsing scale animation (1.0 → 0.85, 2s ease-in-out, repeating). Glow effect via `.shadow(color: AFOne/RhythmSinusal, radius: 6)`.
- Rhythm label: "Ritmo Sinusal" — `.title`, `.semibold`, `.foregroundStyle(.primary)`.
- Confidence badge (trailing): "Alta confianza" — `.caption`, `Color(.secondarySystemFill)` background, `.tertiary` foreground, `.capsule()` clip shape.

**Stats row** (separated from rhythm row by a `Divider()`):
Three equal columns using `HStack` with `Spacer()` and internal `Divider()` elements.

| Column         | Label style              | Value style                        | Content        |
| -------------- | ------------------------ | ---------------------------------- | -------------- |
| CURRENT HR     | `.footnote`, `.tertiary` | `.title3`, `.semibold`, `.primary` | e.g., "62 LPM" |
| LAST EPISODE   | `.footnote`, `.tertiary` | `.title3`, `.semibold`, `.primary` | e.g., "14 h"   |
| EPISODES TODAY | `.footnote`, `.tertiary` | `.title3`, `.semibold`, `.primary` | e.g., "2"      |

Sub-label below each value: `.caption`, `.tertiary` (e.g., "En reposo", "hace 3h · 28 min", "↑ 1 vs ayer").

**Timestamp footer:**
`.caption2`, `.quaternary`. Format: "Actualizado hace 42 seg · Apple Watch". Preceded by a 5 pt circle in `AFOne/RhythmSinusal` at 60% opacity.

### 4.3 AF Active State

All geometry identical to SR state. Differences:

- Linear gradient overlay uses `AFOne/RhythmAF` instead of `AFOne/RhythmSinusal`.
- Rhythm dot: `AFOne/RhythmAF`. Glow: `.shadow(color: AFOne/RhythmAF, radius: 8)`.
- Rhythm label: "AF in progress".
- Confidence badge: "Confirmed".
- FC value reflects current irregular rate (e.g., "118 lpm"). Sub-label: "High irregularity".
- Column 2 value: "—". Sub-label: "Active episode".
- Timestamp dot: `AFOne/RhythmAF`.

**Episode banner** (inserted between rhythm row and stats row):

A secondary card using `Color(.tertiarySystemBackground)` with a `1 pt` border in `AFOne/RhythmAF` at 30% opacity, corner radius 14 pt.

- Left:
  - "ACTIVE EPISODE" — `.caption2`, `.textCase(.uppercase)`, foreground `AFOne/RhythmAF`.
  - Episode timer (counting up): `.system(.title, design: .monospaced)`, `.bold`, `.primary`. Counts elapsed time since the onset of the last `irregularHeartRhythmEvent` without a subsequent sinus restoration event. This is **not** a real-time rhythm monitor — it reflects the last known HealthKit observation, which may be minutes old.
  - Disclosure label: "From last Apple Watch data" — `.caption2`, `AFOne/RhythmAF` at 60% opacity. **Mandatory.** Prevents the timer from being misread as a live continuous measurement.
  - Onset: "From 09:18" — `.caption`, `.secondary`.
- Right: Emergency call button — `Button("📞 Urgencias")` with background `AFOne/RhythmAF`, foreground `.white`, corner radius 12 pt, minimum touch target 44×44 pt. Action: `UIApplication.shared.open(URL(string: "tel://112")!)`.

> **Touch target rule:** All interactive elements must be at minimum 44×44 pt per Apple HIG. The emergency button must meet this regardless of its visual size.

---

## 5. Zone ② — AF Burden (Carga de FA)

### 5.1 Card

`RoundedRectangle(cornerRadius: 20)`, `Color(.secondarySystemBackground)`, 20 pt padding, 16 pt margin.

### 5.2 Time window selector

`Picker` with `.segmentedPickerStyle()`. Options: 24h / 7d / 30d. This is a native iOS segmented control — do not build a custom one.

### 5.3 Primary value

- Number: `.system(size: 52, weight: .bold, design: .rounded)`. Color: one of `AFOne/BurdenLow`, `AFOne/BurdenMid`, or `AFOne/BurdenHigh` based on value thresholds below.
- Unit label: "%" — `.title3`, `.secondary`, baseline-aligned with the number.
- Threshold badge: e.g., "↓ ASSERT <5.5%". `.caption`, foreground and background both derived from the active burden color asset at 70% and 15% opacity respectively. `.capsule()` clip shape.

**Burden color logic:**

| Range        | Asset              | Clinical reference             |
| ------------ | ------------------ | ------------------------------ |
| < 5.5%       | `AFOne/BurdenLow`  | Below ASSERT threshold         |
| 5.5% – 10.9% | `AFOne/BurdenMid`  | ASSERT risk zone               |
| ≥ 11%        | `AFOne/BurdenHigh` | High burden / TRENDS threshold |

### 5.4 Progress bar

`GeometryReader`-based custom view, 6 pt height, `Color(.systemFill)` background, `RoundedRectangle(cornerRadius: 3)`. Fill uses a `LinearGradient` from `AFOne/BurdenLow` to the active burden color. Fill width proportional to burden value capped at 11% = 100% width.

Two threshold tick marks overlay the bar as thin `Rectangle` views (2 pt wide, 12 pt tall):

- At 50% bar position (= 5.5% burden): `AFOne/BurdenMid` at 60% opacity.
- At 100% bar position (= 11% burden): `AFOne/BurdenHigh` at 60% opacity.

### 5.5 Legend

Three `Label` views inline: "Bajo riesgo", "≥5.5% ASSERT", "≥11% Alto". `.caption2`, `.tertiary`. Colored dots use `Circle()` fills from the corresponding burden assets.

### 5.6 Delta row

`Divider()` then a text row. Format: "+0.8% vs semana pasada · 2 episodios hoy". Delta value uses `AFOne/RhythmAF` if positive, `AFOne/RhythmSinusal` if negative. `.caption`, `.tertiary` for the surrounding text.

> **Data note:** AF Burden is not a native HealthKit value. It is calculated by AFOne from `irregularHeartRhythmEvent` timestamps. It is an estimate and must be labeled as such in any clinical export.

---

## 6. Zone ③ — 24h Rhythm Map

### 6.1 Card

Same geometry as Zone ②.

### 6.2 Bar chart

24 bars, equal width, 2 pt gap, `HStack(spacing: 2)`. Each bar is a `RoundedRectangle(cornerRadius: 3)` with corners applied to top only via a custom `Shape`. Maximum height: 36 pt. Bars are bottom-aligned via a shared container with fixed height.

Bar color encoding:

- Sinus rhythm: `Color(.systemBlue)` at 50% opacity.
- Atrial fibrillation: `AFOne/RhythmAF` at 90% opacity.
- No data: `Color(.systemFill)`. Minimum height 4 pt.

Bar height encodes normalized relative heart rate for that hour based on available `heartRate` samples. Hours with zero samples render at minimum height in the no-data color regardless of their inferred rhythm state.

> **Data fidelity constraint:** Each bar represents AFOne's best-effort classification of a one-hour window, not a continuous recording. Apple Watch delivers `heartRate` samples approximately every 5 minutes at rest and more frequently during activity, but coverage is not guaranteed for every hour — gaps are normal, particularly during sleep or low-motion periods. Bars must never be rendered as fully opaque or visually "certain" when the underlying sample count is low. Apply 40% opacity to any bar backed by fewer than 3 `heartRate` samples in that hour window.

### 6.3 Time axis

`HStack(alignment: .top)` with labels at 00:00, 06:00, 12:00, 18:00, 23:00. `.caption2`, `.quaternary`.

### 6.4 Legend

`Divider()` then three `Label` views: "Ritmo sinusal", "Fibrilación auricular", "Sin datos". Legend squares: `RoundedRectangle(cornerRadius: 2)` 8×8 pt. `.caption`, `.secondary`.

### 6.5 Interaction

Tap on the card navigates to the full Rhythm Map detail view. Tap on an individual bar presents a tooltip `popover` showing: hour range, inferred rhythm classification, and sample count (e.g., "4 lecturas de FC"). If sample count is below 3, the tooltip must display an explicit warning: "Datos insuficientes — clasificación estimada". Popover uses `Color(.systemBackground)` and `.subheadline` / `.caption` text styles.

> **Data note:** The map is a visual approximation based on `heartRate` and `irregularHeartRhythmEvent` cross-referencing. It is not a continuous ECG recording. Each bar represents AFOne's best inference for that hour.

---

## 7. Zone ④ — Clinical Metrics Grid

A 2-column `LazyVGrid` with 10 pt spacing. Card geometry: `RoundedRectangle(cornerRadius: 18)`, `Color(.secondarySystemBackground)`, 16 pt padding.

Each card:

- SF Symbol icon: 20 pt, `Color(.secondaryLabel)`, `.font(.title3)`.
- Label: `.caption2`, `.textCase(.uppercase)`, `.foregroundStyle(.tertiary)`.
- Primary value: `.title3`, `.bold`, `.foregroundStyle(.primary)`.
- Unit: `.subheadline`, `.foregroundStyle(.secondary)`, inline with value.
- Sub-label: `.caption`, `.foregroundStyle(.tertiary)`.

### 7.1 Standard cards (2-column layout)

| Card                 | SF Symbol           | Label                | Value source                                                 | Notes                                                                                                                                                                                                                                                                                                                                                                                              |
| -------------------- | ------------------- | -------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SpO₂ en episodio     | `lungs.fill`        | SpO₂ EN EPISODIO     | `HKQuantityTypeIdentifier.oxygenSaturation` × episode window | Value is only displayed when a reading exists within ±15 min of an episode. When no coincident reading exists, the card shows "No data" in `.secondary` style plus the sub-label "No data during episode". The card must never display a SpO₂ value from outside the episode window.                                                                                                               |
| HRV (SR-filtrado)    | `waveform.path.ecg` | HRV (EN RS)          | `heartRateVariabilitySDNN` × SR windows                      | Labeled "est." in export                                                                                                                                                                                                                                                                                                                                                                           |
| Resp. ventricular AF | `bolt.heart.fill`   | RESP. VENTRICULAR AF | `heartRate` × AF windows                                     | Value is inferred by cross-referencing `heartRate` samples against `irregularHeartRhythmEvent` windows — HealthKit does not tag individual HR samples with rhythm context. The card must display "est." as a persistent inline suffix on the value (e.g., "112 lpm est.") in `.caption`, `.tertiary` style, visible at all times — not only in exports. Shows "—" if no AF episode occurred today. |
| Duración episodio    | `clock.fill`        | DURACIÓN EP.         | Derived from `irregularHeartRhythmEvent` intervals           | Duration + onset time                                                                                                                                                                                                                                                                                                                                                                              |

### 7.2 Wide card (full-width, `gridCellColumns: 2`)

**Label:** SÍNTOMAS SIN RITMO EXPLICATIVO
**Value:** Integer count (`.title3`, `.bold`).
**Sub-label:** Most recent unmatched capture timestamp + a `Button("Ver correlación →")` using `.accentColor` and `.caption` text style.

This card is the entry point for the symptom-rhythm correlation view.

---

## 8. Zone ⑤ — Symptom Capture Button

A full-width tappable element at the bottom of the scroll content. Implemented as a `Button` with a custom `ButtonStyle` — not a `ZStack` with a `TapGesture`.

**Background:** `Color(.secondarySystemBackground)` with a subtle `AFOne/RhythmSinusal`-tinted overlay at 8% opacity. `RoundedRectangle(cornerRadius: 18)`. Border: `Color(.separator)`, 1 pt via `.overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(.separator), lineWidth: 1))`.

**Layout:** `HStack(spacing: 14)`:

1. Icon container: 44×44 pt, `Color(.tertiarySystemFill)`, `RoundedRectangle(cornerRadius: 14)`. Icon: `Image(systemName: "plus.circle.fill")`, `.title3`, `Color(.systemBlue)`.
2. `VStack(alignment: .leading, spacing: 2)`:
   - "Capturar síntoma" — `.headline`, `.primary`.
   - "Registrar + iniciar ECG de 30s" — `.subheadline`, `.secondary`.
3. Trailing: `Image(systemName: "chevron.right")`, `.caption`, `.tertiary`.

**Touch target:** The entire `HStack` container must be at least 44 pt tall. Add `.contentShape(RoundedRectangle(cornerRadius: 18))` to ensure the full card area is tappable.

**Action:** Presents a modal sheet (`.sheet(isPresented:)`) for symptom capture. Not a full-screen push.

**AF Active state modification:** In AF Active state, a second button card is shown above this one, using `AFOne/RhythmAF` tint overlay, labeled "Episodio en curso — Capturar contexto" with sub-label "Registrar síntomas durante el episodio activo".

---

## 9. Spacing & Layout

AFOne uses iOS standard spacing values throughout. Do not invent intermediate values.

| Context                        | Value           | Source                                                                     |
| ------------------------------ | --------------- | -------------------------------------------------------------------------- |
| Screen horizontal margin       | 16 pt           | iOS standard content margin                                                |
| Vertical gap between cards     | 12 pt           |                                                                            |
| Card internal padding          | 16–20 pt        |                                                                            |
| Stats column separator         | `Divider()`     | Native, adapts to appearance                                               |
| Grid gap                       | 10 pt           |                                                                            |
| Bottom padding below last card | 32 pt           | Clears home indicator safe area                                            |
| Safe area insets               | System-provided | Use `.ignoresSafeArea()` only on backgrounds, never on interactive content |

---

## 10. Accessibility Requirements

These are not optional. They apply to every element in this screen.

- **Dynamic Type:** All text uses Dynamic Type text styles. The layout must not break at `accessibilityExtraExtraExtraLarge`. Use `@ScaledMetric` for spacing and icon sizes that need to grow with text.
- **Minimum touch targets:** 44×44 pt on all interactive elements. Apply `.frame(minWidth: 44, minHeight: 44)` or `.contentShape()` where visual size is smaller.
- **Color contrast:** Minimum 4.5:1 for body text, 3:1 for large text (≥ 18 pt regular or ≥ 14 pt bold). Verify all five custom color assets against their expected backgrounds using Xcode's Accessibility Inspector.
- **VoiceOver:** All interactive elements have explicit `.accessibilityLabel()` and `.accessibilityHint()`. The episode timer has `.accessibilityValue()` that reads the elapsed time in natural language ("23 minutos, 14 segundos").
- **Increase Contrast:** The system will automatically increase contrast for semantic colors. For custom color assets, define a High Contrast appearance in the asset catalog.
- **Reduce Motion:** The pulsing dot animation must respect `@Environment(\.accessibilityReduceMotion)`. When true, replace the animation with a static filled circle.

---

## 11. State Transition Summary

| Element              | SR State                     | AF Active State                    |
| -------------------- | ---------------------------- | ---------------------------------- |
| Hero background tint | `AFOne/RhythmSinusal` at 10% | `AFOne/RhythmAF` at 10%            |
| Rhythm dot color     | `AFOne/RhythmSinusal`        | `AFOne/RhythmAF`                   |
| Rhythm label         | "Ritmo Sinusal"              | "Fibrilación Auricular"            |
| Confidence badge     | "Alta confianza"             | "Confirmado"                       |
| Episode banner       | Hidden                       | Visible — timer + emergency call   |
| Stats row col. 2     | Last episode duration        | "Episodio activo"                  |
| Timestamp dot        | `AFOne/RhythmSinusal`        | `AFOne/RhythmAF`                   |
| Symptom capture area | Single button (blue tint)    | Two buttons — second with red tint |

---

## 12. Data Source Summary

| Displayed value            | HealthKit identifier                        | Direct / Inferred                    | UI honesty treatment                                                                                                                   |
| -------------------------- | ------------------------------------------- | ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| Current HR                 | `heartRate`                                 | Direct                               | None required                                                                                                                          |
| Rhythm classification      | `irregularHeartRhythmEvent`                 | Direct (event-based, not continuous) | Confidence badge in Hero                                                                                                               |
| Time in current episode    | Derived from event timestamps               | Inferred                             | Mandatory disclosure label: "Desde último dato de Apple Watch"                                                                         |
| AF Burden %                | Derived from event intervals                | Inferred                             | Labeled "est." in exports; threshold badges provide clinical context                                                                   |
| Last episode duration      | Derived from event intervals                | Inferred                             | None required — presented as historical fact                                                                                           |
| Episode count today        | Count of `irregularHeartRhythmEvent`        | Direct                               | None required                                                                                                                          |
| SpO₂ during episode        | `oxygenSaturation` × ±15 min episode window | Inferred — opportunistic             | "Sin dato / No hubo lectura durante el episodio" when no coincident reading. Never displays a reading from outside the episode window. |
| HRV (SR-filtered)          | `heartRateVariabilitySDNN` × SR windows     | Inferred                             | Labeled "est." in exports                                                                                                              |
| Ventricular response in AF | `heartRate` × AF windows                    | Inferred                             | Persistent inline "est." suffix on value in UI                                                                                         |
| 24h rhythm map bars        | `heartRate` + `irregularHeartRhythmEvent`   | Inferred — hourly approximation      | Bars with < 3 samples rendered at 40% opacity; tooltip shows sample count and "Datos insuficientes" warning when applicable            |
| Unmatched symptom count    | AFOne Core Data                             | App-calculated                       | None required                                                                                                                          |

---

*This document covers the home screen only. Detail views for Burden trends, Rhythm Map, Clinical Metrics, Symptom Correlation, and Medication are specified separately.*
