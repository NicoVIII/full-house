#!/usr/bin/env python3

from __future__ import annotations

import sys

from hook_utils import (
    block,
    load_payload,
    log_hook_run,
    payload_touches_client_web,
    repo_root,
    run_command,
    should_process_write_tool,
)


def main() -> int:
    payload = load_payload()
    if not should_process_write_tool(payload):
        return 0

    if not payload_touches_client_web(payload):
        return 0

    log_hook_run("webclient", payload, "started")

    webclient_dir = repo_root() / "client-web"
    commands = [
        ["bun", "x", "--no-install", "tsc", "--noEmit"],
        ["bun", "run", "lint"],
        ["bun", "run", "test:run"],
    ]

    for command in commands:
        if not run_command(command, cwd=webclient_dir):
            log_hook_run("webclient", payload, "blocked")
            return block(
                "Webclient quality checks failed — fix type, lint, or test errors before continuing.",
                "Webclient quality hook blocked progress after a client-web edit.",
            )

    log_hook_run("webclient", payload, "passed")
    print("[hook:webclient] type-check + lint + tests passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
