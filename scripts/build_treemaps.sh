#!/bin/bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
file_path="$repo_root/docs/dev/overview.md"

build_map() {
    local path=$1
    echo '```mermaid' >> "$file_path"
    python3 "$script_dir/treemap.py" "$path" >> "$file_path"
    echo '```' >> "$file_path"
}

echo "# Overview" > "$file_path"
build_map .
echo "## Server" >> "$file_path"
build_map ./server
build_map ./server/src
echo "## Webclient" >> "$file_path"
build_map ./client-web
build_map ./client-web/src
