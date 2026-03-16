# AFOne — Color Palette

**Version:** 1.0
**Date:** 2026-03-14
**Primary appearance:** Dark (`.preferredColorScheme(.dark)` fixed app-wide)

---

## Implementation principles

AFOne fixes dark appearance as the app's permanent presentation. Light mode values are nonetheless defined for all Color Set assets as an **accessibility requirement**: certain system surfaces (widgets, notifications, Share Sheet) ignore the app's color scheme preference and always render using the system appearance.

There are two color categories with distinct implementation rules:

- **Clinical tokens** — defined in `Assets.xcassets` as Color Sets with three appearances (Any / Dark / High Contrast). Their values must not be approximated with system colors because their clinical semantics must remain invariant across iOS versions.
- **Structural tokens** — referenced exclusively through iOS semantic color APIs (`Color(.systemBackground)`, etc.). Never as hardcoded hex values. The values shown below are those resolved by the system in dark appearance; they may vary across iOS versions.

---

## 1. Clinical tokens · `Assets.xcassets`

Five assets. Each with three defined appearances.

### `AFOne/RhythmSinusal`

| Appearance    | Value     |
| ------------- | --------- |
| Dark          | `#34d399` |
| Light         | `#059669` |
| High Contrast | `#00c87a` |

**Clinical meaning:** Confirmed sinus rhythm.
**Applied to:**

- Hero dot · SR state
- Positive delta in AF Burden
- High data coverage in Rhythm Map
- HRV data points above personal baseline
- Timestamp dot in Hero (SR state)
- Coverage bar ≥ 90% in Rhythm Map

---

### `AFOne/RhythmAF`

| Appearance    | Value     |
| ------------- | --------- |
| Dark          | `#f87171` |
| Light         | `#dc2626` |
| High Contrast | `#ff3b30` |

**Clinical meaning:** Active or recent atrial fibrillation.
**Applied to:**

- Hero dot · AF active state
- Episode banner · background and title text
- Emergency call button · background
- Active episode timer · accent color
- Negative delta in AF Burden
- Rhythm Map bars · AF windows
- Episode indicators in event list
- Timestamp dot in Hero (AF state)
- Mini-timeline bars in Emergency Report (current day)
- Episode dot in symptom correlation timeline

---

### `AFOne/BurdenLow`

| Appearance    | Value     |
| ------------- | --------- |
| Dark          | `#34d399` |
| Light         | `#059669` |
| High Contrast | `#00c87a` |

> Shares its base value with `RhythmSinusal` but is a separate asset. Its semantics differ (rhythm state vs. burden threshold) and the two may diverge in future versions.

**Clinical meaning:** AF Burden below 5.5% — under the ASSERT threshold.
**Applied to:**

- AF Burden numeric value when < 5.5%
- Start color of the Burden progress bar gradient
- `<5 min` distribution bar in Episode Duration
- Burden trend chart bars (days < 5.5%)
- Ventricular response at rest (color indicates "controlled")

---

### `AFOne/BurdenMid`

| Appearance    | Value     |
| ------------- | --------- |
| Dark          | `#fbbf24` |
| Light         | `#d97706` |
| High Contrast | `#ffcc00` |

**Clinical meaning:** AF Burden between 5.5% and 10.9% — ASSERT risk zone.
**Applied to:**

- AF Burden numeric value when 5.5% ≤ value < 11%
- Threshold badge `⚠ ASSERT ≥5.5%`
- ASSERT threshold tick mark (50% position on the progress bar)
- End color of the Burden progress bar gradient
- Positive burden delta (worsening trend)
- Burden trend chart bars (days 5.5%–11%)
- `30–60 min` distribution bar in Episode Duration
- Physical activity context in Ventricular Response
- Unmatched symptoms in Symptom Correlation view
- HRV data points below personal baseline
- Low-coverage bar dots in tooltips

---

### `AFOne/BurdenHigh`

| Appearance    | Value     |
| ------------- | --------- |
| Dark          | `#f87171` |
| Light         | `#dc2626` |
| High Contrast | `#ff3b30` |

> Shares its base value with `RhythmAF` but is a separate asset for the same reason as `BurdenLow` / `RhythmSinusal`.

**Clinical meaning:** AF Burden ≥ 11% — TRENDS high-risk threshold.
**Applied to:**

- AF Burden numeric value when ≥ 11%
- Threshold badge `▲ TRENDS ≥11%`
- TRENDS threshold tick mark (100% position on the progress bar)
- Burden trend chart bars (days ≥ 11%)
- `>1 hour` distribution bar in Episode Duration
- Ventricular response bars > 120 bpm in Clinical Metrics

