#!/usr/bin/env python3

from __future__ import annotations

import sys

from hook_utils import (
    block,
    load_payload,
    log_hook_run,
    payload_touches_backend_gleam,
    repo_root,
    run_command,
    should_process_write_tool,
)


def main() -> int:
    payload = load_payload()
    if not should_process_write_tool(payload):
        return 0

    if not payload_touches_backend_gleam(payload):
        return 0

    log_hook_run("backend", payload, "started")

    backend_dir = repo_root() / "backend"
    if not run_command(["gleam", "format"], cwd=backend_dir):
        log_hook_run("backend", payload, "blocked")
        return block(
            "gleam format failed — fix formatting errors before continuing",
            "Backend hook blocked progress after a backend Gleam edit.",
        )

    if run_command(["gleam", "test"], cwd=backend_dir):
        log_hook_run("backend", payload, "passed")
        print("[hook:backend] gleam format + gleam test passed")
        return 0

    log_hook_run("backend", payload, "blocked")
    return block(
        "gleam test failed — fix compilation or test errors before continuing",
        "Backend hook blocked progress after a backend Gleam edit.",
    )


if __name__ == "__main__":
    sys.exit(main())
