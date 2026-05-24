---
description: "Use when implementing error handling, input validation, or fallback logic in any Gleam or TypeScript code. Ensure invalid inputs and failures are surfaced, not silently absorbed."
applyTo: "server/**/*.gleam, client-web/src/**/*.ts, client-web/src/**/*.tsx"
---

# Predictable Behavior

[Hard Rule] - enforcement

Do not silently correct invalid input or swallow failures.

## Rules

- Distinguish absence from invalid input:
  - absent + documented default: allowed
  - invalid provided value: return/report explicit error
- Backend: map invalid request input to `400`; propagate typed failures to appropriate `404`/`409`/`500`.
- Frontend: surface request and validation errors in UI; do not present failure as success.
- For `500`, return safe generic messages (no internals).

## Review Checklist

1. Is invalid input rejected explicitly?
2. Are failures propagated instead of hidden?
3. Can consumers clearly tell whether input was accepted?
