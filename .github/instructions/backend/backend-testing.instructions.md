---
description: "Use when implementing or changing backend Gleam features. Prefer strong endpoint integration coverage and focused infrastructure adapter tests (unit or focused integration)."
applyTo: "backend/src/**/*.gleam, backend/test/**/*.gleam"
---
# Backend Testing Strategy

[Strong Preference]

Aim for broad and meaningful backend test coverage, with explicit and documented exceptions when justified.
- Most backend behavior should be covered by automated tests.
- Endpoint behavior should be covered by integration tests.
- Endpoint integration tests should exercise the request flow through `driver/**`, `application/**`, and `domain/**` up to outbound application port boundaries.
- Endpoint integration tests should stop at the outbound port boundary and use test doubles for outbound dependencies.
- Integration tests should assert protocol-level behavior (status codes, response payloads, pagination/error handling where relevant).
- Endpoint integration tests should not be happy-path-only. Cover invalid-input and failure/edge paths where they matter for the endpoint contract.
- Infrastructure adapters in `infrastructure/**` should have focused coverage for mapping, edge cases, and error paths.
- For SQL adapters, focused integration tests against a test database are acceptable and often preferable to brittle mocks.
- Use the Arrange-Act-Assert (AAA) pattern where applicable to keep tests concise and readable.
- Keep AAA sections lightweight: only split steps that improve clarity.
- Prefer deterministic tests (fixed test data, stable assertions, minimal hidden global state).
- If test coverage is intentionally omitted, document the reason in the PR/task.

## Infrastructure Implementations For Testing

When organizing infrastructure adapters (see `backend-layer-structure.instructions.md`), prefer test seams that keep endpoint tests fast and deterministic while preserving realistic adapter behavior:

- Port-level test doubles are useful for endpoint integration tests that intentionally stop at outbound boundaries.
- Real adapters can be exercised directly in focused integration tests (for example against an isolated test database) to validate SQL and decoding behavior.
- Choose the lightest setup that still verifies the behavior you care about.

## Test Organization

1. Endpoint integration tests under `backend/test/integration/**`
2. Domain unit/property tests under `backend/test/unit/domain/**`
3. Focused infrastructure adapter tests under `backend/test/integration/infrastructure/**` or `backend/test/unit/infrastructure/**` depending on test style

## Review Checklist

1. Does each changed/new endpoint have meaningful integration test coverage?
2. Do endpoint tests cover happy path and key error/edge cases?
3. Does each changed/new infrastructure adapter have focused coverage (unit or focused integration)?
4. Do tests follow AAA structure where it improves readability?
5. Are tests deterministic and easy to understand?
