---
description: "Use when organizing code within hexagonal architecture layers. Organize by business feature or domain concern, not by technical type."
applyTo: "backend/src/**/*.gleam"
---

# Backend Layer Structure

[Guidance] - enforcement

Prefer feature-oriented folders (what the code does) over technical buckets (what kind of file it is).

## Core Intent By Layer

1. `domain/**`: entities, value objects, invariants
2. `application/**`: use cases and outbound ports
3. `driver/**`: inbound adapters (HTTP, CLI, etc.)
4. `infrastructure/**`: outbound adapter implementations
5. Composition root (`full_house.gleam` or `composition/**`): wiring only

## Structure Rules

- Start simple: use single files first; introduce folders when complexity requires it
- Group by feature/resource (`products`, `stock`, `orders`) inside each layer
- Keep related handler/mapper/adapter files close together
- Keep nesting shallow and intentional (typically 2-3 levels)
- Keep outbound ports in `application/ports/**`

## Minimal Example

```text
application/
  list_products.gleam
  ports/product_repository.gleam

driver/http/products/
  handler.gleam
  response_mapper.gleam

infrastructure/product_repository/
  mock_product_repository.gleam
  postgres_product_repository.gleam
```

## Review Checklist

1. Can a new developer identify features from folder names alone?
2. Are related files colocated by feature/resource?
3. Is nesting reasonable for the current complexity?
4. Are ports in `application/ports/**` and adapters in `infrastructure/**`?
