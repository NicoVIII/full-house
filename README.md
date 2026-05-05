# Full House

[![Last commit](https://img.shields.io/github/last-commit/NicoVIII/full-house?style=flat-square)](https://github.com/NicoVIII/full-house/commits/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)

Full House is intended to become an application for managing household groceries.

## Vision

Track what you have at home, monitor best-before dates, and make restocking easy.

## What It Should Become

- Manage groceries and their quantities
- Record and monitor best-before dates
- Define a target "always-have" list for your household
- Quickly see what is missing and what you need to buy to restock

## Goal

Help users reduce food waste, avoid stockouts and shop with a clear, practical list.

## Current Status

Current implementation is an early foundation and does not yet cover the full grocery-management vision.

- Backend and frontend foundations are in place.
- Product and stock management basics are implemented.
- Best-before tracking, household target stock goals, and automated restock suggestions are planned next steps.

## Deployment

Docker images are published to the GitHub Container Registry on every push to `main` and on version tags (`v*`).

### Quick start

Copy this example `docker-compose.yml` and adjust to your needs:

```yaml
services:
  app:
    image: ghcr.io/nicoviii/full-house:main
    ports:
      - "8000:80"
    volumes:
      - db_data:/data
    environment:
      DATABASE_PATH: /data/full_house.db
      SECRET_KEY_BASE: "replace-with-a-long-random-secret"
    restart: unless-stopped

volumes:
  db_data:
```

Then start it:

```sh
docker compose -f docker-compose.example.yml up -d
```

The application is then available at `http://localhost:8000`.

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_PATH` | `./db/data/full_house.db` | Path to the SQLite database file |
| `PORT` | `8000` (dev) / `80` (Docker) | Port the HTTP server listens on |
| `SECRET_KEY_BASE` | *(dev fallback)* | Secret used for request signing — **set this in production** |
| `STATIC_DIR` | `./static` | Directory from which the frontend assets are served |

### Image tags

| Tag | When published |
|---|---|
| `main` | Every push to the `main` branch |
| `sha-<short>` | Every push (pinnable SHA tag) |
| `1.2.3`, `1.2`, `latest` | When a `v1.2.3` git tag is pushed |