---

## 2. Structural tokens · iOS Semantic Colors

Referenced exclusively by API. The hex values shown are those resolved by iOS in dark appearance.

### `systemBackground`

| Property   | Value                      |
| ---------- | -------------------------- |
| SwiftUI    | `Color(.systemBackground)` |
| UIKit      | `UIColor.systemBackground` |
| Dark value | `#000000`                  |

**Applied to:** Base background of all screens. Background of tooltips and popovers.

---

### `secondarySystemBackground`

| Property   | Value                               |
| ---------- | ----------------------------------- |
| SwiftUI    | `Color(.secondarySystemBackground)` |
| UIKit      | `UIColor.secondarySystemBackground` |
| Dark value | `#1c1c28`                           |

**Applied to:** Background of all data cards across all five views. Primary content container for each zone.

---

### `tertiarySystemBackground`

| Property   | Value                              |
| ---------- | ---------------------------------- |
| SwiftUI    | `Color(.tertiarySystemBackground)` |
| UIKit      | `UIColor.tertiarySystemBackground` |
| Dark value | `#2a2a3a`                          |

**Applied to:** Containers nested inside cards — Ventricular Response context cells, episode banner in Hero AF state, bar tooltip background.

---

### `systemGroupedBackground`

| Property   | Value                             |
| ---------- | --------------------------------- |
| SwiftUI    | `Color(.systemGroupedBackground)` |
| UIKit      | `UIColor.systemGroupedBackground` |
| Dark value | `#111116`                         |

**Applied to:** Screen body background. Base of the navigation bar blur material (`rgba(17,17,22,0.92)`).

---

### `systemFill`

| Property   | Value                    |
| ---------- | ------------------------ |
| SwiftUI    | `Color(.systemFill)`     |
| UIKit      | `UIColor.systemFill`     |
| Dark value | `rgba(255,255,255,0.08)` |

**Applied to:** Burden progress bar track. Coverage bar track. No-data hour bars in Rhythm Map. Segmented control background.

---

### `separator`

| Property   | Value                                     |
| ---------- | ----------------------------------------- |
| SwiftUI    | `Color(.separator)` — also as `Divider()` |
| UIKit      | `UIColor.separator`                       |
| Dark value | `rgba(255,255,255,0.07)`                  |

**Applied to:** Row dividers inside cards. Card borders (1 pt). Column separators in the Hero stats row. Navigation bar bottom border. Section borders in the Emergency Report.

---

### `systemBlue`

| Property   | Value                |
| ---------- | -------------------- |
| SwiftUI    | `Color(.systemBlue)` |
| UIKit      | `UIColor.systemBlue` |
| Dark value | `#63b3ff`            |

**Applied to:** Navigation bar back button ("‹ Home"). Interactive links and actions ("See correlation →", "Details →"). Sinus rhythm bars in the Rhythm Map (at 50% opacity). Symptom capture FAB icon. Heart rate line in the Rhythm Map chart.

---

## 3. Text opacity scale

Base: `#ffffff` (dark appearance). All text is implemented using `.foregroundStyle()` in SwiftUI.

| Opacity | Semantic level | SwiftUI              | Applied to                                            |
| ------- | -------------- | -------------------- | ----------------------------------------------------- |
| 100%    | Primary        | `.primary`           | Primary values — HR, burden %, duration, rhythm label |
| 85%     | High           | —                    | Episode text, medication names, insight titles        |
| 50%     | Secondary      | `.secondary`         | Sub-labels, units (bpm, ms, %), confidence badges     |
| 30%     | Tertiary       | `.tertiary`          | Section labels, data notes, card-label text           |
| 18%     | Quaternary     | `.quaternary`        | Timestamps, axis labels, background reference text    |
| 7%      | Fill           | `Color(.systemFill)` | Tracks, subtle card borders, internal separators      |

---

## 4. On-device AI tokens

Distinct visual identity, clearly differentiated from clinical tokens. Single base color — violet — with an opacity scale. Not defined in `Assets.xcassets` because they carry no clinical meaning; they are purely interface-layer identifiers.

### `AIBase`

| Appearance | Value     |
| ---------- | --------- |
| Dark       | `#a78bfa` |
| Light      | `#7c3aed` |

**Applied to:** "On-device" badge, left border accent of inline AI blocks, link text inside insights.

---

### `AIBackground`

| Appearance | Value                    |
| ---------- | ------------------------ |
| Dark       | `rgba(167,139,250,0.06)` |
| Light      | `rgba(124,58,237,0.04)`  |

