---
description: "Use when designing domain models and application types. Avoid primitive obsession by introducing validated opaque value objects."
applyTo: "backend/src/**/*.gleam"
---

# Value Objects Over Primitives

[Hard Rule] - enforcement

Use a named opaque type when a primitive value carries domain meaning or validation rules.

## When A Value Object Is Required

Create a value object when the value:

- Has constraints (format, range, non-empty)
- Represents a distinct concept a domain expert would name
- Could be confused with another value of the same primitive type
- Is validated repeatedly in multiple call sites

Do not create value objects for trivial internal values with no constraints.

## Placement

- Domain concepts -> `domain/**`
- Use-case mechanics (for example pagination controls) -> `application/**`
- Shared low-level wrappers -> `domain/basics/**`

## Constructor Contract

For validated opaque types, provide both:

1. `new(...) -> Result(T, E)` for untrusted/external input
2. `new_exn(...) -> T` for constants and already-validated internal data

`new_exn` must delegate to `new` to avoid duplicated validation logic.

Never call `new_exn` on unvalidated user or external input.

## Anti-Patterns

- Passing raw `String` / `Int` where a named value object exists
- Silently clamping invalid input instead of returning an error
- Mixing multiple independent concepts in one type/module (for example combined offset+limit type)

## Review Checklist

1. Are meaningful primitive fields wrapped in named opaque types?
2. Are invariants enforced once in constructors instead of many call sites?
3. Are both `new` and `new_exn` present when validation exists?
4. Is `new_exn` restricted to trusted data paths?
5. Is the value object placed in the correct layer?

## Related Instructions

- `module-focus.instructions.md`
- `backend-layer-imports.instructions.md`
- `backend-layer-structure.instructions.md`
- `predictable-behavior.instructions.md`
