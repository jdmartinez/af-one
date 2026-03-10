# Domain Pitfalls: iOS Heart Rhythm Monitoring App

**Project:** AFOne - Paroxysmal Atrial Fibrillation Monitoring  
**Researched:** 2026-03-10  
**Confidence:** MEDIUM-HIGH

---

## Critical Pitfalls

### 1. Misunderstanding Apple Watch Data Collection Model

**What goes wrong:** Assuming Apple Watch provides continuous heart rhythm monitoring when it's actually opportunistic sampling.

**Why it happens:** 
- Apple Watch uses photoplethysmography (PPG) for irregular rhythm notifications, not continuous ECG
- AFib History feature analyzes pulse data "opportunistically" - not continuous monitoring
- Long gaps (hours/days) between readings are normal, not a bug

**Consequences:**
- Users expect comprehensive data coverage but get sparse, irregular samples
- App displays appear incomplete or misleading
- User trust erodes when they realize data gaps are normal

**Prevention:** 
- Design UI to explicitly show data coverage windows
- Educate users upfront about opportunistic monitoring
- Add empty state handling for periods with no data
- Display last sync timestamp prominently

**Warning signs:**
- Users asking "why is my timeline empty?"
- Complaints about missing data
- Review: "App doesn't show my heart data"

**Phase:** Foundation (Data Layer) - This shapes all data handling architecture.

---

### 2. Background Data Sync Unreliability

**What goes wrong:** HKObserverQuery doesn't fire reliably when app is backgrounded; users see stale data.

**Why it happens:**
- iOS throttles background delivery aggressively, especially on watchOS
- HKAnchoredObjectQuery results handlers often don't execute in background
- Device-specific issues: Apple Watch Series 10 has reduced background delivery frequency
- Apple Health app becomes the primary data source, not your app

**Consequences:**
- App shows outdated information until user opens it
- Notifications for new episodes arrive late or never
- Poor user experience when checking for recent AF events

**Prevention:**
- Implement foreground-only data refresh on app launch
- Use BGTaskScheduler for periodic refresh (not guaranteed)
- Rely on Apple Health app for primary data entry
- Consider HKStatisticsCollectionQuery for historical data on each launch

**Warning signs:**
- Data appears only after manually opening app
- Console shows "HKAnchoredObjectQuery result handler not called"
- Different data between app and Apple Health

**Phase:** Foundation (Data Layer) - Background sync must be designed around limitations.

---

### 3. Regulatory Boundary Violation (Medical Device Claims)

**What goes wrong:** App makes diagnostic claims or suggests it can detect/diagnose AF, triggering FDA regulatory issues.

**Why it happens:**
- AF detection is FDA-cleared feature of Apple Watch, not third-party apps
- Phrases like "AF detector," "arrhythmia alert," or "diagnoses AF" cross the line
- Interpreting rhythm data as "AF episode" is diagnosis

**Consequences:**
- App Store rejection
- Legal liability if users rely on app for medical decisions
- Potential FDA enforcement action
- Must redesign app around existing disclaimers

**Prevention:**
- Use consistent, explicit disclaimers: "Not a medical device" / "For informational purposes only"
- Never use words like "detect," "diagnose," "alert" for AF
- Frame as "rhythm interpretation" or "pattern visualization"
- Model AFOne after Apple's own approach: show Apple Watch data, don't interpret it as diagnosis
- Include in every screen: "This app displays data from Apple Watch. It does not diagnose or treat any condition."

**Warning signs:**
- Marketing copy uses medical terminology
- Product descriptions mention "detection" or "diagnosis"
- Legal review flagged

**Phase:** Foundation - This must be built into core architecture and UI patterns.

---

### 4. Query Performance with Large Datasets

**What goes wrong:** Querying months/years of heart rhythm data causes app freezing or crashes.

**Why it happens:**
- HKStatisticsCollectionQuery can take several seconds even for 1-day queries
- NSXPCDecoder spends significant time decoding data
- Querying too many dates at once causes crashes (900+ date predicates crash)
- No pagination built into HealthKit queries

