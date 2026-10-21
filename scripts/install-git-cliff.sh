#!/usr/bin/env bash
set -euo pipefail

# The version and hashes live in requirements.txt, where Dependabot finds and
# updates them; --require-hashes refuses any file whose hash is not listed.
REQUIREMENTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/requirements.txt"
ENVIRONMENT="$RUNNER_TEMP/git-cliff"
python3 -m venv "$ENVIRONMENT"
"$ENVIRONMENT/bin/pip" install --quiet --disable-pip-version-check \
  --require-hashes --only-binary :all: --no-deps -r "$REQUIREMENTS"
"$ENVIRONMENT/bin/git-cliff" --version
printf '%s\n' "$ENVIRONMENT/bin" >> "$GITHUB_PATH"
