---
description: "Use when implementing or changing backend Gleam features. Enforce bounded-context integration tests, real-infrastructure adapter tests, and critical-path unit tests."
applyTo: "server/src/**/*.gleam, server/test/**/*.gleam"
---
# Backend Testing Strategy

[Hard Rule] - enforcement

Keep test categories separate.

- Bounded-context integration tests: validate flow from `driver/**` through `application/**` and `domain/**` to outbound application port boundaries.
- Infrastructure adapter tests: validate concrete adapters with real infrastructure.
- Unit tests: validate critical business/domain rules in isolation.

[Strong Preference]

- Most backend behavior should be covered by automated tests.
- Bounded-context integration tests should include happy-path and meaningful failure-path coverage.
- Integration tests should assert protocol-level behavior.
- Infrastructure adapter tests should cover mapping, edge cases, and error paths against real infrastructure.
- Use AAA and deterministic test data.
- If coverage is intentionally omitted, document why in the PR/task.

## Boundary Rules

- In bounded-context integration tests, mock only at outbound port boundaries.
- Do not mock infrastructure internals in infrastructure adapter tests.
- Keep critical rule validation in unit tests when behavior is isolatable.

## Test Organization

1. Bounded-context integration tests under `server/test/integration/driver/**`
2. Infrastructure adapter tests under `server/test/integration/infrastructure/**`
3. Domain/unit/property tests for critical paths under `server/test/unit/domain/**`
4. Prefer operation-scoped files and intention-revealing test names.

## Review Checklist

1. Does each changed/new bounded-context operation have end-to-end integration coverage from driver to outbound port boundary?
2. Do bounded-context integration tests cover happy path and key failure/edge cases?
3. Does each changed/new infrastructure adapter have dedicated coverage with real infrastructure?
4. Do critical business/domain paths have focused unit tests?
5. Are tests deterministic and readable (AAA where useful)?
