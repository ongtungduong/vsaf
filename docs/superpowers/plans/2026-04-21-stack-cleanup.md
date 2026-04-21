# Stack Cleanup — 5-Tool Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce ASF from 8-tool stack to 5-tool stack by deleting excess files and rewriting all affected config/docs in one atomic pass.

**Architecture:** Delete 6 paths (BMAD, MemPalace artifacts, old docs, Cursor, Codex). Rewrite 4 files (CLAUDE.md, Makefile, setup-asf.sh, README.md). AGENTS.md requires no changes — it is already purely GitNexus content.

**Tech Stack:** Bash, Markdown, Make

---

### Task 1: Delete excess files and directories

**Files:**
- Delete: `_bmad/`
- Delete: `mempalace.yaml`
- Delete: `entities.json`
- Delete: `docs/onboarding/`
- Delete: `.cursor/`
- Delete: `.codex/`

- [ ] **Step 1: Delete all six paths**

```bash
rm -rf _bmad/ mempalace.yaml entities.json docs/onboarding/ .cursor/ .codex/
```

- [ ] **Step 2: Verify deletions**

```bash
ls _bmad mempalace.yaml entities.json docs/onboarding .cursor .codex 2>&1
```

Expected output: six "No such file or directory" errors (one per path).

- [ ] **Step 3: Verify kept paths are untouched**

```bash
ls openspec/ githooks/ .claude/settings.json .github/ .agent/ scripts/setup-asf.sh Makefile CLAUDE.md README.md AGENTS.md
```

Expected: all paths exist with no errors.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: delete BMAD, MemPalace, Graphify, Cursor, Codex artifacts"
```

---

### Task 2: Rewrite CLAUDE.md

**Files:**
- Modify: `CLAUDE.md` lines 1–220 (replace entirely; keep lines 221–322 — the `<!-- gitnexus:start -->` block — intact)

- [ ] **Step 1: Write new CLAUDE.md**

Replace the entire file with the content below. The GitNexus block (lines 221–322 in the original) is preserved verbatim at the end.

```markdown
# ASF — Agentic SDLC Framework

> System prompt for Claude Code. Do not remove or override.
> Spec-driven development. 3-layer review. 5-tool stack.

---

## Identity

This project uses the **ASF (Agentic SDLC Framework)**.

**Stack:**

| Layer | Tool |
|---|---|
| Spec | OpenSpec |
| Code intelligence | GitNexus (MCP) |
| Implementation | Claude Code + Superpowers + AgentShield |

**Supported platforms:** Claude Code (primary) | GitHub Copilot | Antigravity

---

## 5-Step Workflow

### Step 1: Spec
```bash
/opsx:propose <feature>
git commit -m "spec: <feature>"
```
Tasks must be atomic (2-5 min). Include edge cases.

### Step 2: Impact Analysis
```
gitnexus_impact({target: "symbol", direction: "upstream"})
gitnexus_context({name: "symbol"})
```
Impact > 3 modules → split PRs. Update specs if new edge cases found.

### Step 3: Brainstorm + Plan
```
/superpowers:brainstorm
/superpowers:write-plan
```
Do not approve until every task has a verification step.

### Step 4: Execute
```
/superpowers:execute-plan
```
- 1 commit per task.
- Tests after EVERY task.
- Fail 3x on same task → stop, architectural review.

### Step 5: Review + Ship
```bash
/superpowers:code-review
/opsx:verify
npx ecc-agentshield scan
git push origin feature/<name>
/opsx:archive
```

---

## Tool Commands — Quick Reference

| Action | Command |
|---|---|
| OpenSpec propose | `/opsx:propose <feature>` |
| OpenSpec verify | `/opsx:verify` |
| OpenSpec archive | `/opsx:archive` |
| Superpowers brainstorm | `/superpowers:brainstorm` |
| Superpowers plan | `/superpowers:write-plan` |
| Superpowers execute | `/superpowers:execute-plan` |
| Superpowers review | `/superpowers:code-review` |
| AgentShield scan | `npx ecc-agentshield scan` |
| AgentShield deep scan | `npx ecc-agentshield scan --opus --stream` |
| GitNexus index | `gitnexus analyze` |
| GitNexus web | `gitnexus serve` |

