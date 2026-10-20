#!/usr/bin/env bash
set -euo pipefail

# An empty tag is what a caller passes when nothing was versioned; it is not an error.
if [[ -z "$TAG" ]]; then
  echo "No tag given, so there is no release to publish."
  printf 'skip=true\ntag=\nrange=\nprevious-tag=\n' >> "$GITHUB_OUTPUT"
  exit 0
fi
if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
  echo "::error::$TAG is not an exact version tag such as v1.2.3 or v1.2.3-feature.1"
  exit 1
fi
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
printf 'skip=false\ntag=%s\nrange=%s\nprevious-tag=%s\n' "$TAG" "$RANGE" "$PREVIOUS" >> "$GITHUB_OUTPUT"
