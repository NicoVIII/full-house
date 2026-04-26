---
description: "Use when implementing backend Gleam boundaries between driver and application, or application and infrastructure. Enforce anti-corruption layers (ACLs) so external layer models do not leak across boundaries."
applyTo: "backend/src/**/*.gleam"
---
# Backend Anti-Corruption Layers (ACL)

[Hard Rule] - enforcement

Use explicit ACL mapping functions at layer boundaries to translate between external types and internal types. This lets each layer evolve independently.

- Apply this to all backend boundaries, not only new changes.
- Between `driver/**` and `application/**`, map transport/request/response models to application input/output models.
- Between `application/**` and `infrastructure/**`, map infrastructure/persistence/external models to application port models.
- Do not expose driver DTOs, HTTP concerns, or infrastructure record shapes directly to `application/**`.
- Prefer small dedicated mapper functions over inline ad-hoc conversions.
- Preserve semantic meaning when mapping (for example optional IDs, pagination semantics, and error categories).

## Mapper Function Organization

**Placement depends on reuse and complexity.**

- If a mapper is **used by multiple handlers or modules**, extract it to a separate file.
- If a mapper is **simple and used by only one handler** (e.g. a few lines of primitive parsing with a fallback), place it inline as a private helper.
- If a mapper is **complex and used by only one handler** (e.g. involves multiple domain types, nested structures, or more than ~20 lines), extract it to a separate file regardless of reuse. Complexity alone justifies extraction for readability.

A rough guide for "complex":
- Imports two or more domain modules for mapping purposes
- Contains multiple helper functions to build up the result
- Would make the handler file noticeably harder to scan

## Recommended Structures

### Simple Single-Use Mappers (Inline)

```gleam
// driver/http/products/handler.gleam

fn map_limit_param(query: List(#(String, String))) -> page_limit.T {
  // simple param parsing with fallback
}

pub fn handle(request: wisp.Request) -> wisp.Response { ... }
```

**Use when**: A few lines, one type, no domain traversal.

### Complex or Multi-Use Mappers (Separate File)

```gleam
// driver/http/products/response_mapper.gleam
pub fn map_response(result: list_products.ListProductsResult) -> String { ... }

// driver/http/products/handler.gleam
import driver/http/products/response_mapper
pub fn handle(request: wisp.Request) -> wisp.Response {
  let body = response_mapper.map_response(result)
  ...
}
```

**Use when**: Multiple domain types, several helper functions, or reused across handlers.

## Review Checklist

1. Are boundary models translated through explicit mapper functions (inline or in separate file)?
2. Are mappers placed inline (single use) or extracted (multiple use) appropriately?
3. Can application use-case signatures stay stable if HTTP payload shapes change?
4. Can infrastructure storage/external schemas change without changing application types?
5. Are mapping responsibilities kept out of domain code?
