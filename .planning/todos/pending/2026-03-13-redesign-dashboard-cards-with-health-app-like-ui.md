---
created: 2026-03-13T13:07:43.647Z
title: Redesign dashboard cards with Health app-like UI
area: ui
files:
  - AFOne/Features/Dashboard/DashboardView.swift:234-269
---

## Problem

Dashboard metric cards (AF Burden, Episodes, Avg HR) don't look like Apple Health app cards. Issues observed:
- Card borders not rendering properly
- No icons or colored titles
- AF Burden time range selector should be in a dedicated view at top of its card

## Solution

TBD - Review Health app design patterns and implement:
- Use Health app-style card layout with icons and colored titles
- Fix card border rendering issues
- Move period picker inside AF Burden card header
- Use semantic colors (green for normal, red for alerts, etc.)
