#!/usr/bin/env bash
set -euo pipefail

FLAGS=()
if [[ "$TAG" == *-* ]]; then
  FLAGS+=(--prerelease --latest=false)
fi

# FILES: one path per line, relative to the workspace, with no glob expansion.
ATTACH=()
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if [[ ! -f "$path" ]]; then
    printf 'gh-release-action: file not found: %s\n' "$path" >&2
    exit 1
  fi
  ATTACH+=("$path")
done <<< "${FILES:-}"

# Look the release up by its tag: the release list can come back incomplete,
# and only a 404 means there is no release yet.
ERRORS=$(mktemp)
if RELEASE=$(gh api "repos/$GH_REPO/releases/tags/$TAG" 2>"$ERRORS"); then
  URL=$(jq -r .html_url <<< "$RELEASE")
  if (( ${#ATTACH[@]} > 0 )); then
    WANT=$(for file in "${ATTACH[@]}"; do basename "$file"; done | sort | paste -sd ' ')
    HAVE=$(jq -r '.assets[].name' <<< "$RELEASE" | sort | paste -sd ' ')
    if [[ "$WANT" != "$HAVE" ]]; then
      printf 'gh-release-action: release %s exists with different files; requested: %s; attached: %s\n' \
        "$TAG" "$WANT" "${HAVE:-none}" >&2
      exit 1
    fi
  fi
  echo "Release $TAG already exists; preserving its published notes and files."
elif grep -q 'HTTP 404' "$ERRORS"; then
  # One create call with the files and without --draft: gh uploads them to a hidden
  # draft and deletes it if an upload fails, so no release appears with files missing.
  URL=$(gh release create "$TAG" "${ATTACH[@]}" --verify-tag --title "$TAG" --notes-file "$NOTES" "${FLAGS[@]}")
else
  cat "$ERRORS" >&2
  exit 1
fi
printf 'release-url=%s\n' "$URL" >> "$GITHUB_OUTPUT"
