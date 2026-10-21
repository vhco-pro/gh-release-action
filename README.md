# gh-release-action

Publish a GitHub Release for an exact version tag, with release notes rendered by
a hash-verified [git-cliff](https://git-cliff.org).

This action does one thing. It does not calculate versions or create tags: that
is [`michielvha/gitversion-tag-action`](https://github.com/michielvha/gitversion-tag-action).
Most repositories do not call this action directly. They call
[`vhco-pro/gh-release-workflow`](https://github.com/vhco-pro/gh-release-workflow),
which checks out full history, runs GitVersion, and then this action. Copy an
example from that repository.

[.github/workflows/release.yml](.github/workflows/release.yml) is a working
direct use: this repository releases itself with `uses: ./`.

## Behaviour

| Input | Result |
| --- | --- |
| `dry-run: 'true'` | Notes for `HEAD` go to the job summary; no release, the tag need not exist |
| Prerelease tag | A prerelease that does not become the latest release |
| Release already exists | Its notes are kept; nothing is replaced, so a retry is safe |

The notes cover the commits since the previous stable `vX.Y.Z` tag that is an
ancestor of the release, and end at the release tag even when the branch has
moved on. [scripts/select-range.sh](scripts/select-range.sh) picks that range
because git-cliff alone ends the notes at `HEAD` and cannot skip earlier
prereleases while releasing one. The bundled [cliff.toml](cliff.toml) groups breaking
changes, features, fixes and dependency updates, and leaves out routine docs,
test and CI commits. `config-file` points at a caller configuration instead.

Inputs and outputs are defined in [action.yml](action.yml). The caller checks
out with `fetch-depth: 0` and `fetch-tags: true` and grants `contents: write`.
The runner needs Python 3 with `venv`, which GitHub-hosted runners have.

## Development

Run `shellcheck scripts/*.sh tests/*.sh` and `bash tests/test-release.sh` on
Linux or macOS with Python 3. The test installs git-cliff from
[requirements.txt](requirements.txt), where pip checks every file against its
listed hash and Dependabot keeps the version and hashes current. It renders notes
in disposable repositories and uses a mock `gh`; it publishes nothing.
Logic lives in [scripts/](scripts); `action.yml` only orders the steps.
