---
description: "Use when adding or reviewing imports in backend Gleam files. Enforce allowed and forbidden layer dependencies for domain, application, infrastructure, and driver."
applyTo: "backend/src/**/*.gleam"
---

# Backend Layer Import Rules

[Hard Rule] - enforcement

Follow one-way dependency direction across layers.

## Allowed Dependencies By Layer

- `domain/**`: `domain/**`, `gleam/**`, pure external libs
- `application/**`: `application/**`, `domain/**`, `gleam/**`
- `infrastructure/**`: `infrastructure/**`, `application/**`, `domain/**`, `gleam/**`
- `driver/**`: `driver/**`, `application/**`, `domain/**`, `gleam/**`
- Composition root (`full_house.gleam` or `composition/**`): may import all layers, but wiring only

## Forbidden Dependencies

- `domain/**` must not import `application/**`, `infrastructure/**`, or `driver/**`
- `application/**` must not import `infrastructure/**` or `driver/**`
- `driver/**` must not import `infrastructure/**`
- `infrastructure/**` must not import `driver/**`

## Review Checklist

1. Can this file still compile conceptually if adapters are swapped?
2. Does dependency direction still point inward toward domain/application?
3. Is composition root doing wiring only, not business logic?
