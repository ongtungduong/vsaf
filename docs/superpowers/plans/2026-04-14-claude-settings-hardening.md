# Claude Settings Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a permissions block and a Stop hook (via an external shell script) to the project's `.claude/settings.json`, addressing the two findings from the claude-automation-recommender audit.

**Architecture:** One new executable shell script `scripts/claude-stop-hook.sh` runs five advisory session-end checks (secrets, AgentShield reminder, GitNexus staleness, uncommitted summary, debug artifacts). The `.claude/settings.json` gains a `permissions` block (permissive allowlist for the vsaf toolchain + deny list for destructive patterns) and a `Stop` hook that invokes the script. Existing PreToolUse/PostToolUse hooks remain untouched.

**Tech Stack:** Bash, `jq`, `git`, Claude Code hooks and permissions.

**Spec:** [docs/superpowers/specs/2026-04-14-claude-settings-hardening-design.md](../specs/2026-04-14-claude-settings-hardening-design.md)

---

## Important Caveat

The existing PreToolUse hook in `.claude/settings.json` hard-blocks `Edit`/`Write`/`MultiEdit` on `.claude/settings.json` itself (see line 9 of the current file). Task 6 must be applied by the user manually OR by a tool invocation the user explicitly approves when the hook fires. Do NOT attempt to disable or work around the hook.

---

### Task 1: Create `scripts/claude-stop-hook.sh`

**Files:**
- Create: `scripts/claude-stop-hook.sh`

- [ ] **Step 1: Write the script**

Create `scripts/claude-stop-hook.sh` with this exact content:

```bash
#!/usr/bin/env bash
# Session-end verification for Claude Code Stop hook.
# Usage: claude-stop-hook.sh [--strict]
#
# Checks (all advisory unless --strict):
#   1. Uncommitted secret scan (diff regex)
#   2. AgentShield reminder if files modified
#   3. GitNexus staleness (.gitnexus/meta.json vs HEAD)
#   4. Uncommitted changes summary
#   5. Debug artifact scan in staged diff
#
# Exit 0 always, except --strict + secrets -> exit 2.

set -uo pipefail

STRICT="${1:-}"
WARN=0

say() { printf '[stop-hook] %s\n' "$*"; }

check_secrets() {
  local diff
  diff="$( { git diff HEAD 2>/dev/null; git diff --cached 2>/dev/null; } )"
  if printf '%s' "$diff" | grep -qE 'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|sk-[a-zA-Z0-9]{48}|xox[bpoas]-[a-zA-Z0-9-]+|eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*'; then
    say "SECRET DETECTED in uncommitted diff"
    if [ "$STRICT" = "--strict" ]; then
      exit 2
    fi
    WARN=$((WARN + 1))
  fi
}

check_agentshield() {
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    say "Files modified — run: npx ecc-agentshield scan"
    WARN=$((WARN + 1))
  fi
}

check_gitnexus_stale() {
  local meta=".gitnexus/meta.json"
  [ -f "$meta" ] || return 0
  local head_ts meta_ts
  head_ts="$(git log -1 --format=%ct 2>/dev/null || echo 0)"
  meta_ts="$(stat -f %m "$meta" 2>/dev/null || stat -c %Y "$meta" 2>/dev/null || echo 0)"
  if [ "$head_ts" -gt "$meta_ts" ]; then
    say "GitNexus index stale — run: gitnexus analyze"
    WARN=$((WARN + 1))
  fi
}

check_uncommitted() {
  local status
  status="$(git status --short 2>/dev/null)"
  if [ -n "$status" ]; then
    say "Uncommitted changes:"
    printf '%s\n' "$status" | sed 's/^/  /'
  fi
}

check_debug_artifacts() {
  local added
  added="$(git diff --cached -U0 2>/dev/null | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
  if [ -n "$added" ] && printf '%s' "$added" | grep -qE 'console\.log|debugger;|TODO:[[:space:]]*remove|print\('; then
    say "Debug artifact in staged diff (console.log/debugger/print/TODO:remove)"
    WARN=$((WARN + 1))
  fi
}

check_secrets
check_agentshield
check_gitnexus_stale
check_uncommitted
check_debug_artifacts

if [ "$WARN" -gt 0 ]; then
  say "$WARN warning(s)"
fi
exit 0
```

