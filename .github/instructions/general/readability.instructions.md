---
description: "Use when writing, reviewing, or refactoring backend Gleam or frontend TypeScript code. Readability is the tie-breaker when correctness and behavior are equivalent."
applyTo: "backend/**/*.gleam, webfrontend/src/**/*.ts, webfrontend/src/**/*.tsx"
---

# Readability First

[Hard Rule] - enforcement

When two solutions are equally correct, choose the one easier for the next developer to understand.

## Practical Criteria

- Module purpose is clear quickly
- Names communicate intent
- Control flow reads top-to-bottom
- Complexity is justified by real needs

## Definition Order

- Define constants before functions that use them
- Define private helpers before first use
- Define local utility values before dependent expressions
- Keep file flow sequential from top to bottom

Recommended module order:

1. Imports
2. Public types and aliases
3. Constants
4. Functions in dependency order

Allowed exception:

- Mutually recursive functions may stay grouped when reordering harms clarity

## Commenting

- Prefer self-explanatory code over explanatory comments
- Write comments for non-obvious intent, trade-offs, or edge cases
- Keep comments short and focused on why
- Do not restate obvious line-by-line behavior
- Avoid long comment blocks that duplicate code structure

## Do Not Trade Away

- Architectural boundaries
- Validation and explicit error handling
- Necessary abstractions

## Related Rules

- `module-focus.instructions.md`
- `backend-acl.instructions.md`
- `no-primitive-obsession.instructions.md`
