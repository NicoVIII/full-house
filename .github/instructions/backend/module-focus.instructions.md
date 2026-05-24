---
description: "Use when creating or reviewing modules in the backend. Keep modules focused on a single concept or responsibility. Split modules that cover multiple separable concerns."
applyTo: "server/src/**/*.gleam"
---

# Backend Module Focus

[Hard Rule] - enforcement

One module should represent one concept.

## Split When

- The module contains separable concepts or independently evolving types.
- Consumers regularly use only part of the module.
- The name needs "and" or vague terms like `utils`/`helpers`.

## Keep Together When

- Types/functions are tightly coupled as one concept.

## Review Checklist

1. Can the module be described without "and"?
2. Do all exports belong to one concept?
3. Would splitting reduce accidental coupling?
