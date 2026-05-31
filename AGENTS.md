# Full House — Agent Guide

`server/` — Gleam/Wisp API. `client-web/` — Solid/TypeScript/Vite.

## Just (Repo Root)

```bash
just --list
just setup
just check
just test
just fix-format
just fix-all
```

## API

```bash
just skir-gen
just skir-format
just skir-snapshot
```

## Server

```bash
just server::run
just server::build
just server::check
just server::format
just server::format-check
just server::lint
just server::test
```

## Webclient

```bash
just client::dev
just client::build
just client::format
just client::format-check
just client::lint
just client::lint-fix
just client::deadcode
just client::test
just client::type-check
```
