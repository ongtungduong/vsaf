#!/usr/bin/env bash
# Session-end verification hook for Claude Code.
# Checks staged files for secrets and debug artifacts.
set -euo pipefail

cd "${PROJECT_DIR:-.}" 2>/dev/null || exit 0

ISSUES=""

# Check for hardcoded secrets in staged files
SECRETS=$(git diff --cached --diff-filter=ACM --name-only 2>/dev/null \
  | xargs grep -lE 'AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|sk-[a-zA-Z0-9]{48}|xox[bpoas]-|BEGIN.*PRIVATE' 2>/dev/null) || true

if [ -n "$SECRETS" ]; then
  ISSUES="${ISSUES}WARNING: Possible secrets staged: ${SECRETS} "
fi

# Check for debug artifacts in staged files
LOGS=$(git diff --cached --name-only 2>/dev/null \
  | xargs grep -lE 'console[.]log|debugger' 2>/dev/null) || true

if [ -n "$LOGS" ]; then
  ISSUES="${ISSUES}WARNING: Debug artifacts in staged files: ${LOGS} "
fi

if [ -n "$ISSUES" ]; then
  echo "$ISSUES"
fi
