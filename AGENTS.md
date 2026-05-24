# Full House — Agent Guide

`server/` — Gleam/Wisp API. `client-web/` — Solid/TypeScript/Vite.

## API

```bash
./skir.sh gen
./skir.sh format
./skir.sh snapshot
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
bun run check:deadcode
bun run test:run
bun run type-check
```
