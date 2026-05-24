---
description: "Use when implementing or refactoring backend Gleam modules with hexagonal architecture and CQS. Keep domain pure, define outbound ports in application modules, and separate command and query use cases."
applyTo: "server/src/**/*.gleam"
---

# Backend CQS + Hexagonal

[Hard Rule] - enforcement

Preserve hexagonal boundaries and keep each use case either command or query.

## Rules

- `domain/**` is pure: no driver/infrastructure concerns.
- Define outbound ports in `application/**`; implement them in `infrastructure/**`.
- Keep inbound adapters in `driver/**` (protocol translation only).
- Command use cases mutate state; query use cases return read models.
- Wire dependencies only in composition root (`full_house.gleam` or `composition/**`).
- Follow dependency direction from `backend-layer-imports.instructions.md`.

## Review Checklist

1. Is the module clearly command or query?
2. Are domain types free of transport/adapter details?
3. Are ports in application and adapters in infrastructure?
4. Is wiring done only in composition root?
