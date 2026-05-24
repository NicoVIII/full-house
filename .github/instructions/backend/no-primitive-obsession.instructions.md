---
description: "Use when designing domain models and application types. Avoid primitive obsession by introducing validated opaque value objects."
applyTo: "server/src/**/*.gleam"
---

# Value Objects Over Primitives

[Hard Rule] - enforcement

Use opaque named types for values with domain meaning or validation.

## Create A Value Object When

- The value has constraints (format/range/non-empty).
- The value represents a named domain concept.
- The same primitive could be confused with another concept.
- Validation repeats across call sites.

## Constructor Rules

- Provide `new(...) -> Result(T, E)` for untrusted input.
- Trusted-path constructors are optional; never use them for untrusted input.
- Validate once in the value object, not repeatedly in callers.

## Review Checklist

1. Are meaningful primitives wrapped in named opaque types?
2. Are invariants enforced in constructors?
3. Is untrusted input validated through safe constructors?