**Applied to:** Background of all `ai-inline` blocks embedded within data cards.

---

### `AIBorder`

| Appearance | Value                    |
| ---------- | ------------------------ |
| Dark       | `rgba(167,139,250,0.18)` |
| Light      | `rgba(124,58,237,0.15)`  |

**Applied to:** Border of `ai-inline` blocks (1 pt). Border of the main `ai-card` panel (1 pt).

---

### `ConfConsolidated`

| Appearance | Value                  |
| ---------- | ---------------------- |
| Dark       | `rgba(52,211,153,0.7)` |
| Light      | `rgba(5,150,105,0.9)`  |

**Activation criteria:** ≥ 30 episodes and ≥ 60 days of data. Pattern consistent in ≥ 75% of cases.
**Applied to:** "Consolidated" badge on AI insight blocks.

---

### `ConfPreliminary`

| Appearance | Value                  |
| ---------- | ---------------------- |
| Dark       | `rgba(251,191,36,0.7)` |
| Light      | `rgba(217,119,6,0.9)`  |

**Activation criteria:** Between 10 and 29 episodes, or between 30 and 59 days of data.
**Applied to:** "Preliminary" badge on AI insight blocks.

---

### `ConfInsufficient`

| Appearance | Value                   |
| ---------- | ----------------------- |
| Dark       | `rgba(255,255,255,0.3)` |
| Light      | `rgba(60,60,67,0.4)`    |

**Activation criteria:** Fewer than 10 episodes or fewer than 30 days of data. The insight is not shown — only an empty state with an explanation is displayed.
**Applied to:** "Insufficient data" badge in AI insight empty states.

---

## 5. Gradients

All gradients use a fixed angle. They are not animated. Implemented as `LinearGradient` in SwiftUI.

### Hero SR

```swift
LinearGradient(
    colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e"), Color(hex: "#0f3460")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

**Angle:** 160°
**Applied to:** Zone ① Hero Card background in Sinus Rhythm state. Overlaid on `secondarySystemBackground` with an `AFOne/RhythmSinusal` color overlay at 10% opacity to reinforce state identity.

---

### Hero AF

```swift
LinearGradient(
    colors: [Color(hex: "#2d0a0a"), Color(hex: "#3d1010"), Color(hex: "#5c1a1a")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

**Angle:** 160°
**Applied to:** Zone ① Hero Card background in AF Active state. Same angle as Hero SR so that the transition between states is visually coherent. Overlaid with `AFOne/RhythmAF` at 10% opacity.

---

### Emergency Header

```swift
LinearGradient(
    colors: [Color(hex: "#3d0a0a"), Color(hex: "#5c1212")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

**Angle:** 160°
**Applied to:** Full-bleed header of the Emergency Report view. Always active — this view is only presented during an active episode. Has no alternative state.

---

### Burden Progress

```swift
LinearGradient(
    colors: [AFOneColor.BurdenLow, AFOneColor.BurdenMid],
    startPoint: .leading,
    endPoint: .trailing
)
```

**Angle:** 90° (horizontal)
**Applied to:** AF Burden progress bar fill in Zone ② and in the Burden Detail view. The fill is capped at 100% width when the value reaches 11% (TRENDS threshold). Gradient colors are clinical tokens defined in Assets — not direct hex values.

---

### AI Card Top Border

```swift
LinearGradient(
    colors: [
        Color(AIBase).opacity(0.6),
        Color(systemBlue).opacity(0.4),
        AFOneColor.BurdenLow.opacity(0.3)
    ],
    startPoint: .leading,
    endPoint: .trailing
)
```

**Angle:** 90° (horizontal)
**Thickness:** 2 pt
**Applied to:** Decorative top border line of the main AI panel (`ai-card`). Combines the three state colors to signal that the panel aggregates multiple types of analysis. Present only in the main panel — not in `ai-inline` blocks.

---

## 6. Prohibited color practices

The following practices are explicitly prohibited in AFOne:

- Hardcoded hex or RGB values for any color that has an iOS semantic equivalent.
- Use of `UIColor(red:green:blue:alpha:)` for structural colors.
- Approximating `AFOne/RhythmSinusal` with `Color(.systemGreen)` or `AFOne/RhythmAF` with `Color(.systemRed)`. System color values change across iOS versions; the clinical meaning of AFOne's tokens must be stable.
- Colors that only function in dark appearance without a defined light appearance variant in the asset catalog.
- Any new color outside the groups defined in this document without a corresponding update to this specification.

---
