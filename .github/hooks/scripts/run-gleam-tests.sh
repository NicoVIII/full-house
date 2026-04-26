#!/usr/bin/env bash
# PostToolUse hook: run gleam test after any backend Gleam file is edited.
# Exits 2 (blocking) if tests fail, so the agent cannot proceed.

set -euo pipefail

# Read tool call data from stdin
input=$(cat)

tool_name=$(echo "$input" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4)

# Only act on file-writing tools
case "$tool_name" in
  replace_string_in_file|create_file|multi_replace_string_in_file) ;;
  *) exit 0 ;;
esac

# Extract the filePath from tool_input (first filePath value)
file_path=$(echo "$input" | grep -o '"filePath":"[^"]*"' | head -1 | cut -d'"' -f4)

# Only act on backend Gleam files
if [[ "$file_path" != *"/backend/"*".gleam" ]]; then
  exit 0
fi

cd "$(dirname "$0")/../../.." || exit 0
cd backend || exit 0

if gleam test 2>&1; then
  exit 0
else
  echo '{"stopReason":"gleam test failed — fix compilation or test errors before continuing"}'
  exit 2
fi
