---
description: "Use when organizing code within hexagonal architecture layers. Organize by business feature or domain concern, not by technical type."
applyTo: "backend/src/**/*.gleam"
---

# Backend Layer Structure

[Guidance]

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
- When one resource contains multiple distinct operations with their own files, prefer operation subfolders such as `products/create/` or `products/list/` over a flat folder of operation-prefixed files
- Keep nesting shallow and intentional (typically 2-3 levels)
- Keep outbound port abstractions in `application/**` (either colocated in the use-case module or extracted to a dedicated application module when shared)

## Minimal Example

```text
application/
  commands/
    create_product.gleam
  queries/
    list_products.gleam

driver/http/products/
  list/
    handler.gleam
    response_mapper.gleam
  create/
    handler.gleam
    request_mapper.gleam
    response_mapper.gleam

infrastructure/adapter/
  commands/create_product/create_adapter.gleam
  queries/list_products/list_products_adapter.gleam
```

## Review Checklist

1. Can a new developer identify features from folder names alone?
2. Are related files colocated by feature/resource?
3. Is nesting reasonable for the current complexity?
4. Are outbound ports defined in `application/**` and adapters in `infrastructure/**`?
