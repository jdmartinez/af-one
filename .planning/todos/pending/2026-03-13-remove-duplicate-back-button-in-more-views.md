---
created: 2026-03-13T14:36:36.035Z
title: Remove duplicate back button in More views
area: ui
files: []
---

## Problem

In "More > Emergency Information" and "More > Clinical Report" views, an additional back button is shown. This appears to be a navigation redundancy where a back button is rendered when it shouldn't be (possibly because these views are being presented in a navigation stack that already provides back navigation).

## Solution

TBD - Investigate the navigation structure in MoreView.swift and ReportView.swift to understand why the duplicate back button appears. May need to conditionally hide the back button or adjust how these views are presented.