- [ ] **Step 2: Make executable**

Run: `chmod +x scripts/claude-stop-hook.sh`

- [ ] **Step 3: Syntax check**

Run: `bash -n scripts/claude-stop-hook.sh`
Expected: no output, exit 0.

- [ ] **Step 4: Shellcheck (if available)**

Run: `command -v shellcheck >/dev/null && shellcheck scripts/claude-stop-hook.sh || echo "shellcheck not installed — skipping"`
Expected: either "no issues" from shellcheck, or the skip message.

- [ ] **Step 5: Commit**

```bash
git add scripts/claude-stop-hook.sh
git commit -m "feat: add Claude Code Stop hook script for session-end checks"
```

---

### Task 2: Smoke test the Stop hook script (baseline)

**Files:** none (verification only)

- [ ] **Step 1: Run the script on the current working tree**

Run: `./scripts/claude-stop-hook.sh`
Expected: zero or more `[stop-hook] ...` lines, exits 0. Typical output on a dirty tree:

```
[stop-hook] Files modified — run: npx ecc-agentshield scan
[stop-hook] Uncommitted changes:
  M some/file.ext
[stop-hook] 1 warning(s)
```

If the script errors out (e.g. `bash: stat: command not found`, unexpected non-zero exit), STOP and fix before proceeding.

- [ ] **Step 2: Confirm exit code is 0**

Run: `./scripts/claude-stop-hook.sh; echo "exit=$?"`
Expected: last line is `exit=0`.

---

### Task 3: Test secret detection

**Files:**
- Temporary: `/tmp/vsaf-stop-hook-secret-test.txt` (created + deleted in this task)

- [ ] **Step 1: Stage a fake AWS key in a throwaway file**

Run:
```bash
printf 'AWS_KEY=AKIAIOSFODNN7EXAMPLE\n' > /tmp/vsaf-stop-hook-secret-test.txt
cp /tmp/vsaf-stop-hook-secret-test.txt ./vsaf-stop-hook-secret-test.txt
git add -f ./vsaf-stop-hook-secret-test.txt
```

Note: we copy into the repo because the hook inspects `git diff --cached` for files in this working tree. The file is NOT committed.

- [ ] **Step 2: Run the script, expect secret warning**

Run: `./scripts/claude-stop-hook.sh`
Expected: output contains `[stop-hook] SECRET DETECTED in uncommitted diff`. Exit code 0.

- [ ] **Step 3: Run with `--strict`, expect exit 2**

Run: `./scripts/claude-stop-hook.sh --strict; echo "exit=$?"`
Expected: `[stop-hook] SECRET DETECTED in uncommitted diff` followed by `exit=2`.

- [ ] **Step 4: Unstage and delete the test file**

Run:
```bash
git reset HEAD ./vsaf-stop-hook-secret-test.txt
rm ./vsaf-stop-hook-secret-test.txt /tmp/vsaf-stop-hook-secret-test.txt
```

- [ ] **Step 5: Confirm the test file is gone from git and disk**

Run: `git status --short | grep vsaf-stop-hook-secret-test.txt || echo "clean"`
Expected: `clean`.

Run: `test ! -e ./vsaf-stop-hook-secret-test.txt && echo "gone"`
Expected: `gone`.

- [ ] **Step 6: Re-run the hook to confirm the secret warning is gone**

Run: `./scripts/claude-stop-hook.sh`
Expected: no `SECRET DETECTED` line.

---

### Task 4: Test GitNexus staleness check

**Files:** none (toggles mtime on `.gitnexus/meta.json`)

- [ ] **Step 1: Skip if the file does not exist**

Run: `test -f .gitnexus/meta.json && echo "present" || echo "absent — skipping Task 4"`

If the output is `absent — skipping Task 4`, mark all remaining steps in this task as complete and move to Task 5.

