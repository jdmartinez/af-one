# Feature Research

**Domain:** iOS Heart Rhythm Monitoring / AFib Tracking App
**Researched:** 2026-03-10
**Confidence:** MEDIUM

Based on analysis of Apple Watch ecosystem, competing apps (Cardiogram, Heart History, ECG+, AFib Manager, Empirical), and Apple Health capabilities.

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Dashboard with rhythm context | Users want immediate insight into current heart status | MEDIUM | Must show current rhythm state prominently |
| AF burden percentage | Core metric for PAF patients; Apple Watch provides this | LOW | Display weekly/monthly percentages clearly |
| Episode history timeline | Patients need to see when AF occurred | MEDIUM | Timestamps, duration, frequency |
| Heart rate visualization | Understand episode severity and behavior | MEDIUM | Show HR during AF vs normal rhythm |
| Apple Health integration | Primary data source; users expect seamless sync | MEDIUM | Read-only access to heart rhythm data |
| Irregular rhythm notifications | Apple Watch alerts users; app should surface | LOW | Mirror/represent existing notifications |
| Basic symptom logging | Patients track what they feel | MEDIUM | Simple timestamp + symptom type entry |
| Clear disclaimer (not medical device) | Regulatory requirement; builds trust | LOW | Prominent on first launch and settings |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Symptom-rhythm correlation | Connect what patient feels to what watch records | HIGH | Link logged symptoms to AF episodes by time |
| Lifestyle trigger tracking | Identify what causes AF episodes | MEDIUM | Log caffeine, alcohol, stress, sleep, exercise |
| HR behavior analysis during AF | Understand episode patterns (rapid vs gradual onset) | MEDIUM | Compare HR at episode start vs peak |
| Multi-window burden (daily/weekly/monthly) | Different timeframes useful for different decisions | LOW | Apple provides weekly; add daily/monthly |
| Clinical report PDF export | Share with cardiologist in usable format | MEDIUM | Concise 2-3 page summary preferred |
| Medication awareness from Health Records | Context for rhythm patterns | LOW | Read medications from Apple Health |
| Long-term trend visualization | See if condition is improving/worsening | MEDIUM | 3-month, 6-month, 1-year trends |
| Color-coded burden zones | Quick visual assessment (Green/Orange/Red) | LOW | Similar to Heart History app |
| Emergency information quick access | Critical for first responders | LOW | Name, condition, medications, emergency contact |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Real-time continuous monitoring | "More data is better" | Creates anxiety, battery drain, no clinical value for PAF | Focus on retrospective analysis |
| Cloud sync/backups | Data safety concerns | Violates privacy-first principle; adds backend complexity | Emphasize on-device storage |
| Write data back to Apple Health | "Let me add notes to Health" | Accuracy concerns; Apple doesn't expect app-written rhythm data | Store notes in app only |
| Treatment recommendations | Patients want guidance | Liability; requires medical device classification | Keep informational; recommend consulting doctor |
| Automated alerts for every episode | "Notify me immediately" | Causes alarm fatigue; Apple Watch already alerts | Surface existing notifications cleanly |
| Direct cardiologist connectivity | "Send data to my doctor" | HIPAA/compliance complexity; doctors use EHR | PDF export for patient to share |

## Feature Dependencies

```
Dashboard
    └──requires──> Apple Health Integration
    └──requires──> Episode History

Episode History
    └──requires──> Apple Health Integration

AF Burden Calculation
    └──requires──> Apple Health Integration
    └──requires──> Episode History

Symptom-Rhythm Correlation
    └──requires──> Symptom Logging
    └──requires──> Episode History

Lifestyle Trigger Tracking
    └──requires──> Lifestyle Logging
    └──requires──> Episode History

Clinical Report Export
    └──requires──> Episode History
    └──requires──> AF Burden Calculation
    └──requires──> Long-term Trends
```

### Dependency Notes