**Consequences:**
- App appears frozen on launch
- Memory pressure on older devices
- Poor UX forcing users to wait

**Prevention:**
- Query in date-range chunks (e.g., 30-day windows)
- Use HKStatisticsCollectionQuery with lower resolution (hourly vs minute)
- Implement progressive loading: show recent data first, load older on scroll
- Cache results locally; don't re-query every launch
- Use background task for initial historical data import

**Warning signs:**
- Instruments shows NSXPCDecoder taking >50% time
- Launch takes >3 seconds on first run
- Memory spikes when querying

**Phase:** Foundation (Data Layer) - Chunked querying must be implemented early.

---

### 5. Data Source Attribution Ambiguity

**What goes wrong:** Cannot reliably determine if rhythm data came from Apple Watch ECG vs PPG vs manual entry.

**Why it happens:**
- HealthKit stores all rhythm data with same HKHeartbeatSeriesSample type
- No metadata distinguishing ECG (single-lead) from optical sensor
- Multiple sources can write similar data types

**Consequences:**
- Cannot accurately show "ECG reading" vs "pulse check"
- May display confidence levels that aren't actually different
- User confusion about data quality

**Prevention:**
- Don't make claims about data source quality in UI
- Treat all rhythm data as equivalent
- If needed, query by source: predicateForObjects(from: sources)
- Accept that precise attribution isn't possible

**Phase:** Foundation - This affects what metrics can be displayed.

---

## Moderate Pitfalls

### 6. One-Way Permission Model

**What goes wrong:** Users cannot revoke HealthKit permissions in-app; only via iOS Settings.

**Why it happens:**
- iOS doesn't allow apps to modify HealthKit authorization
- If user denies permission, only system Settings can fix it

**Consequences:**
- Poor UX when permission accidentally denied
- Support burden increases
- Users may uninstall rather than navigate Settings

**Prevention:**
- Check HKHealthStore.authorizationStatus(for:) on each launch
- Guide users to Settings with clear instructions when denied
- Store user preference for "don't ask again" in UserDefaults
- Handle authorization errors gracefully

**Phase:** Foundation - Onboarding must handle permission flow edge cases.

---

### 7. ECG Voltage Data Handling Crashes

**What goes wrong:** Retrieving ECG voltage data causes app crashes.

**Why it happens:**
- HKElectrocardiogramQuery requires specific async handling
- Memory-intensive for large ECG recordings
- Some third-party libraries have bugs with voltage retrieval

**Consequences:**
- App crashes when accessing ECG detail view
- Bad App Store reviews

**Prevention:**
- Test ECG retrieval extensively on real devices
- Handle async results properly with completion handlers
- Consider deferring ECG voltage display (just show classification)
- Use Apple's sample code directly

**Warning signs:**
- Memory warnings when loading ECG
- Crash reports in TestFlight

**Phase:** Data Layer (if ECG detail implemented)

---

### 8. Third-Party Data Quality Inconsistencies

**What goes wrong:** Data from other apps (Garmin, Fitbit) mixed with Apple Watch causes duplicates or conflicts.

**Why it happens:**
- Different apps write similar data types differently
- Garmin Connect removes and re-adds step data instead of updating
- Some sources use different units or time zones

**Consequences:**
- Duplicate episodes in timeline
- Incorrect AF burden calculations
- Confusing data for users

**Prevention:**
- Filter by source: only show Apple Watch data initially
- If aggregating, implement deduplication logic in-app
- Use HKSourceQuery to identify data sources
- Consider limiting to "most recent" source per time window

**Phase:** Foundation - Source filtering should be early architecture decision.

---

### 9. Sleep vs Bedtime Confusion

**What goes wrong:** Heart rate data during sleep shows unexpected gaps or patterns.

**Why it happens:**
- Apple Watch tracks "in bed time" separately from actual sleep
- Sleep stages (iOS 16+) add complexity
- iPhone tracks bedtime, not actual sleep
- Manual entry differs from device data

