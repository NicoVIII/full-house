#!/bin/sh
set -e

SKIR_VERSION="1.2"

if command -v bunx >/dev/null 2>&1; then
	bunx skir@"$SKIR_VERSION" "$@"
else
	npx skir@"$SKIR_VERSION" "$@"
fi

# Run formatter only when generating code, outside of CI.
if [ "$1" = "gen" ] && [ -z "$CI" ]; then
	(cd server && gleam format)
fi
