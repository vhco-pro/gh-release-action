#!/usr/bin/env bash
set -euo pipefail

FLAGS=()
if [[ "$TAG" == *-* ]]; then
  FLAGS+=(--prerelease --latest=false)
fi
# Look the release up by its tag: the release list can come back incomplete,
# and only a 404 means there is no release yet.
ERRORS=$(mktemp)
if URL=$(gh api "repos/$GH_REPO/releases/tags/$TAG" --jq .html_url 2>"$ERRORS"); then
  echo "Release $TAG already exists; preserving its published notes."
elif grep -q 'HTTP 404' "$ERRORS"; then
  URL=$(gh release create "$TAG" --verify-tag --title "$TAG" --notes-file "$NOTES" "${FLAGS[@]}")
else
  cat "$ERRORS" >&2
  exit 1
fi
printf 'release-url=%s\n' "$URL" >> "$GITHUB_OUTPUT"
