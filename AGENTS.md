# Full House — Agent Guide

`backend/` — Gleam/Wisp API. `webfrontend/` — Solid/TypeScript/Vite.

## API

```bash
bunx skir format
bunx skir snapshot
```

## Backend

```bash
cd backend
gleam check
gleam format
gleam run -m lint
gleam test
```

## Frontend

```bash
cd webfrontend
bun run dev
bun run build
bun run format:fix
bun run lint:fix
bun run test:run
bun run type-check
```
