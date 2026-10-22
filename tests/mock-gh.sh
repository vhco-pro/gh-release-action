#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$GH_LOG"
URL="https://github.com/example/project/releases/tag/$TAG"
if [[ "$1 $2" == "api repos/$GH_REPO/releases/tags/$TAG" ]]; then
  case "$RELEASE_CASE" in
    existing) printf '%s\n' "$URL" ;;
    absent) echo 'gh: Not Found (HTTP 404)' >&2; exit 1 ;;
    *) echo 'gh: Server Error (HTTP 502)' >&2; exit 1 ;;
  esac
elif [[ "$1 $2" == 'release create' ]]; then
  printf '%s\n' "$URL"
else
  exit 1
fi
