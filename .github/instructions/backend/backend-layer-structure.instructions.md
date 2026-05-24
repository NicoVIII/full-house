---
description: "Use when organizing code within hexagonal architecture layers. Organize by business feature or domain concern, not by technical type."
applyTo: "server/src/**/*.gleam"
---

# Backend Layer Structure

[Guidance]

Organize by feature/domain concern first, technical type second.

## Rules

- Keep layer intent clear:
  - `domain/**`: entities, value objects, invariants
  - `application/**`: use cases and outbound ports
  - `driver/**`: inbound adapters
  - `infrastructure/**`: outbound adapters
  - composition root: wiring only
- Prefer feature folders (`products`, `stock`) over generic technical buckets.
- Keep related operation files close together.
- Start simple; introduce subfolders only when complexity warrants it.

## Review Checklist

1. Can a new reader find feature code quickly?
2. Are related files colocated by feature/operation?
3. Is nesting shallow and justified?