- [ ] **Step 2: Back up the original mtime**

Run: `ORIG_MTIME=$(stat -f %m .gitnexus/meta.json 2>/dev/null || stat -c %Y .gitnexus/meta.json); echo "$ORIG_MTIME" > /tmp/vsaf-gitnexus-mtime.bak`

- [ ] **Step 3: Force the file's mtime to 1970-01-02 (far past)**

Run: `touch -t 197001020000 .gitnexus/meta.json`

- [ ] **Step 4: Run the hook, expect staleness warning**

Run: `./scripts/claude-stop-hook.sh`
Expected: output contains `[stop-hook] GitNexus index stale — run: gitnexus analyze`.

- [ ] **Step 5: Restore the original mtime**

Run:
```bash
ORIG=$(cat /tmp/vsaf-gitnexus-mtime.bak)
# touch accepts @epoch via -d on GNU, -t requires YYYYMMDDhhmm — use python for portability
python3 -c "import os,sys; os.utime('.gitnexus/meta.json', (int(sys.argv[1]), int(sys.argv[1])))" "$ORIG"
rm /tmp/vsaf-gitnexus-mtime.bak
```

- [ ] **Step 6: Confirm the warning is gone**

Run: `./scripts/claude-stop-hook.sh | grep -F 'GitNexus index stale' || echo "clean"`
Expected: `clean`.

---

### Task 5: Test debug artifact detection

**Files:**
- Temporary: `./vsaf-stop-hook-debug-test.js` (created + deleted in this task)

- [ ] **Step 1: Create and stage a file with `console.log`**

Run:
```bash
printf 'function f() { console.log("hi"); }\n' > ./vsaf-stop-hook-debug-test.js
git add -f ./vsaf-stop-hook-debug-test.js
```

- [ ] **Step 2: Run the hook, expect debug artifact warning**

Run: `./scripts/claude-stop-hook.sh`
Expected: output contains `[stop-hook] Debug artifact in staged diff`.

- [ ] **Step 3: Unstage and delete**

Run:
```bash
git reset HEAD ./vsaf-stop-hook-debug-test.js
rm ./vsaf-stop-hook-debug-test.js
```

- [ ] **Step 4: Confirm clean**

Run: `./scripts/claude-stop-hook.sh | grep -F 'Debug artifact' || echo "clean"`
Expected: `clean`.

---

### Task 6: Update `.claude/settings.json` with permissions block and Stop hook

**Files:**
- Modify: `.claude/settings.json`

**Caveat:** The existing PreToolUse hook blocks automated writes to this file. The user will see a block message and must manually approve the edit, OR they will apply the change by hand from the plan.

- [ ] **Step 1: Capture current file for reference**

Run: `cat .claude/settings.json`

Expected: current content with `hooks` and `enabledPlugins` but no `permissions` and no `Stop` array.

- [ ] **Step 2: Apply the new content**