---

## Anti-Patterns

| Do Not | Instead |
|---|---|
| Write code before specs | `/opsx:propose` first |
| Skip brainstorm | `/superpowers:brainstorm` before planning |
| Push without review | code-review + opsx:verify + agentshield scan |
| Create PRs > 400 lines | Split into smaller PRs |
| Trust AI output blindly | AI writes → Superpowers reviews → human approves |
| Skip impact analysis | GitNexus BEFORE coding |
| Forget to archive | `/opsx:archive` after every merge |

---

## Commit Discipline

- 1 commit per task from the plan.
- Each commit message: `<type>: <description>` (feat, fix, refactor, spec, docs, test).
- Tests must pass after every commit.
- If a task fails 3 times, stop and trigger an architectural review.

---

## Security

- AgentShield hooks active: secrets and protected files are blocked automatically.
- Run `npx ecc-agentshield scan` after any configuration change.
- Run `npx ecc-agentshield scan --opus --stream` before releases.
- Never hardcode credentials. Use environment variables.
- Review `.claude/settings.json` hook rules if a block triggers unexpectedly.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **agentic-sdlc-framework** (291 symbols, 307 relationships, 0 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## When Debugging

1. `gitnexus_query({query: "<error or symptom>"})` — find execution flows related to the issue
2. `gitnexus_context({name: "<suspect function>"})` — see all callers, callees, and process participation
3. `READ gitnexus://repo/agentic-sdlc-framework/process/{processName}` — trace the full execution flow step by step
4. For regressions: `gitnexus_detect_changes({scope: "compare", base_ref: "main"})` — see what your branch changed

## When Refactoring

- **Renaming**: MUST use `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` first. Review the preview — graph edits are safe, text_search edits need manual review. Then run with `dry_run: false`.
- **Extracting/Splitting**: MUST run `gitnexus_context({name: "target"})` to see all incoming/outgoing refs, then `gitnexus_impact({target: "target", direction: "upstream"})` to find all external callers before moving code.
- After any refactor: run `gitnexus_detect_changes({scope: "all"})` to verify only expected files changed.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Tools Quick Reference

| Tool | When to use | Command |
|------|-------------|---------|
| `query` | Find code by concept | `gitnexus_query({query: "auth validation"})` |
| `context` | 360-degree view of one symbol | `gitnexus_context({name: "validateUser"})` |
| `impact` | Blast radius before editing | `gitnexus_impact({target: "X", direction: "upstream"})` |
| `detect_changes` | Pre-commit scope check | `gitnexus_detect_changes({scope: "staged"})` |
| `rename` | Safe multi-file rename | `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` |
| `cypher` | Custom graph queries | `gitnexus_cypher({query: "MATCH ..."})` |

## Impact Risk Levels

| Depth | Meaning | Action |
|-------|---------|--------|
| d=1 | WILL BREAK — direct callers/importers | MUST update these |
| d=2 | LIKELY AFFECTED — indirect deps | Should test |
| d=3 | MAY NEED TESTING — transitive | Test if critical path |

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/agentic-sdlc-framework/context` | Codebase overview, check index freshness |
| `gitnexus://repo/agentic-sdlc-framework/clusters` | All functional areas |
| `gitnexus://repo/agentic-sdlc-framework/processes` | All execution flows |
| `gitnexus://repo/agentic-sdlc-framework/process/{name}` | Step-by-step execution trace |

## Self-Check Before Finishing

Before completing any code modification task, verify:
1. `gitnexus_impact` was run for all modified symbols
2. No HIGH/CRITICAL risk warnings were ignored
3. `gitnexus_detect_changes()` confirms changes match expected scope
4. All d=1 (WILL BREAK) dependents were updated

## Keeping the Index Fresh

After committing code changes, the GitNexus index becomes stale. Re-run analyze to update it:

```bash
npx gitnexus analyze
```

If the index previously included embeddings, preserve them by adding `--embeddings`:

```bash
npx gitnexus analyze --embeddings
```

To check whether embeddings exist, inspect `.gitnexus/meta.json` — the `stats.embeddings` field shows the count (0 means no embeddings). **Running analyze without `--embeddings` will delete any previously generated embeddings.**

> Claude Code users: A PostToolUse hook handles this automatically after `git commit` and `git merge`.

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
```

- [ ] **Step 2: Verify no removed-tool references remain in CLAUDE.md**

```bash
grep -c "bmad\|graphify\|mempalace\|claude-mem\|cursor\|codex" CLAUDE.md || echo "0 matches — clean"
```

Expected: `0 matches — clean`

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: rewrite CLAUDE.md for 5-tool stack"
```

---

### Task 3: Rewrite Makefile

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Write new Makefile**

```makefile
# ASF — Agentic SDLC Framework
# Day-to-day operations via Make targets.
# Run `make help` for available commands.

.PHONY: help setup index scan scan-deep verify review archive status clean

SHELL := /bin/bash

# ── Setup ──────────────────────────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: ## Run full ASF setup (install all tools)
	@bash scripts/setup-asf.sh

# ── Knowledge Graph ────────────────────────────────────────────────────────────

index: ## Re-index codebase (GitNexus)
	@echo "==> Re-indexing codebase..."
	gitnexus analyze
	@echo "==> Index complete"

# ── Security ───────────────────────────────────────────────────────────────────

scan: ## Run AgentShield security scan
	npx ecc-agentshield scan

scan-deep: ## Run AgentShield deep scan (Opus + streaming)
	npx ecc-agentshield scan --opus --stream

# ── Review (3-layer) ──────────────────────────────────────────────────────────

verify: ## Layer 2: Check implementation against OpenSpec specs
	openspec validate --all

review: ## Run 3-layer review (methodology + spec + re-index)
	@echo "==> Layer 1: Methodology review"
	@echo "    Run in Claude Code: /superpowers:code-review"
	@echo ""
	@echo "==> Layer 2: Spec compliance"
	openspec validate --all
	@echo ""
	@echo "==> Layer 3: Re-index knowledge graph"
	$(MAKE) index
	@echo ""
	@echo "==> 3-layer review complete"

# ── Spec Lifecycle ─────────────────────────────────────────────────────────────

archive: ## Archive specs + re-index (post-merge)
	openspec archive
	$(MAKE) index
	@echo "==> Archived and re-indexed"

# ── Status ─────────────────────────────────────────────────────────────────────

status: ## Show status of all tools
	@echo "==> GitNexus"
	@gitnexus status 2>/dev/null || echo "    [not indexed]"
	@echo ""
	@echo "==> OpenSpec"
	@openspec list 2>/dev/null || echo "    [no active changes]"

# ── Maintenance ────────────────────────────────────────────────────────────────

clean: ## Clean GitNexus index (requires confirmation)
	@read -p "This will remove the GitNexus index. Continue? [y/N] " confirm && \
		[ "$$confirm" = "y" ] && gitnexus clean || echo "Aborted."
```

- [ ] **Step 2: Verify removed targets are gone and no removed-tool references remain**

```bash
grep -c "mine\|graphify\|mempalace\|claude-mem" Makefile || echo "0 matches — clean"
```

Expected: `0 matches — clean`

- [ ] **Step 3: Verify make help renders correctly**

```bash
make help
```

Expected: lists `setup`, `index`, `scan`, `scan-deep`, `verify`, `review`, `archive`, `status`, `clean` — no `mine` target.

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "chore: simplify Makefile for 5-tool stack"
```

---

### Task 4: Rewrite scripts/setup-asf.sh

**Files:**
- Modify: `scripts/setup-asf.sh`

- [ ] **Step 1: Write new setup-asf.sh**

```bash
#!/usr/bin/env bash
# setup-asf.sh — ASF — Agentic SDLC Framework setup
# Installs and configures: OpenSpec, GitNexus, AgentShield (ECC hooks), Superpowers (manual).
# Idempotent. Ubuntu 24 / macOS supported.
set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[FAIL]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }
step()  { echo -e "\n${CYAN}==> $*${NC}"; }

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

