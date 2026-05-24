---
description: "Use when adding or reviewing imports in backend Gleam files. Enforce allowed and forbidden layer dependencies for domain, application, infrastructure, and driver."
applyTo: "server/src/**/*.gleam"
---

# Backend Layer Import Rules

[Hard Rule] - enforcement

Keep dependencies one-way toward domain/application.

## Allowed

- `domain/**` -> `domain/**`, stdlib/external pure libs
- `application/**` -> `application/**`, `domain/**`
- `infrastructure/**` -> `infrastructure/**`, `application/**`, `domain/**`
- `driver/**` -> `driver/**`, `application/**`, `domain/**`
- Composition root -> all layers (wiring only)

## Forbidden

- `domain/**` -> `application/**`, `infrastructure/**`, `driver/**`
- `application/**` -> `infrastructure/**`, `driver/**`
- `driver/**` -> `infrastructure/**`
- `infrastructure/**` -> `driver/**`

## Review Checklist

1. Does dependency direction still point inward?
2. Is composition root only wiring, not business logic?
