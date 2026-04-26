---
description: "Use when writing, reviewing, or refactoring backend Gleam or frontend TypeScript code. Prefer code that is both readable and concise; when those goals pull apart, keep the version that preserves clarity fastest."
applyTo: "backend/**/*.gleam, webfrontend/src/**/*.ts, webfrontend/src/**/*.tsx"
---

# Readability First

[Hard Rule] - enforcement

Prefer code that is easy to understand and free of avoidable noise. When a shorter version hides intent, choose the clearer one.

## Practical Criteria

- Module purpose is clear quickly
- Names communicate intent
- Control flow reads top-to-bottom
- Complexity is justified by real needs
- Conciseness removes noise without hiding intent

## Frontend Note

- Apply the same rule to frontend code: prefer components and reactive flows that are easy to scan without unnecessary ceremony or tightly packed JSX
- Extract helpers or subcomponents when they make rendering logic easier to follow

## Definition Order

- Define constants before functions that use them
- Define private helpers before first use
- Define local utility values before dependent expressions
- Keep file flow sequential from top to bottom

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
- Clarity for unnecessary terseness

## Related Rules

- `module-focus.instructions.md`
- `backend-acl.instructions.md`
- `no-primitive-obsession.instructions.md`
