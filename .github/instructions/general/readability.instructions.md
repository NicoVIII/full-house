---
description: "Use when writing, reviewing, or refactoring backend Gleam or frontend TypeScript code. Prefer code that is both readable and concise; when those goals pull apart, keep the version that preserves clarity fastest."
applyTo: "server/**/*.gleam, client-web/src/**/*.ts, client-web/src/**/*.tsx"
---

# Readability First

[Hard Rule] - enforcement

Choose clarity over cleverness; remove noise without hiding intent.

## Rules

- Keep names and module purpose obvious.
- Keep control flow easy to scan top-to-bottom.
- Keep definitions ordered before use where practical.
- Prefer self-explanatory code; comment only for non-obvious intent/trade-offs.
- Preserve boundaries, validation, and explicit error handling while simplifying.
- For frontend decomposition decisions, follow `frontend-composition.instructions.md`.

## Review Checklist

1. Is intent obvious on first read?
2. Is complexity justified and localized?
3. Was conciseness achieved without reducing clarity?
