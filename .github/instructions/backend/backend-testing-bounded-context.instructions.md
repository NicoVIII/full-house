---
description: "Use when adding or changing backend bounded-context integration tests in the driver layer. Keep them operation-scoped, concise, and discoverable."
applyTo: "server/test/integration/driver/**/*.gleam"
---
# Backend Bounded Context Integration Tests

[Hard Rule] - enforcement

- Test one full flow from inbound driver to outbound application port boundary.
- Execute through `driver/**`, `application/**`, and `domain/**` in one test.
- Mock only outbound application ports.
- Do not bypass driver handlers.

## Structure

- Organize by bounded context and operation.
- Prefer one operation per file (`list_test.gleam`, `get_test.gleam`, `create_test.gleam`, `delete_test.gleam`).
- Avoid catch-all route test modules when operation files exist.
- Extract repeated setup into local `testsetup.gleam` or `common.gleam` helpers.

## Naming

- Use `<operation>_<scenario>_<outcome>_test`.
- Avoid generic names like `success_test` and `error_test`.

## Minimum Scenario Coverage

- At least one happy-path test per operation.
- At least one meaningful failure-path test per operation.

## Review Checklist

1. Is the full driver -> application -> domain flow tested in one go?
2. Are outbound dependencies mocked only at port boundaries?
3. Is the file operation-scoped and easy to find?
4. Are test names intention-revealing?
5. Does the operation include both happy and failure-path coverage?
