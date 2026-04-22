#!/usr/bin/env bash
# onboard-repo.sh — Apply ASF config to an existing git repository.
# Usage: bash scripts/onboard-repo.sh <TARGET_DIR>
set -euo pipefail

# ---------------------------------------------------------------------------
# Colors / logging
# ---------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
skip()  { echo -e "${YELLOW}[SKIP]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }
step()  { echo -e "\n${CYAN}==> $*${NC}"; }

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------
if [ $# -eq 0 ]; then
    echo "Usage: bash scripts/onboard-repo.sh <TARGET_DIR>"
    echo ""
    echo "  TARGET_DIR  Path to the existing git repository to onboard."
    echo ""
    echo "Example:"
    echo "  bash scripts/onboard-repo.sh /path/to/my-project"
    exit 1
fi

TARGET="$1"

if ! git -C "$TARGET" rev-parse --git-dir &>/dev/null 2>&1; then
    fail "Not a git repository: $TARGET"
fi

TARGET="$(cd "$TARGET" && pwd)"
ASF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ""
echo "============================================================"
echo "  ASF — Onboarding Existing Repository"
echo "  Target: $TARGET"
echo "============================================================"

# ---------------------------------------------------------------------------
# 1. Copy files — always overwrite
# ---------------------------------------------------------------------------
step "Copying ASF system prompts (always overwrite)"

for f in CLAUDE.md AGENTS.md; do
    if [ -f "$ASF_DIR/$f" ]; then
        cp "$ASF_DIR/$f" "$TARGET/$f"
        ok "$f → updated"
    else
        warn "$f not found in ASF — skipped"
    fi
done

# ---------------------------------------------------------------------------
# 2. Copy files / dirs — skip if already exist
# ---------------------------------------------------------------------------
step "Copying ASF config files (skip if already exist)"

copy_if_absent() {
    local name="${1%/}"   # strip trailing slash for path checks
    local src="$ASF_DIR/$name"
    local dst="$TARGET/$name"
    if [ ! -e "$dst" ]; then
        if [ -e "$src" ]; then
            rsync -a "$src" "$TARGET/"
            ok "$1 → copied"
        else
            warn "$1 not found in ASF — skipped"
        fi
    else
        skip "$1 already exists"
    fi
}

copy_if_absent "Makefile"
copy_if_absent "githooks/"
copy_if_absent ".claude/"
copy_if_absent ".github/"
copy_if_absent ".agent/"

# ---------------------------------------------------------------------------
# 3. Merge .gitignore (append ASF entries, idempotent)
# ---------------------------------------------------------------------------
step "Merging .gitignore"

ASF_GITIGNORE="$ASF_DIR/.gitignore"
TARGET_GITIGNORE="$TARGET/.gitignore"
MARKER="# ASF entries"

if grep -qF "$MARKER" "$TARGET_GITIGNORE" 2>/dev/null; then
    skip ".gitignore already contains ASF entries"
elif [ -f "$ASF_GITIGNORE" ]; then
    {
        if [ -f "$TARGET_GITIGNORE" ]; then echo ""; fi
        echo "$MARKER"
        cat "$ASF_GITIGNORE"
    } >> "$TARGET_GITIGNORE"
    ok ".gitignore → ASF entries appended"
else
    warn ".gitignore not found in ASF — skipped"
fi

# ---------------------------------------------------------------------------
# 4. Configure git hooks path
# ---------------------------------------------------------------------------
step "Configuring git hooks path"

git -C "$TARGET" config core.hooksPath githooks/
ok "core.hooksPath = githooks/"

# ---------------------------------------------------------------------------
# 5. Index repository with GitNexus
# ---------------------------------------------------------------------------
step "Indexing repository (gitnexus analyze)"

if command -v gitnexus &>/dev/null; then
    if gitnexus analyze "$TARGET" 2>/dev/null; then
        ok "GitNexus index complete"
    else
        warn "gitnexus analyze failed — run manually: gitnexus analyze $TARGET"
    fi
else
    warn "gitnexus not found — run manually after installing: gitnexus analyze $TARGET"
fi

# ---------------------------------------------------------------------------
# 6. Final instructions
# ---------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "  Onboarding complete."
echo ""
echo "  Manual step required (inside Claude Code):"
echo ""
echo "    /plugin install superpowers@claude-plugins-official"
echo ""
echo "  Then restart Claude Code."
echo "============================================================"
echo ""
