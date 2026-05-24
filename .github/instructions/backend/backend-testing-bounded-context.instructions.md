---
description: "Use when adding or changing backend bounded-context integration tests in the driver layer. Keep them operation-scoped, concise, and discoverable."
applyTo: "server/test/integration/driver/**/*.gleam"
---

# Backend Bounded-Context Integration Tests

[Hard Rule] - enforcement

Test one operation flow from inbound driver through application/domain to outbound port boundary.

## Rules

- Execute through `driver/**`, `application/**`, and `domain/**`.
- Mock only outbound application ports.
- Do not bypass driver handlers.
- Keep tests operation-scoped (for example `get_test.gleam`, `create_test.gleam`).
- Name tests `<operation>_<scenario>_<outcome>_test`.
- Cover at least one happy path and one meaningful failure path per operation.

## Review Checklist

1. Is full flow covered in one go?
2. Are mocks limited to outbound ports?
3. Is the test file operation-scoped and discoverable?
