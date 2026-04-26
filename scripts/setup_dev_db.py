#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import platform
import shutil
import stat
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

DBMATE_VERSION = "v2.26.0"


def resolve_repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def resolve_default_db_path(repo_root: Path) -> Path:
    return repo_root / "backend" / "data" / "full_house.db"


def map_architecture(machine: str) -> str:
    if machine == "x86_64":
        return "amd64"
    if machine in {"aarch64", "arm64"}:
        return "arm64"
    raise RuntimeError(f"Unsupported architecture for dbmate install: {machine}")


def run(
    command: list[str],
    *,
    env: dict[str, str] | None = None,
    input_text: str | None = None,
) -> None:
    subprocess.run(command, check=True, env=env, text=True, input=input_text)


def ensure_dbmate() -> None:
    if shutil.which("dbmate"):
        return

    machine = platform.machine()
    dbmate_arch = map_architecture(machine)
    url = (
        f"https://github.com/amacneil/dbmate/releases/download/"
        f"{DBMATE_VERSION}/dbmate-linux-{dbmate_arch}"
    )

    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        tmp_path = Path(tmp.name)

    try:
        urllib.request.urlretrieve(url, tmp_path)
        tmp_path.chmod(tmp_path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

        target = Path("/usr/local/bin/dbmate")
        if os.geteuid() == 0:
            shutil.move(str(tmp_path), target)
        else:
            if shutil.which("sudo"):
                run(["sudo", "mv", str(tmp_path), str(target)])
            else:
                raise RuntimeError("dbmate is missing and sudo is not available to install it")
    finally:
        if tmp_path.exists():
            tmp_path.unlink()


def ensure_binary(name: str, install_hint: str) -> None:
    if shutil.which(name):
        return
    raise RuntimeError(f"{name} CLI not found. Install it first ({install_hint}).")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Set up local SQLite database for development")
    parser.add_argument(
        "--db-path",
        help="Override SQLite database file path",
    )
    parser.add_argument(
        "--seed",
        action="store_true",
        help="Seed development data after applying migrations",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = resolve_repo_root()

    db_path = Path(
        args.db_path
        or os.environ.get("DATABASE_PATH")
        or resolve_default_db_path(repo_root)
    ).expanduser()

    migrations_dir = repo_root / "backend" / "db" / "migrations"
    dev_seed_file = repo_root / "backend" / "db" / "seeds" / "dev" / "dev_seed.sql"

    db_path.parent.mkdir(parents=True, exist_ok=True)

    ensure_dbmate()
    ensure_binary("sqlite3", "e.g. sudo apt install -y sqlite3")

    env = dict(os.environ)
    env["DATABASE_URL"] = f"sqlite:{db_path}"

    run(["dbmate", "--migrations-dir", str(migrations_dir), "up"], env=env)

    if args.seed:
        run(
            ["sqlite3", str(db_path)],
            env=env,
            input_text=dev_seed_file.read_text(encoding="utf-8"),
        )

    print(f"SQLite database is ready at {db_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)
