---
description: "Use when implementing error handling, input validation, or fallback logic in any Gleam or TypeScript code. Ensure invalid inputs and failures are surfaced, not silently absorbed."
applyTo: "backend/**/*.gleam, webfrontend/src/**/*.ts, webfrontend/src/**/*.tsx"
---

# Predictable Behavior

[Hard Rule] - enforcement

Callers must never be surprised by silent correction or swallowed failures.

## Absence vs Invalid Input

- Absent parameter: documented default is acceptable
- Invalid provided parameter: return an explicit error

Never silently treat invalid input as a valid default.

## Backend Rules

- HTTP driver layer: invalid request input -> `400 Bad Request` with actionable error message
- Domain/application layers: propagate failures as `Result`, do not silently replace errors with fallbacks
- Infrastructure failures: propagate to driver layer; map typed errors to suitable status codes (`404`, `409`, `500`)
- For `500`, return a generic safe message (no internal leakage)

## Frontend Rules

- Surface request failures to users (message/toast/error UI)
- Do not silently show empty/cached data as if request succeeded
- Show inline validation feedback for invalid user input

## Silent Default Exception (All Required)

1. Input was absent (not invalid)
2. Default is documented
3. Caller cannot reasonably be surprised by the defaulted result

## Review Checklist

1. Does each fallback distinguish absence from invalid input?
2. Are invalid caller inputs rejected with clear feedback?
3. Are infrastructure/application errors propagated instead of swallowed?
4. Would an API/UI consumer understand whether their input was accepted?
