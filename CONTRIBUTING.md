# Contributing to ask-ranger

Thanks for taking an interest. This kit is opinionated and small; the bar for changes is clarity + tests.

## Before you open a PR

- Read [CLAUDE.md](template/CLAUDE.md) — the workflow the kit teaches is the workflow the kit follows.
- Run the full local check:
  ```bash
  bats tests/                    # 20 tests, no network
  shellcheck scripts/setup.sh scripts/sync-platforms.sh \
    scripts/session-end-check.sh scripts/hooks/gitleaks-precheck.sh \
    template/githooks/pre-push
  bash scripts/sync-platforms.sh # must leave the tree clean
  ```
- Keep PRs under ~400 lines where possible. Split large changes.

## Canonical source vs generated output

- **Canonical:** `template/workflows/<skill>/SKILL.md`.
- **Generated:** `template/.claude/skills/openspec-*`, `template/.claude/commands/opsx/*`, `template/.agent/…`, `template/.github/{prompts,skills}/…`.

Edit only the canonical source, then run `make sync`. CI fails the PR if generated files drift from the canonical source.

## Commit discipline

Follow the kit's own rules:

- One logical change per commit.
- Prefix with `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`, or `spec:`.
- Tests must pass after every commit.
- Never `--no-verify`; never `git push --force` to `main`.

## Security-sensitive changes

Updates to `template/vendor/ecc-hooks/hooks.json` must include a refreshed
`template/vendor/ecc-hooks/SOURCE_SHA`. Document the upstream diff in the PR
body; see [vendor/ecc-hooks/README.md](template/vendor/ecc-hooks/README.md)
for the process.

Changes to the `gitleaks-precheck.sh` hook or the setup script's settings
merge logic must include a bats test demonstrating the new behavior.

## Issues

Bug reports welcome. Please include:
- OS + shell (macOS/Linux, bash/zsh)
- `node -v`, `gitleaks version`, `jq --version`
- The exact `make` or `scripts/setup.sh` command you ran
- The output, not a summary
