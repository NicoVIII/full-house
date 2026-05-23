# Contributing to Full House

Thank you for your interest in contributing! This document explains how to get started and what to expect from the development workflow.

## Repository Structure

The repository consists of two main parts:

- [server/](server/) — Gleam/Wisp HTTP API with a SQLite database
- [client-web/](client-web/) — SolidJS/TypeScript webclient built with Vite and Bun

For a visual overview of the repository layout, see the Mermaid treemap diagrams in [docs/dev/overview.md](docs/dev/overview.md). They show the full project, the server, and the webclient as proportional treemaps so you can quickly orient yourself.

## Development Environment

The repository ships with a Dev Container configuration. Opening it in VS Code with the Dev Containers extension (or GitHub Codespaces) gives you a ready-to-use environment with all dependencies installed.

If you prefer a local setup, you need:

- [Gleam](https://gleam.run/getting-started/installing/) and Erlang/OTP for the server
- [Bun](https://bun.sh/) for the webclient
- [Python 3](https://www.python.org/) for the dev database setup script

### Setting up the development database

```sh
python scripts/setup_dev_db.py
```

Database migrations are the source of truth for schema changes.

- Create and apply schema changes via dbmate migrations in `server/db/migrations/`.
- Treat `server/db/schema.sql` as generated output from dbmate.
- Do not edit `server/db/schema.sql` manually.

## Running the Project Locally

### Server

```sh
cd server
gleam run
```

### Webclient

```sh
cd client-web
bun run dev
```

## Tests and Quality Checks

All checks listed below are also enforced by the [lefthook](lefthook.yml) pre-commit hook.
If you don't use the devcontainer, install lefthook once to have them run automatically on every commit:

```sh
lefthook install
```

### Server

```sh
cd server
gleam format --check
gleam check         # type check
gleam run -m lint   # architecture lint
gleam test          # unit and integration tests
```

### Webclient

```sh
cd client-web
bun run format:check
bun x --no-install tsc --noEmit   # type check
bun run lint
bun run test:run    # Vitest tests
```

## Submitting Changes

1. Fork the repository and create a branch from `main`.
2. Make your changes and ensure all tests and checks pass.
3. Open a pull request against `main` with a clear description of what you changed and why.

There are no strict commit message conventions beyond writing clear, descriptive summaries.

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).