# ---------------------------------------------------------------------------
# Auto-install missing prerequisites (jq)
# ---------------------------------------------------------------------------
auto_install_prereqs() {
    step "Auto-installing missing prerequisites"
    local OS
    OS=$(detect_os)

    if ! command -v jq &>/dev/null; then
        info "jq not found — attempting auto-install..."
        case "$OS" in
            linux)
                sudo apt install -y jq &>/dev/null \
                    && ok "jq auto-installed (apt)" \
                    || err "Failed to auto-install jq. Install manually: sudo apt install jq"
                ;;
            macos)
                brew install jq &>/dev/null \
                    && ok "jq auto-installed (brew)" \
                    || err "Failed to auto-install jq. Install manually: brew install jq"
                ;;
            *)
                err "Unknown OS — install jq manually: https://jqlang.github.io/jq/"
                ;;
        esac
    else
        ok "No auto-install needed — all installable prerequisites present"
    fi
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_prereqs() {
    step "Checking prerequisites"
    local failed=0

    # Node >= 18
    if command -v node &>/dev/null; then
        NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$NODE_VER" -ge 18 ]; then
            ok "Node.js v$(node -v | sed 's/v//')"
        else
            err "Node.js $(node -v) found — v18+ required. Install: https://nodejs.org/"
            failed=1
        fi
    else
        err "Node.js not found — v18+ required. Install: https://nodejs.org/"
        failed=1
    fi

    if command -v npm &>/dev/null; then
        ok "npm $(npm -v)"
    else
        err "npm not found — install Node.js (includes npm): https://nodejs.org/"
        failed=1
    fi

    if command -v git &>/dev/null; then
        ok "git $(git --version | awk '{print $3}')"
    else
        err "git not found — install: sudo apt install git (Ubuntu) or xcode-select --install (macOS)"
        failed=1
    fi

    if command -v jq &>/dev/null; then
        ok "jq $(jq --version 2>&1 | sed 's/jq-//')"
    else
        err "jq not found — required for AgentShield hook merging. Install: sudo apt install jq (Ubuntu) or brew install jq (macOS)"
        failed=1
    fi

    if [ "$failed" -ne 0 ]; then
        fail "Missing prerequisites. Install them and re-run."
    fi
    ok "All prerequisites satisfied"
}

