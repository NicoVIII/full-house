---
description: "Use when creating or reviewing modules in the backend. Keep modules focused on a single concept or responsibility. Split modules that cover multiple separable concerns."
applyTo: "backend/src/**/*.gleam"
---

# Concise, Focused Modules

[Hard Rule] - enforcement

Each module should encapsulate exactly one concept or responsibility. If a module covers two separable concerns, split it into two modules.

## Principle

A module's name should fully describe its contents. If you need "and" to describe what a module does, it likely needs splitting.

- **Good**: `page_limit.gleam` — one concept, one type, one set of related functions
- **Bad**: `pagination.gleam` — mixes `Limit` and `Offset`, two separable value objects

## When to Split a Module

Split a module when:

- It defines two or more types that could evolve independently
- Functions in the module only ever operate on one of the types
- The module name requires "and" or a vague umbrella term ("utils", "helpers", "misc")
- A consumer only needs half of what the module exports

Keep a module together when:

- Types are tightly coupled (one cannot be used without the other)
- All functions operate on the same type
- The concept is genuinely singular (e.g., `uuid.gleam` defines one opaque type)

## Examples

### Split: Two Independent Value Objects

```
// Bad: both in one module
application/pagination.gleam   ← Limit + Offset mixed

// Good: each in its own module
application/page_limit.gleam   ← only Limit
application/page_offset.gleam  ← only Offset (may reference page_limit)
```

### Keep Together: Single Concept

```
// Good: one concept, one module
domain/basics/uuid.gleam    ← T, new, value, generate_v7
domain/product.gleam        ← Id, T (Id is inseparable from Product)
```

## Module Naming

- Name the module after the single concept it represents
- Prefer specific names over generic containers (`product_name` over `product_strings`)
- Avoid suffixes like `_utils`, `_helpers`, `_misc` — they signal a module that has grown without focus

## Review Checklist

1. Can the module name be described without "and"?
2. Does every exported type and function belong to the same concept?
3. Would any consumer import this module but only use part of it?
4. Are there two types that could evolve independently of each other?
5. Could the module be split without creating circular imports?
