#!/usr/bin/env bash
set -euo pipefail

# git-cliff cannot do this itself: with prerelease tags ignored it also ignores
# a prerelease being released, and it ends the notes at HEAD rather than at an
# older tag being retried. Both put later commits in the notes.
if [[ "$DRY_RUN" == true ]]; then
  REVISION=$(git rev-parse HEAD)
else
  REVISION=$(git rev-parse "refs/tags/$TAG^{commit}")
fi
PREVIOUS=""
CANDIDATES=$(git for-each-ref --merged="$REVISION" --sort=-version:refname --format='%(refname:short)' refs/tags)
while IFS= read -r CANDIDATE; do
  if [[ "$CANDIDATE" != "$TAG" && "$CANDIDATE" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    PREVIOUS="$CANDIDATE"
    break
  fi
done <<< "$CANDIDATES"
RANGE="$REVISION"
if [[ -n "$PREVIOUS" ]]; then
  RANGE="$PREVIOUS..$REVISION"
fi
printf 'range=%s\nprevious-tag=%s\n' "$RANGE" "$PREVIOUS" >> "$GITHUB_OUTPUT"
