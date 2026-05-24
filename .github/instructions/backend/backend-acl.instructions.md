---
description: "Use when implementing backend Gleam boundaries between driver and application, or application and infrastructure. Enforce anti-corruption layers (ACLs) so external layer models do not leak across boundaries."
applyTo: "server/src/**/*.gleam"
---

# Backend ACL

[Hard Rule] - enforcement

Translate models at every backend boundary. Never leak transport or infrastructure shapes into application/domain types.

## Rules

- `driver/**` <-> `application/**`: map request/response DTOs to use-case models.
- `application/**` <-> `infrastructure/**`: map port models to persistence/external models.
- Keep mappers explicit and small; avoid ad-hoc inline conversions in unrelated code.
- Infrastructure outcomes stay technical at the port boundary; business meaning is decided in application/domain.

## Mapper Placement

- Inline private helper: simple, single-use mapper.
- Separate mapper module: reused or complex mapper.

## Review Checklist

1. Are boundary models mapped explicitly?
2. Are application/domain types independent from HTTP/DB shapes?
3. Are business decisions kept out of infrastructure mapping?
