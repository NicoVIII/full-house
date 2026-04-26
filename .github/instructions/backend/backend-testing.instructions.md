---
description: "Use when implementing or changing backend Gleam features. Ensure strong test coverage: integration tests for endpoints across driver/application/domain/ports boundaries, and unit tests for infrastructure adapters."
applyTo: "backend/src/**/*.gleam, backend/test/**/*.gleam"
---
# Backend Testing Strategy

[Strong Preference] - enforcement

Aim for broad and meaningful backend test coverage, with explicit and documented exceptions when justified.
- Most backend behavior should be covered by automated tests.
- Every endpoint must have integration tests.
- Endpoint integration tests should exercise the request flow through `driver/**`, `application/**`, and `domain/**` up to outbound `application/ports/**` boundaries.
- Endpoint integration tests should stop at the outbound port boundary and use test doubles for outbound dependencies.
- Integration tests should assert protocol-level behavior (status codes, response payloads, pagination/error handling where relevant).
- Endpoint integration tests must not be happy-path-only. Cover at least one invalid-input path and one failure/edge path for each endpoint when applicable.
- Infrastructure adapters in `infrastructure/**` must have focused unit tests.
- Infrastructure unit tests should verify adapter behavior in isolation (mapping, edge cases, error paths) without relying on full endpoint flows.
- Use the Arrange-Act-Assert (AAA) pattern where applicable to keep tests concise and readable.
- Keep AAA sections lightweight: only split steps that improve clarity.
- Prefer deterministic tests (fixed test data, stable assertions, minimal hidden global state).
- If test coverage is intentionally omitted, document the reason in the PR/task.

## Infrastructure Implementations for Testing

When organizing infrastructure adapters (see `backend-layer-structure.instructions.md`), use mock implementations for integration tests and real implementations for other environments:

- **Mock implementations** (e.g., `mock_product_repository.gleam`): Used in integration tests and development. Mock adapters are test doubles that implement the port interface with hardcoded/in-memory data.
- **Real implementations** (e.g., `postgres_product_repository.gleam`): Used in production and acceptance tests. Real adapters connect to actual external services (databases, APIs).
- **Test organization**: Place both implementations in the same folder (e.g., `infrastructure/product_repository/`) and wire them in the composition root based on environment.

## Test Organization

1. Endpoint integration tests under `backend/test/integration/**`
2. Infrastructure unit tests under `backend/test/unit/infrastructure/**`
3. Mock adapters colocated with real adapters under `infrastructure/[resource]/`

## Review Checklist

1. Does each changed/new endpoint have integration test coverage?
2. Do integration tests cover happy path and key error/edge cases?
3. Does each changed/new infrastructure adapter have unit tests?
4. Do tests follow AAA structure where it improves readability?
5. Are tests deterministic and easy to understand?
