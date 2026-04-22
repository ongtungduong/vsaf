# vendor/ecc-hooks

Vendored copy of AgentShield PreToolUse / PostToolUse hook definitions from the upstream [everything-claude-code](https://github.com/affaan-m/everything-claude-code) repository.

## Why vendor?

`scripts/setup.sh` merges these hooks into `~/.claude/settings.json` during installation. Fetching them from the network at setup time is a supply-chain risk — anything upstream adds to `hooks.json` gets executed on every Claude Code tool call. Vendoring pins the hooks to a reviewed SHA.

## Current version

See `SOURCE_SHA` for the commit we vendored.

## Refreshing

```bash
TMP=$(mktemp -d) && cd "$TMP"
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git ecc
SHA=$(git -C ecc rev-parse HEAD)
diff ecc/hooks/hooks.json <repo-root>/vendor/ecc-hooks/hooks.json   # review the diff
cp ecc/hooks/hooks.json <repo-root>/vendor/ecc-hooks/hooks.json
echo "$SHA" > <repo-root>/vendor/ecc-hooks/SOURCE_SHA
```

Commit the update in a dedicated PR so the diff is visible.

## Files

- `hooks.json` — merged into `~/.claude/settings.json` by `scripts/setup.sh`
- `SOURCE_SHA` — the upstream commit SHA this copy was taken from
