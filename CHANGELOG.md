# Changelog

Follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] — 2026-04-23

### Added
- `template/` directory: cleanly separates what gets installed into a target
  repo from what lives in the kit's own development tree.
- Token substitution: `{{REPO_NAME}}` in `template/CLAUDE.md` is replaced with
  `basename(TARGET)` by `setup.sh` so GitNexus MCP URIs resolve correctly in
  target repos.
- `setup.sh` now uses `trap ERR` to roll back `~/.claude/settings.json` from
  its timestamped backup if any step fails.
- Hard-fail on native Windows (previously a soft warning). Use WSL2.
- Existing `core.hooksPath` in target is preserved; the setup no longer
  silently overrides a user-set hooks path.
- `package.json` with `peerDependencies` declaring tested ranges for
  `@fission-ai/openspec`, `gitnexus`, and `ecc-agentshield`.
- `VERSION`, `CHANGELOG.md`, `CONTRIBUTING.md`.
- New bats assertions: `setup.sh` excludes itself from target copy, and
  substitutes `{{REPO_NAME}}` correctly.

### Changed
- `gitleaks-precheck.sh` now reads the PreToolUse JSON payload from stdin and
  extracts every relevant `tool_input.*` field (command, content, new_string,
  edits[].new_string); falls back to `TOOL_INPUT` env var for backward compat.
  Exits `2` (fail-close) when gitleaks is missing instead of `0` (fail-open).
- `template/Makefile`: `gitnexus` and `openspec` invocations switched to `npx`
  to match `CLAUDE.md` guidance and to remove the global-install requirement.
- `sync-platforms.sh` is context-aware: writes into `template/.claude/`,
  `template/.agent/`, `template/.github/` when run inside the kit;
  writes into `.claude/`, `.agent/`, `.github/` when run inside a target repo.
- Root `Makefile` slimmed to kit-only targets (setup, sync, test).
- README tightened to a pitch; GETTING_STARTED tightened to a tutorial.
- Root `.gitignore` cleaned up; target-facing fragment moved to
  `template/.gitignore.append`.

### Removed
- Obsolete `/tmp/ecc/` entry from `.gitignore` (predates vendored hooks).

## [0.1.1] — earlier

See `git log` for pre-0.2.0 history.

[Unreleased]: https://github.com/ongtungduong/ask-ranger/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/ongtungduong/ask-ranger/compare/v0.1.1...v0.2.0