- **Dashboard requires Apple Health Integration:** Cannot show anything without reading data from HealthKit first
- **Symptom-rhythm correlation requires both:** Must have symptom entries AND episode data to find temporal overlaps
- **Clinical report requires multiple features:** A useful summary needs episode history, burden stats, and trend data

## MVP Definition

### Launch With (v1)

Minimum viable product — what's needed to validate the concept.

- [ ] Dashboard with current rhythm context and recent AF activity — primary value proposition
- [ ] Apple Health integration for reading rhythm data — data source foundation
- [ ] AF burden calculation (weekly) — core metric from Apple Watch
- [ ] Episode history timeline — basic event tracking
- [ ] Clear non-medical-device disclaimer — regulatory requirement
- [ ] Heart rate visualization during episodes — understanding severity

### Add After Validation (v1.x)

Features to add once core is working.

- [ ] Symptom logging with timestamp association — user value add
- [ ] Symptom-rhythm correlation analysis — differentiation
- [ ] Lifestyle trigger tracking — pattern identification
- [ ] Multiple burden time windows (daily/monthly) — better context
- [ ] Medication awareness from Health Records — contextual insight
- [ ] Clinical report PDF export — cardiologist communication

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] Long-term trends (6-month, 1-year) — requires accumulated data
- [ ] Color-coded burden zones — UI enhancement
- [ ] HR behavior analysis during AF — deeper analytics
- [ ] Emergency information quick access — safety feature
- [ ] Widget support — iOS home screen integration
- [ ] Apple Watch app — glanceable data

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Apple Health integration | HIGH | MEDIUM | P1 |
| Dashboard with context | HIGH | MEDIUM | P1 |
| AF burden (weekly) | HIGH | LOW | P1 |
| Episode history timeline | HIGH | MEDIUM | P1 |
| Heart rate visualization | HIGH | MEDIUM | P1 |
| Disclaimer | HIGH | LOW | P1 |
| Symptom logging | MEDIUM | MEDIUM | P2 |
| Symptom-rhythm correlation | HIGH | HIGH | P2 |
| Lifestyle trigger tracking | MEDIUM | MEDIUM | P2 |
| Burden (daily/monthly) | MEDIUM | LOW | P2 |
| Medication awareness | LOW | LOW | P2 |
| Clinical report export | HIGH | MEDIUM | P2 |
| Long-term trends | MEDIUM | MEDIUM | P3 |
| Color-coded zones | LOW | LOW | P3 |
| HR behavior analysis | MEDIUM | MEDIUM | P3 |
| Emergency info | MEDIUM | LOW | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Apple Health | Heart History | ECG+ | Cardiogram | Our Approach |
|---------|--------------|---------------|------|------------|---------------|
| AF burden display | Weekly only | Weekly + zones | No | No | Weekly + daily/monthly |
| Episode timeline | Limited | Timeline view | No | Minute-by-minute | Detailed timeline |
| Symptom logging | No | No | No | Yes | Yes, with correlation |
| PDF export | Raw data | No | No | No | Concise clinical report |
| Lifestyle factors | Yes (life factors) | No | No | No | Tracked + correlated |
| HRV analysis | Basic | No | Advanced | No | Future consideration |
| Not medical device | Yes | Yes | Yes | Yes | Clear disclaimer |

## Sources

- Apple Support: Track your AFib History with Apple Watch (2024)
- App Store: Heart History: AFib & Alerts, ECG+, Cardiogram, AFib Manager, Empirical
- Reddit: App to Export Cardiological Trends in a Clear, Concise PDF for Cardiologist (2025)
- JACC: Enhanced Detection and Prompt Diagnosis of Atrial Fibrillation Using Apple Watch (2025)
- Cardiomatics: AF Burden: A Key Metric in AF Management (2025)
- ACC: Guidance on Using Apple Watch for Heart Health Monitoring (2025)

---
*Feature research for: iOS Heart Rhythm Monitoring / AFib Tracking*
*Researched: 2026-03-10*
