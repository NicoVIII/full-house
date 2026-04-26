from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any


WRITE_TOOL_NAMES = {
    "apply_patch",
    "create_file",
    "replace_string_in_file",
    "multi_replace_string_in_file",
}


def load_payload() -> dict[str, Any]:
    raw_input = sys.stdin.read().strip()
    if not raw_input:
        return {}

    try:
        payload = json.loads(raw_input)
    except json.JSONDecodeError:
        return {}

    return payload if isinstance(payload, dict) else {}


def should_process_write_tool(payload: dict[str, Any]) -> bool:
    tool_name = payload.get("tool_name")
    return isinstance(tool_name, str) and tool_name in WRITE_TOOL_NAMES


def iter_strings(value: Any):
    if isinstance(value, str):
        yield value
        return

    if isinstance(value, dict):
        for nested_value in value.values():
            yield from iter_strings(nested_value)
        return

    if isinstance(value, list):
        for nested_value in value:
            yield from iter_strings(nested_value)


def payload_touches_backend_gleam(payload: dict[str, Any]) -> bool:
    tool_input = payload.get("tool_input")
    for text in iter_strings(tool_input):
        if "/backend/" in text and ".gleam" in text:
            return True
    return False


def payload_touches_webfrontend(payload: dict[str, Any]) -> bool:
    tool_input = payload.get("tool_input")
    for text in iter_strings(tool_input):
        if "/webfrontend/" in text or text.startswith("webfrontend/") or "webfrontend/" in text:
            return True
    return False


def repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def run_command(command: list[str], cwd: Path) -> bool:
    completed = subprocess.run(command, cwd=cwd, check=False)
    return completed.returncode == 0


def block(message: str, system_message: str | None = None) -> int:
    payload: dict[str, Any] = {
        "decision": "block",
        "stopReason": message,
    }
    if system_message:
        payload["systemMessage"] = system_message

    print(json.dumps(payload))
    return 2