**Consequences:**
- Timeline shows periods as "awake" when user was sleeping
- AF burden calculations may be wrong for overnight periods

**Prevention:**
- Don't make assumptions about overnight data
- Show sleep window boundaries in timeline
- Consider excluding "in bed but awake" from overnight analysis

**Phase:** Visualization (if overnight analysis is feature)

---

### 10. User Expectation: Continuous Monitoring

**What goes wrong:** Users expect real-time heart monitoring like hospital equipment.

**Why it happens:**
- Apple Watch marketing emphasizes "heart health"
- Users don't understand difference between PPG and ECG
- "Irregular rhythm notification" sounds like continuous watch

**Consequences:**
- Disappointment when app shows limited data
- Users may disable Apple Watch features expecting "more"
- Complaints about gaps between readings

**Prevention:**
- Clear onboarding explaining what Apple Watch actually measures
- Show data collection frequency (e.g., "12 readings in last 7 days")
- Educational content about opportunistic monitoring
- Set expectations: "Your Apple Watch checks periodically, not continuously"

**Phase:** Onboarding + UI Design - This is user education, not technical.

---

## Minor Pitfalls

### 11. Keychain Anchor Storage Complexity

**What goes wrong:** Storing HKQueryAnchor for incremental sync is complex and error-prone.

**Why it happens:**
- Anchors are per-sample-type, not universal
- Must serialize with NSKeyedArchiver
- Keychain has size limits

**Prevention:**
- Don't implement incremental sync initially; re-query on launch
- Only add if performance becomes issue
- Use anchor per HKSampleType, not one for all

**Phase:** Foundation (if early performance issue emerges)

---

### 12. Simulator vs Real Device Data Differences

**What goes wrong:** Health data added via Apple Health app simulator differs from real Apple Watch data.

**Why it happens:**
- Manual entry in Health app lacks device metadata
- Real Apple Watch data has source attribution
- Debugging with simulator produces unrepresentative results

**Prevention:**
- Always test with real device and real Apple Watch
- Use real device for QA, not just simulator
- Understand simulator limitations for health data

**Phase:** Testing - This is a QA/process issue, not architecture.

---

## Phase-Specific Warnings

| Phase | Likely Pitfall | Mitigation |
|-------|---------------|------------|
| Foundation (Data) | #1, #2, #4, #5, #6 | Design data layer around limitations from start |
| Onboarding | #3, #10 | Build disclaimers and education into flow first |
| Visualization | #9 | Handle edge cases in timeline rendering |
| Reports | #8 | Filter sources carefully for clinical reports |
| Testing | #12 | Mandate real device testing |

---

## Sources

| Source | Confidence | Relevance |
|--------|------------|-----------|
| Apple Developer Forums (HKObserverQuery issues) | HIGH | Background delivery problems |
| Beda Software: Apple HealthKit Pitfalls | MEDIUM | FHIR, aggregation, source issues |
| MobilePeople: Mastering HealthKit (Medium) | MEDIUM | Query performance, anchoring |
| Apple Developer Forums (HKStatisticsCollectionQuery slow) | HIGH | Performance benchmarks |
| FDA Apple AFib History MDDT qualification | HIGH | Regulatory context |
| JACC: Apple Watch ECG Meta-Analysis | HIGH | Data reliability context |
| Stack Overflow: ECG voltage crash | MEDIUM | Technical crash detail |

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| HealthKit technical pitfalls | HIGH | Multiple documented sources, Apple forums |
| Background delivery issues | HIGH | Well-documented in forums |
| Regulatory boundaries | HIGH | FDA documentation clear |
| Performance characteristics | MEDIUM | Device-dependent, but general patterns known |
| ECG crash specifics | MEDIUM | Limited reports, specific to libraries |
| User behavior/expectations | MEDIUM | General mobile health app patterns |

---

## Open Questions

- How aggressively can we cache HealthKit data locally without violating privacy constraints?
- What's realistic AF burden calculation accuracy with opportunistic sampling?
- Should we attempt background refresh or rely on foreground-only?
