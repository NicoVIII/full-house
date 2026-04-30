from __future__ import annotations

from datetime import datetime, timezone
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
    "edit_notebook_file",
    "create_new_jupyter_notebook",
}


WRITE_INPUT_KEYS = {
    "filePath",
    "filePaths",
    "path",
    "old_path",
    "new_path",
    "oldPath",
    "newPath",
    "input",
    "content",
    "newCode",
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
    tool_name = normalize_tool_name(get_payload_field(payload, "tool_name", "toolName"))
    print(f"[hook_utils] detected tool name: {tool_name}")
    if tool_name in WRITE_TOOL_NAMES:
        return True

    # Fallback for hook payload variants: if the payload shape clearly looks
    # like a file write/edit operation, treat it as a write tool.
    return payload_looks_like_write(get_tool_input(payload))


def get_payload_field(payload: dict[str, Any], *names: str) -> Any:
    for name in names:
        if name in payload:
            return payload.get(name)
    return None


def get_tool_input(payload: dict[str, Any]) -> Any:
    return get_payload_field(payload, "tool_input", "toolInput", "input")


def detected_tool_name(payload: dict[str, Any]) -> str:
    tool_name = normalize_tool_name(get_payload_field(payload, "tool_name", "toolName"))
    return tool_name or "unknown"


def normalize_tool_name(tool_name: Any) -> str:
    if not isinstance(tool_name, str):
        return ""

    # Some payloads include a namespace prefix (e.g. "functions.apply_patch").
    return tool_name.split(".")[-1]


def payload_looks_like_write(tool_input: Any) -> bool:
    if isinstance(tool_input, dict):
        for key, value in tool_input.items():
            if key in WRITE_INPUT_KEYS:
                return True
            if payload_looks_like_write(value):
                return True
        return False

    if isinstance(tool_input, list):
        for value in tool_input:
            if payload_looks_like_write(value):
                return True

    return False


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
    tool_input = get_tool_input(payload)
    for text in iter_strings(tool_input):
        if (
            "/backend/" in text
            or text.startswith("backend/")
            or "backend/" in text
        ) and ".gleam" in text:
            return True
    return False


def payload_touches_webfrontend(payload: dict[str, Any]) -> bool:
    tool_input = get_tool_input(payload)
    for text in iter_strings(tool_input):
        if "/webfrontend/" in text or text.startswith("webfrontend/") or "webfrontend/" in text:
            return True
    return False


def repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def run_command(command: list[str], cwd: Path) -> bool:
    completed = subprocess.run(command, cwd=cwd, check=False)
    return completed.returncode == 0


def log_hook_run(hook_name: str, payload: dict[str, Any], outcome: str) -> None:
    record = {
        "ts": datetime.now(timezone.utc).isoformat(),
        "hook": hook_name,
        "tool": detected_tool_name(payload),
        "outcome": outcome,
    }

    try:
        log_path = repo_root() / ".github/hooks/.last-run.log"
        with log_path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(record) + "\n")
    except Exception:
        # Logging must never break hook execution.
        return


def block(message: str, system_message: str | None = None) -> int:
    payload: dict[str, Any] = {
        "decision": "block",
        "stopReason": message,
    }
    if system_message:
        payload["systemMessage"] = system_message

    print(json.dumps(payload))
    return 2