# ---------------------------------------------------------------------------
# Tool installation helper
# ---------------------------------------------------------------------------
npm_global_install() {
    local pkg="$1"
    local cmd="${2:-$pkg}"
    if command -v "$cmd" &>/dev/null; then
        ok "$cmd already installed"
    else
        info "Installing $pkg..."
        npm install -g "$pkg"
        ok "$cmd installed"
    fi
}

# ---------------------------------------------------------------------------
# 1. OpenSpec
# ---------------------------------------------------------------------------
install_openspec() {
    step "Installing OpenSpec"
    npm_global_install "@fission-ai/openspec@latest" "openspec"
    if [ -f "openspec/config.yaml" ] || [ -f "openspec.json" ]; then
        ok "OpenSpec already initialized"
    else
        openspec init
        ok "OpenSpec initialized"
    fi
}

# ---------------------------------------------------------------------------
# 2. GitNexus
# ---------------------------------------------------------------------------
install_gitnexus() {
    step "Installing GitNexus"
    npm_global_install "gitnexus" "gitnexus"
    info "Running gitnexus setup..."
    gitnexus setup 2>/dev/null || true
    info "Indexing repository..."
    gitnexus analyze . 2>/dev/null || warn "gitnexus analyze failed — run manually after setup"
    ok "GitNexus configured"
}

