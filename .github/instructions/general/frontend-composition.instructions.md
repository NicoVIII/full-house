---
description: "Use when creating or refactoring frontend TypeScript/TSX modules. Keep UI and state logic in small, composable units instead of large page files."
applyTo: "client-web/src/**/*.ts, client-web/src/**/*.tsx"
---

# Frontend Composition First

[Hard Rule] - enforcement

Prefer small, focused components/hooks over monolithic page files.

## Rules

- Pages should compose route-level pieces, not implement all logic inline.
- Extract reusable behavior into hooks.
- Extract reusable UI sections into components.
- Keep module names intent-based; avoid generic `utils`/`helpers` catch-alls.
- Keep feature-specific pieces near usage; move to shared only after real reuse.

## Split Heuristics

Split when a file has multiple concerns (for example scan logic + data orchestration + dense UI), hard-to-scan render branches, or recurring cross-cutting edits.

## Review Checklist

1. Does this module have one clear responsibility?
2. Is the page mostly composition/wiring?
3. Are reusable behaviors/views extracted with clear names?
