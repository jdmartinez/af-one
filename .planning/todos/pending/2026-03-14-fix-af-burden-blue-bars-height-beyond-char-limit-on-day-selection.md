---
created: 2026-03-14T14:00:39.671Z
title: Fix AF Burden blue bars height beyond char limit on Day selection
area: ui
files: []
---

## Problem

When selecting "Day" time range on the AF Burden dashboard card, the blue bars (representing data) render with heights that exceed the visible character/text limit area. This causes the bars to overflow or be cut off, making the visualization difficult to read. The chart scaling appears to be incorrect for the Day view specifically.

## Solution

TBD - Investigate AF Burden chart rendering:
- Check the Day view data scaling logic
- Review how bar heights are calculated relative to the available space
- Verify character/label bounds are being respected
- Consider using dynamic scaling based on max value in Day range