# ---------------------------------------------------------------------------
# 3. AgentShield (ECC cherry-pick — hooks only)
# ---------------------------------------------------------------------------
install_agentshield() {
    step "Installing AgentShield (ECC hooks)"

    local ECC_DIR="/tmp/ecc"
    local CLAUDE_HOME="${HOME}/.claude"

    if [ ! -d "$ECC_DIR" ]; then
        info "Cloning ECC repository..."
        git clone --depth 1 https://github.com/anthropics/ecc.git "$ECC_DIR" 2>/dev/null \
            || git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git "$ECC_DIR"
    fi

    mkdir -p "$CLAUDE_HOME"
    local TARGET="$CLAUDE_HOME/settings.json"
    [ ! -f "$TARGET" ] && echo '{}' > "$TARGET"

    if [ -f "$ECC_DIR/hooks/hooks.json" ]; then
        info "Merging AgentShield hooks into $TARGET (non-destructive)..."
        local MERGED
        MERGED=$(jq -s '
            .[0] as $existing |
            .[1] as $ecc |
            $existing * {
                hooks: {
                    PreToolUse:  (($existing.hooks.PreToolUse // []) + ($ecc.hooks.PreToolUse // []) | unique_by(.description)),
                    PostToolUse: (($existing.hooks.PostToolUse // []) + ($ecc.hooks.PostToolUse // []) | unique_by(.description))
                }
            }
        ' "$TARGET" "$ECC_DIR/hooks/hooks.json" 2>/dev/null) || true
        if [ -n "$MERGED" ]; then
            echo "$MERGED" > "$TARGET"
            ok "Hooks merged into $TARGET"
        else
            warn "Could not merge hooks — manual merge may be needed"
        fi
    else
        warn "ECC hooks/hooks.json not found — skipping hook merge"
    fi

    rm -rf "$ECC_DIR"
    ok "AgentShield installed (temp clone removed)"
}

# ---------------------------------------------------------------------------
# 4. Superpowers (manual — requires Claude Code interactive session)
# ---------------------------------------------------------------------------
print_superpowers_instructions() {
    step "Superpowers (manual step)"
    local SP_DIR="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
    if [ -d "$SP_DIR" ]; then
        ok "Superpowers already installed"
        return
    fi
    echo ""
    echo "  Superpowers requires an interactive Claude Code session."
    echo "  Run this command inside Claude Code:"
    echo ""
    echo "    /plugin install superpowers@claude-plugins-official"
    echo ""
    echo "  Then restart Claude Code."
    echo ""
    warn "Superpowers cannot be automated — complete manually after this script"
}

# ---------------------------------------------------------------------------
# Git hooks configuration
# ---------------------------------------------------------------------------
configure_git_hooks() {
    step "Configuring git hooks"
    mkdir -p githooks
    git config core.hooksPath githooks/
    ok "Git hooks path set to githooks/"
}

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------
verify_install() {
    step "Verifying installation"
    local pass=0
    local total=0

    verify_cmd() {
        total=$((total + 1))
        if eval "$1" &>/dev/null; then
            ok "$2"
            pass=$((pass + 1))
        else
            warn "$2 — FAILED"
        fi
    }

    verify_cmd "command -v openspec"                   "OpenSpec available"
    verify_cmd "gitnexus status"                       "GitNexus indexed"
    verify_cmd "npx ecc-agentshield --version"         "AgentShield available"
    verify_cmd "test -f ${HOME}/.claude/settings.json" "Global Claude hooks configured"
    verify_cmd "test -f .claude/settings.json"         "Local Claude hooks configured"

    echo ""
    info "Verification: $pass/$total checks passed"
    if [ "$pass" -lt "$total" ]; then
        warn "Some tools need manual attention. See warnings above."
    else
        ok "All verifications passed"
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    echo ""
    echo "============================================================"
    echo "  ASF — Agentic SDLC Framework Setup"
    echo "  Spec-driven development | 3-layer review | 5 tools"
    echo "============================================================"
    echo ""

    auto_install_prereqs
    check_prereqs

    install_openspec
    install_gitnexus
    install_agentshield
    print_superpowers_instructions
    configure_git_hooks

    verify_install

    echo ""
    echo "============================================================"
    echo "  Setup complete. Next steps:"
    echo "  1. Install Superpowers in Claude Code (see instructions above)"
    echo "  2. Run:  make status   (verify all tools)"
    echo "  3. Read: CLAUDE.md     (system prompt / workflow rules)"
    echo "============================================================"
    echo ""
}

main "$@"
```

- [ ] **Step 2: Verify no removed-tool references remain**

```bash
grep -c "bmad\|graphify\|mempalace\|claude-mem\|pipx\|python" scripts/setup-asf.sh || echo "0 matches — clean"
```

Expected: `0 matches — clean`

- [ ] **Step 3: Commit**

```bash
git add scripts/setup-asf.sh
git commit -m "chore: rewrite setup-asf.sh for 5-tool stack"
```

---

### Task 5: Rewrite README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write new README.md**

```markdown
# ASF — Agentic SDLC Framework

A spec-driven development framework. Write specs first, execute with AI, review
in 3 layers. 5-tool stack, $20/month total.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  SPEC              OpenSpec (propose, verify, archive)               │
├──────────────────────────────────────────────────────────────────────┤
│  CODE INTEL        GitNexus (MCP — impact, context, query)           │
├──────────────────────────────────────────────────────────────────────┤
│  IMPLEMENTATION    Claude Code + Superpowers + AgentShield           │
└──────────────────────────────────────────────────────────────────────┘
```

**Supported platforms:** Claude Code (primary) | GitHub Copilot | Antigravity

## Quickstart

Requires **Node.js ≥ 18**, **Git**, **jq**, and a **Claude Code subscription** ($20/mo).

```bash
git clone <this-repo> && cd agentic-sdlc-framework
make setup          # Install tools (idempotent — safe to re-run)
make status         # Verify everything is working
```

One manual post-setup step (requires an interactive Claude Code session):

```
/plugin install superpowers@claude-plugins-official
```

Restart Claude Code after installing Superpowers.

## Directory Layout

```
.
├── .agent/                  # Antigravity config
├── .claude/
│   └── settings.json        # AgentShield hooks: block secrets, protect config
├── .github/                 # GitHub Copilot config
├── docs/
│   └── superpowers/         # Design specs and implementation plans
├── githooks/                # Git hooks (pre-push security scan)
├── openspec/                # OpenSpec workspace (proposals, tasks, verification)
├── scripts/
│   └── setup-asf.sh         # Setup automation (called by make setup)
├── CLAUDE.md                # Claude Code system prompt — workflow rules
└── Makefile                 # All day-to-day operations
```

## Daily Operations

| Command | What It Does |
|---|---|
| `make setup` | Install or update all tools |
| `make index` | Re-index codebase (GitNexus) — run after every merge |
| `make verify` | Check implementation against OpenSpec specs |
| `make review` | Run 3-layer review |
| `make scan` | Run AgentShield security scan |
| `make status` | Show status of installed tools |

## Tools

| Tool | What It Does | Cost |
|---|---|---|
| **Claude Code** | AI coding agent — primary interface | $20/mo |
| **OpenSpec** | Spec-driven development: proposals, specs, tasks, verification | Free |
| **GitNexus** | Code knowledge graph via MCP — impact analysis, dependency queries | Free |
| **Superpowers** | Methodology engine: brainstorm, plan, TDD execution, code review | Free |
| **AgentShield** | Security scanner + git hooks (block secrets, protect config) | Free |

## Workflow

Every feature follows a **5-step cycle**: spec → impact analysis → brainstorm+plan
→ execute → review+ship.

See `CLAUDE.md` for the full workflow rules and quick-reference command table.

---

**Core principles:** Spec before code. Context is king. 3-layer review before every PR.
```

- [ ] **Step 2: Verify no removed-tool references remain**

```bash
grep -c "bmad\|graphify\|mempalace\|claude-mem\|onboarding\|cursor\|codex" README.md || echo "0 matches — clean"
```

Expected: `0 matches — clean`

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README.md for 5-tool stack"
```

---

### Self-Review

**Spec coverage check:**

| Spec requirement | Covered by |
|---|---|
| Delete `_bmad/` | Task 1 |
| Delete `mempalace.yaml` | Task 1 |
| Delete `entities.json` | Task 1 |
| Delete `docs/onboarding/` | Task 1 |
| Delete `.cursor/` | Task 1 |
| Delete `.codex/` | Task 1 |
| Rewrite `CLAUDE.md` (5-step workflow, no removed tools) | Task 2 |
| Rewrite `Makefile` (remove mine, simplify index/status/review) | Task 3 |
| Rewrite `scripts/setup-asf.sh` (4 installable tools only) | Task 4 |
| Rewrite `README.md` (5-tool architecture, updated layout) | Task 5 |
| Keep `AGENTS.md` (already clean — GitNexus only) | No task needed |
| Keep `.claude/settings.json`, `openspec/`, `githooks/`, `.github/`, `.agent/` | No task needed — not touched |
