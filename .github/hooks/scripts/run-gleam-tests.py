#!/usr/bin/env python3

from __future__ import annotations

import sys

from hook_utils import (
    block,
    load_payload,
    log_hook_run,
    payload_touches_server_gleam,
    repo_root,
    run_command,
    should_process_write_tool,
)


def main() -> int:
    payload = load_payload()
    if not should_process_write_tool(payload):
        return 0

    if not payload_touches_server_gleam(payload):
        return 0

    log_hook_run("server", payload, "started")

    server_dir = repo_root() / "server"
    if not run_command(["gleam", "format"], cwd=server_dir):
        log_hook_run("server", payload, "blocked")
        return block(
            "gleam format failed — fix formatting errors before continuing",
            "Server hook blocked progress after a server Gleam edit.",
        )

    if run_command(["gleam", "test"], cwd=server_dir):
        log_hook_run("server", payload, "passed")
        print("[hook:server] gleam format + gleam test passed")
        return 0

    log_hook_run("server", payload, "blocked")
    return block(
        "gleam test failed — fix compilation or test errors before continuing",
        "Server hook blocked progress after a server Gleam edit.",
    )


if __name__ == "__main__":
    sys.exit(main())
