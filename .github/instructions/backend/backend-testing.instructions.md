---
description: "Use when implementing or changing backend Gleam features. Enforce bounded-context integration tests, real-infrastructure adapter tests, and critical-path unit tests."
applyTo: "server/src/**/*.gleam, server/test/**/*.gleam"
---

# Backend Testing Strategy

[Hard Rule] - enforcement

Keep responsibilities clear across integration, adapter, and unit tests.

## Required Coverage

- Bounded-context integration tests for changed driver operations.
- Infrastructure adapter tests against real infrastructure for changed adapters.
- Focused unit tests for critical domain/business rules.

## Rules

- Bounded-context integration tests: mock only outbound application ports.
- Infrastructure adapter tests: do not mock infrastructure internals.
- Tests should be deterministic and readable (AAA preferred).

## Review Checklist

1. Are changed operations covered end-to-end to outbound ports?
2. Are changed adapters covered with real infrastructure?
3. Are critical business rules covered by focused unit tests?
