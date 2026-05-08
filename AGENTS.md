# Full House — Agent Guide

`backend/` — Gleam/Wisp API. `webfrontend/` — Solid/TypeScript/Vite.

## Backend

```bash
cd backend
gleam check
gleam format --check
gleam run -m lint
gleam test
```

## Frontend

```bash
cd webfrontend
bun run dev
bun run build
bun run lint:fix
bun run test:run
bun run type-check
```
