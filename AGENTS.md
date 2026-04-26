# Full House — Agent Guide

`backend/` — Gleam/Wisp API (port 8000). `webfrontend/` — Solid/TypeScript/Vite.

## Backend

```bash
cd backend
gleam build
gleam test   # uses wisp/simulate — no server needed
gleam format --check
gleam check
```

## Frontend

```bash
cd webfrontend
bun run dev         # start dev server
bun run build       # build for production
bun run lint:fix    # lint with auto-fix
bun run test:run    # run tests
bun run type-check  # type check
```
