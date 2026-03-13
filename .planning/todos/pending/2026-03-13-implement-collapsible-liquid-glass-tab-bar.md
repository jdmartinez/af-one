---
created: 2026-03-13T14:38:15.447Z
title: Implement collapsible Liquid Glass tab bar
area: ui
files: []
---

## Problem

The navigation tab bar doesn't match iOS 26+ Liquid Glass design. Currently it shows all tabs at once. Should be a collapsible navigation bar that defaults to collapsed showing only the Dashboard button, and expands to reveal all navigation options when tapped.

## Solution

TBD - Implement collapsible Liquid Glass navigation:
- Default collapsed state: Show only Dashboard button (center or prominent)
- Expanded state: Show all tab options (Dashboard, Log, Trends, Analysis, More)
- Use iOS 26 Liquid Glass material/glass effect for the bar
- Animate transition between collapsed and expanded states
- Consider using SwiftUI's .glassEffect() or similar APIs
