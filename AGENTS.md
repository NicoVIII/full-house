# Full House — Agent Guide

`server/` — Gleam/Wisp API. `client-web/` — Solid/TypeScript/Vite.

## API

```bash
bunx skir gen
bunx skir format
bunx skir snapshot
```

## Server

```bash
./scripts/setup_dev_db.py # Execute database migrations
cd server
gleam check
gleam format
gleam run -m lint
gleam test
```

## Webclient

```bash
cd client-web
bun run dev
bun run build
bun run format:fix
bun run lint:fix
bun run test:run
bun run type-check
```
