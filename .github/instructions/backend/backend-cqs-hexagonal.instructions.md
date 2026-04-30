---
description: "Use when implementing or refactoring backend Gleam modules with hexagonal architecture and CQS. Keep domain pure, place outbound ports in application/ports, and separate command and query use cases."
applyTo: "backend/src/**/*.gleam"
---
# Backend CQS And Hexagonal Architecture

[Hard Rule] - enforcement

Enforce CQS and hexagonal boundaries in backend code.

- Keep domain modules pure: no HTTP, persistence, or infrastructure concerns in `domain/**`.
- Define outbound ports in `application/ports/**` as abstractions owned by the application.
- Implement outbound adapters in `infrastructure/**`.
- Implement inbound adapters in `driver/**` (for example HTTP handlers and routers).
- Keep business rule decisions in `domain/**` and `application/**`. Infrastructure may provide facts, persist state, and enforce technical safeguards, but it must not become the primary home of business-policy branching.
- When an invariant depends on data owned by infrastructure, prefer this shape: infrastructure returns facts through ports, application/domain decides, infrastructure executes the command. Database constraints and external safeguards are a backstop for races and misconfiguration, not the canonical rule definition.
- Treat each use case as either command or query, never both.
- Query use cases return read models; command use cases perform state changes and return command results.
- Do not place query/pagination transport metadata in domain entities unless it is domain-significant.
- Place query/read models outside domain. They may live in `application/**` or `driver/**` depending on context.
- Compose dependencies in a dedicated composition root (for example `src/full_house.gleam` or `src/composition/**`).
- Dependency wiring can be global (application-wide composition root) or route-local (per-route composition), but it always happens in the composition root—not in `driver/**` or elsewhere. Route-local wiring means each route can construct its own dependencies instead of sharing a single global composition.
- Import/dependency direction is defined in `backend-layer-imports.instructions.md`.
- For layer structure and directory organization guidelines, see `backend-layer-structure.instructions.md`.

## Review Checklist

1. Is this module clearly command or query oriented?
2. Are domain types free of adapter and transport details?
3. Are ports defined under `application/ports/**` and implemented in `infrastructure/**`?
4. Does `driver/**` only translate protocol concerns (HTTP/query params/status/JSON) and delegate business work?
5. If infrastructure returns a business-shaped error, is it only reporting a guardrail outcome rather than originating the business rule itself?
5. Is dependency wiring kept in the composition root and scoped per route when needed?
6. Are import/dependency rules compliant with `backend-layer-imports.instructions.md`?
