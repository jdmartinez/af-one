---
created: 2026-03-14T15:00:17.184Z
title: Fix tab bar scroll collapse not working
area: ui
files:
  - AFOne/Shared/Components/GlassBottomBar.swift
---

## Problem

The GlassBottomBar tab bar is displaying as always fixed at the bottom. The collapse/expand effect based on scroll position is not working - the tab bar remains visible regardless of scroll offset.

The implementation includes ScrollOffsetKey preference key and collapse/expand animations, but the behavior is not being triggered when the user scrolls through content.

## Solution

TBD - Investigate why scroll-based visibility toggle isn't working:
- Check if ScrollOffsetKey is properly propagating from scrollable views
- Verify the animation triggers are correctly tied to the scroll offset thresholds
- Test with different scrollable content to isolate the issue