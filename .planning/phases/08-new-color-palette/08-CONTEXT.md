# Phase 8: New Color Palette - Context

**Gathered:** 2026-03-15
**Status:** Ready for planning
**Source:** SPECIFICATION.md + codebase analysis

---

## Phase Boundary

Phase 8 implements the color palette defined in SPECIFICATION.md to replace the current broken implementation:
- Current state: Theme.swift uses hardcoded RGB values, Color Set assets exist but aren't properly referenced
- Target state: Full SPEC.md implementation with Color Set references, AI tokens, gradients, and no hardcoded colors

**Depends on:** Phase 7 (Dashboard Redesign)

---

## Implementation Decisions

### 1. Theme.swift Asset Reference Pattern

**Decision:** Use `Color("AFOne/RhythmSinusal")` pattern to reference Color Set assets

**Rationale:**
- Loads from asset catalog at runtime
- Automatically supports All Appearances / Dark / High Contrast variants
- Matches SPEC.md requirement for clinical color invariance

**Implementation:**
```swift
struct AFOneColors {
    let rhythmSinusal = Color("AFOne/RhythmSinusal")
    let rhythmAF = Color("AFOne/RhythmAF")
    let burdenLow = Color("AFOne/BurdenLow")
    let burdenMid = Color("AFOne/BurdenMid")
    let burdenHigh = Color("AFOne/BurdenHigh")
}
```

### 2. AI Tokens

**Decision:** Add AI tokens to Assets.xcassets now (forward-looking)

**Rationale:**
- Color Sets ready when AI features are implemented
- No wasted work later
- Keeps palette complete per SPEC.md

**Tokens to add:**
- `AFOne/AIBase` - violet base for AI elements
- `AFOne/AIBackground` - low-opacity violet background
- `AFOne/AIBorder` - medium-opacity violet border
- `AFOne/ConfConsolidated` - green for ≥30 episodes, ≥60 days
- `AFOne/ConfPreliminary` - amber for 10-29 episodes OR 30-59 days
- `AFOne/ConfInsufficient` - gray for <10 episodes OR <30 days

### 3. Gradients

**Decision:** Convert gradient colors to use Color Set references

**Rationale:**
- Maintains clinical meaning across appearances
- Follows same pattern as solid clinical colors
- Gradient stops reference existing clinical tokens

**Implementation:**
```swift
// Hero SR Gradient
LinearGradient(
    colors: [Color("AFOne/HeroSR1"), Color("AFOne/HeroSR2"), Color("AFOne/HeroSR3")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

**New Color Sets needed for gradients:**
- `AFOne/HeroSR1`, `AFOne/HeroSR2`, `AFOne/HeroSR3` (dark reds)
- `AFOne/HeroAF1`, `AFOne/HeroAF2`, `AFOne/HeroAF3` (dark reds - similar to SR)
- `AFOne/Emergency1`, `AFOne/Emergency2` (emergency gradient)
- `AFOne/AICardBorder` (AI card decorative border)

### 4. Hardcoded Color Sweep

**Decision:** Full sweep across all Swift files

**Files with hardcoded colors to fix:**
| File | Hardcoded Colors Found |
|------|----------------------|
| Theme.swift | `Color(red:green:blue:)` - already identified |
| OverviewView.swift | `Color.red`, `Color.green` |
| RhythmMapView.swift | `Color.blue` |
| TimelineView.swift | `Color.red`, `Color.green`, etc. |
| AuthorizationView.swift | Various |
| TriggerChip.swift | Various |
| DisclaimerView.swift | Various |

**Replacement rules:**
- `Color.red` → `Color.afOne.rhythmAF` (clinical AF indicator)
- `Color.green` → `Color.afOne.rhythmSinusal` (clinical SR indicator)
- `Color.blue` → `Color(.systemBlue)` (structural, not clinical)
- `Color.orange` → `Color.afOne.burdenMid` (burden threshold)
- `Color.gray` → `Color(.systemGray)` (structural unknown state)

### 5. Text Opacity Scale

**Decision:** Add as SwiftUI ViewModifiers, not as Color Sets

**Rationale:**
- Opacity is a modifier on existing colors, not a distinct color
- More flexible for different base colors

**Implementation:**
```swift
extension View {
    func textOpacity(_ level: TextOpacityLevel) -> some View {
        self.foregroundColor(.primary.opacity(level.value))
    }
}

enum TextOpacityLevel {
    case primary      // 100%
    case high         // 85%
    case secondary    // 50%
    case tertiary     // 30%
    case quaternary   // 18%
    case fill         // 7%
}
```

---

## Code Context

### Current Asset Catalog Structure
```
AFOne/Assets.xcassets/
├── AFOne/
│   ├── RhythmSinusal.colorset/    # Exists ✓
│   ├── RhythmAF.colorset/         # Exists ✓
│   ├── BurdenLow.colorset/         # Exists ✓
│   ├── BurdenMid.colorset/        # Exists ✓
│   └── BurdenHigh.colorset/       # Exists ✓
```

### Files to Modify
| File | Action |
|------|--------|
| Theme.swift | Replace hardcoded RGB with Color("AFOne/...") references |
| Assets.xcassets/ | Add AI tokens, gradient colors |
| OverviewView.swift | Replace hardcoded colors |
| RhythmMapView.swift | Replace Color.blue |
| TimelineView.swift | Replace hardcoded colors |
| AuthorizationView.swift | Replace hardcoded colors |
| TriggerChip.swift | Replace hardcoded colors |
| DisclaimerView.swift | Replace hardcoded colors |

### Key Implementation Notes

1. **Color Set naming:** Must match `Color("AFOne/Name")` exactly
2. **Appearance variants:** Each new Color Set needs All Appearances, Dark, High Contrast
3. **Gradients:** Use existing clinical tokens where possible (e.g., BurdenLow for Burden Progress)
4. **Hex in gradients:** Convert any remaining hex strings to Color Sets per SPEC.md

---

## Prior Context References

- **Phase 7 CONTEXT.md:** Zone-based dashboard layout, semantic colors requirement
- **Phase 7 SPECIFICATION.md:** Full color palette spec (this phase implements it)
- **Phase 4 CONTEXT.md:** Theme.swift structure, semantic vs. data-specific colors
- **PROJECT.md:** Not a medical device, privacy-first, offline-first

---

## Requirements Coverage

| SPEC Section | Implementation | Status |
|--------------|---------------|--------|
| Clinical tokens (5) | Color Set assets exist, fix Theme.swift reference | Gap closure |
| Structural tokens | Verify all use iOS semantic colors | Gap closure |
| Text opacity scale | Add ViewModifiers | New |
| AI tokens (6) | Add to Assets.xcassets | New |
| Gradients (5) | Add Color Sets + implement in Theme | New |
| Prohibited practices | Full sweep of hardcoded colors | Gap closure |

---

## Next Steps

**For Planning Agent:**
- Break down into 4-6 plans:
  1. Fix Theme.swift to use Color Set references
  2. Add AI tokens to Assets.xcassets
  3. Add gradient Color Sets
  4. Implement text opacity scale modifiers
  5. Sweep and fix hardcoded colors across all views

---

*Context created: 2026-03-15*
*Discuss-phase completed*
