#!/usr/bin/env python3

from __future__ import annotations

import sys

from hook_utils import block, payload_touches_backend_gleam, repo_root, run_command, should_process_write_tool, load_payload


def main() -> int:
    payload = load_payload()
    if not should_process_write_tool(payload):
        return 0

    if not payload_touches_backend_gleam(payload):
        return 0

    backend_dir = repo_root() / "backend"
    if run_command(["gleam", "test"], cwd=backend_dir):
        return 0

    return block(
        "gleam test failed — fix compilation or test errors before continuing",
        "Backend hook blocked progress after a backend Gleam edit.",
    )


if __name__ == "__main__":
    sys.exit(main())
