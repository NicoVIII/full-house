#!/bin/sh
set -e
DATABASE_URL="sqlite:${DATABASE_PATH}" dbmate --migrations-dir /app/db/migrations up
exec ./entrypoint.sh "$@"
