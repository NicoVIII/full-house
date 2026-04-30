#!/usr/bin/env python3

from __future__ import annotations

import sys

from hook_utils import (
    block,
    load_payload,
    log_hook_run,
    payload_touches_webfrontend,
    repo_root,
    run_command,
    should_process_write_tool,
)


def main() -> int:
    payload = load_payload()
    if not should_process_write_tool(payload):
        return 0

    if not payload_touches_webfrontend(payload):
        return 0

    log_hook_run("frontend", payload, "started")

    frontend_dir = repo_root() / "webfrontend"
    commands = [
        ["bun", "x", "--no-install", "tsc", "--noEmit"],
        ["bun", "run", "lint"],
        ["bun", "run", "test:run"],
    ]

    for command in commands:
        if not run_command(command, cwd=frontend_dir):
            log_hook_run("frontend", payload, "blocked")
            return block(
                "Frontend quality checks failed — fix type, lint, or test errors before continuing.",
                "Frontend quality hook blocked progress after a webfrontend edit.",
            )

    log_hook_run("frontend", payload, "passed")
    print("[hook:frontend] type-check + lint + tests passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