Replace the entire content of `.claude/settings.json` with:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "MultiEdit",
      "TodoWrite",
      "WebFetch",
      "WebSearch",
      "Bash(git:*)",
      "Bash(gh:*)",
      "Bash(make:*)",
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(grep:*)",
      "Bash(rg:*)",
      "Bash(find:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(gitnexus:*)",
      "Bash(graphify:*)",
      "Bash(mempalace:*)",
      "Bash(pytest:*)",
      "Bash(go:*)",
      "Bash(cargo:*)"
    ],
    "deny": [
      "Bash(rm -rf /*)",
      "Bash(rm -rf ~*)",
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git push -f*)",
      "Bash(chmod 777*)",
      "Edit(.env*)",
      "Edit(*.pem)",
      "Edit(*.key)",
      "Edit(id_rsa*)",
      "Edit(id_ed25519*)",
      "Write(.env*)",
      "Write(*.pem)",
      "Write(*.key)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|Create|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "FILE=\"$TOOL_INPUT_FILE\"; if [ -n \"$FILE\" ]; then if echo \"$FILE\" | grep -qE '\\.env$|\\.env\\.|\\.pem$|\\.key$|id_rsa|id_ed25519|\\.claude/settings\\.json'; then echo 'BLOCK: Protected file. Manual edit required for secrets/config files.'; exit 2; fi; fi"
          }
        ]
      },
      {
        "matcher": "Edit|Write|Create|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "INPUT=\"$TOOL_INPUT\"; if [ -n \"$INPUT\" ]; then if echo \"$INPUT\" | grep -qE 'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|sk-[a-zA-Z0-9]{48}|xox[bpoas]-[a-zA-Z0-9-]+|eyJ[a-zA-Z0-9_-]*\\.[a-zA-Z0-9_-]*\\.[a-zA-Z0-9_-]*'; then echo 'BLOCK: Hardcoded secret/token detected. Use environment variables.'; exit 2; fi; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Create",
        "hooks": [
          {
            "type": "command",
            "command": "echo '[AgentShield] File modified. Run: npx ecc-agentshield scan'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/claude-stop-hook.sh\""
          }
        ]
      }
    ]
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
```

- [ ] **Step 3: Validate JSON**

Run: `jq . .claude/settings.json > /dev/null && echo "valid"`
Expected: `valid`.

If `jq` is not installed:
Run: `python3 -m json.tool .claude/settings.json > /dev/null && echo "valid"`
Expected: `valid`.

- [ ] **Step 4: Confirm the expected keys exist**

Run: `jq -r '.permissions | keys | join(",")' .claude/settings.json`
Expected: `allow,deny`.

Run: `jq -r '.hooks | keys | join(",")' .claude/settings.json`
Expected: `PostToolUse,PreToolUse,Stop` (order may differ).

Run: `jq -r '.hooks.Stop[0].hooks[0].command' .claude/settings.json`
Expected: `bash "$CLAUDE_PROJECT_DIR/scripts/claude-stop-hook.sh"`.

- [ ] **Step 5: Commit**

```bash
git add .claude/settings.json
git commit -m "feat(claude): add permissions block and Stop hook to settings"
```

---

### Task 7: End-to-end verification in a Claude session

**Files:** none (manual runtime check)

- [ ] **Step 1: Restart Claude Code so the new settings load**

The user must exit and re-enter the Claude session, OR run `/model` (which re-reads settings in some versions) — whichever the user prefers. Hooks and permissions are loaded at session start.

- [ ] **Step 2: Confirm the Stop hook fires**

End the session (or trigger a Stop event via the normal turn-end path). Look for `[stop-hook]` lines in the terminal.

Expected: at least the `Files modified` or `Uncommitted changes:` line if there are pending changes, otherwise silent exit 0.

- [ ] **Step 3: Confirm a denied pattern is blocked**

In a new turn, ask Claude to run `rm -rf /tmp/definitely-does-not-exist-xyz123`. Note: the deny pattern is `Bash(rm -rf *)` which matches this.

Expected: Claude is prompted (or blocked) by the permissions system instead of the command running immediately.

Note: if the deny pattern semantics differ from expectation in the currently-installed Claude Code version, the user may need to adjust globs. That's acceptable — the goal of this step is to surface the behavior, not to prove a specific implementation.

- [ ] **Step 4: Confirm an allowed pattern runs without prompt**

In a new turn, ask Claude to run `git status`.
Expected: runs without a permission prompt.

---

## Rollback

If any task goes wrong and the settings file is broken:

```bash
git checkout HEAD -- .claude/settings.json
```

If the Stop hook script itself is the problem:

```bash
git rm scripts/claude-stop-hook.sh
# and remove the Stop block from .claude/settings.json manually, re-run jq to validate
```

---

## Summary

Three files touched, three commits:

1. `feat: add Claude Code Stop hook script for session-end checks` — new `scripts/claude-stop-hook.sh`
2. `feat(claude): add permissions block and Stop hook to settings` — modify `.claude/settings.json`
3. (Already committed by the brainstorming phase): `spec: claude settings hardening design`

No production code touched. No runtime dependencies added. No existing hooks changed.
