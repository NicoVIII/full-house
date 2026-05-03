#!/usr/bin/env python3
"""Generate a Mermaid treemap of a directory hierarchy, using file line counts as values."""

import os
import subprocess
import sys


def count_lines(filepath: str) -> int:
    try:
        with open(filepath, errors="ignore") as f:
            return sum(1 for _ in f)
    except OSError:
        return 0


def git_ignored(dir_path: str, names: list[str]) -> set[str]:
    """Return the subset of names inside dir_path that are git-ignored."""
    if not names:
        return set()
    paths = [os.path.join(dir_path, name) for name in names]
    try:
        result = subprocess.run(
            ["git", "check-ignore", "--stdin", "-z"],
            input="\0".join(paths),
            capture_output=True,
            text=True,
            encoding="utf-8",
            cwd=dir_path,
        )
    except FileNotFoundError:
        return set()
    if not result.stdout:
        return set()
    return {os.path.basename(p) for p in result.stdout.split("\0") if p}


def build_treemap(root: str) -> str:
    root = os.path.abspath(root)
    output = [
        "---",
        "config:",
        "  treemap:",
        "    showValues: false",
        "---",
        "treemap-beta"
    ]
    root_node = os.path.basename(root)
    start_depth = 0
    # Only add root node, if it's not the current directory, to avoid cluttering the treemap
    if root_node != ".":
        output.append(f"\"{root_node}\"")
        start_depth = 1


    def recurse(path: str, depth: int) -> None:
        prefix = "  " * depth
        try:
            entries = sorted(os.scandir(path), key=lambda e: (not e.is_dir(), e.name))
        except PermissionError:
            return
        visible = [e for e in entries if not e.name.startswith(".git")]
        ignored = git_ignored(path, [e.name for e in visible])
        for entry in visible:
            if entry.name in ignored:
                continue
            if entry.is_dir(follow_symlinks=False):
                output.append(f"{prefix}\"{entry.name}\"")
                recurse(entry.path, depth + 1)
            else:
                lines = count_lines(entry.path)
                if lines > 0:
                    output.append(f"{prefix}\"{entry.name}\": {lines}")

    recurse(root, start_depth)
    return "\n".join(output)


if __name__ == "__main__":
    root_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    print(build_treemap(root_dir))
