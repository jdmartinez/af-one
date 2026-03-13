---
status: testing
phase: 02-user-input-analysis
source: 02-01-SUMMARY.md, 02-02-SUMMARY.md, 02-03-SUMMARY.md, 02-04-SUMMARY.md, 02-05-SUMMARY.md, 02-06-SUMMARY.md
started: 2026-03-13T12:00:00Z
updated: 2026-03-13T12:50:00Z
---

## Current Test

number: 6
name: Health Notifications
expected: |
  App checks for health events on foreground. If episode > 1 hour or AF burden increased >10% from previous week, notification is triggered. Notification permission requested on first launch.
awaiting: user response

## Tests

### 1. SwiftData Models Persistence
expected: SymptomLog and TriggerLog models persist data locally. Selecting "palpitations" as symptom or "alcohol" as trigger and saving persists the entry across app restarts.
result: pass
notes: App does not crash on save/reopen. Data persists. UI issue: Dashboard metric cards not rendering borders properly.

### 2. Log View Bottom Sheet with FAB
expected: Dashboard shows FAB (floating action button) in bottom-right. Tapping it opens bottom sheet with symptom chips (multi-select) and trigger chips (single-select), plus optional notes field and Save/Cancel buttons.
result: pass

### 3. AF Burden Chart with Period Selector
expected: Dashboard shows AF burden section with segmented picker (Day/Week/Month). Selecting "Day" shows hourly bars, "Week" shows daily trend line, "Month" shows daily trend line. Trend indicator shows increasing/decreasing/stable.
result: issue
reported: "When selecting Day, blue bars occupy all height and go beyond borders"
severity: minor

### 4. Analysis View with Tabs
expected: TabView shows Analysis tab (5th position). Tapping it shows three tabs: Symptoms, Triggers, Heart Rate. Each tab displays correlation insights from logged data.
result: pass
notes: Fixed - AuthorizationView now shows on first launch, HealthKit auth works

### 5. Medications View
expected: Medications tab shows list of medications from Apple Health (iOS 18+). Empty state displays when no medications recorded. Tab accessible from main navigation.
result: pass

### 6. Health Notifications
expected: App checks for health events on foreground. If episode > 1 hour or AF burden increased >10% from previous week, notification is triggered. Notification permission requested on first launch.
result: skipped
notes: Cannot verify without real Apple Watch data on device

### 3. AF Burden Chart with Period Selector
expected: Dashboard shows AF burden section with segmented picker (Day/Week/Month). Selecting "Day" shows hourly bars, "Week" shows daily trend line, "Month" shows daily trend line. Trend indicator shows increasing/decreasing/stable.
result: [pending]

### 4. Analysis View with Tabs
expected: TabView shows Analysis tab (5th position). Tapping it shows three tabs: Symptoms, Triggers, Heart Rate. Each tab displays correlation insights from logged data.
result: [pending]

### 5. Medications View
expected: Medications tab shows list of medications from Apple Health (iOS 18+). Empty state displays when no medications recorded. Tab accessible from main navigation.
result: [pending]

### 6. Health Notifications
expected: App checks for health events on foreground. If episode > 1 hour or AF burden increased >10% from previous week, notification is triggered. Notification permission requested on first launch.
result: [pending]

## Summary

total: 6
passed: 4
issues: 1
pending: 0
skipped: 1

## Gaps

- truth: "AF Burden chart displays correctly with proper bar heights within borders"
  status: failed
  reason: "When selecting Day, blue bars occupy all height and go beyond borders"
  severity: minor
  test: 3