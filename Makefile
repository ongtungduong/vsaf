# VSAF v3 — Agentic AI SDLC Framework
# Day-to-day operations via Make targets.
# Run `make help` for available commands.

.PHONY: help setup index scan scan-deep verify review archive status mine clean

SHELL := /bin/bash

# ── Setup ──────────────────────────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: ## Run full VSAF setup (install all tools)
	@bash scripts/setup-vsaf.sh

# ── Knowledge Graph ────────────────────────────────────────────────────────────

index: ## Re-index codebase (GitNexus + Graphify)
	@echo "==> Re-indexing codebase..."
	gitnexus analyze
	@if command -v graphify &>/dev/null; then \
		graphify . --update 2>/dev/null || echo "[WARN] graphify update failed — run '/graphify . --update' in Claude Code"; \
	fi
	@echo "==> Index complete"

# ── Security ───────────────────────────────────────────────────────────────────

scan: ## Run AgentShield security scan
	npx ecc-agentshield scan

scan-deep: ## Run AgentShield deep scan (Opus + streaming)
	npx ecc-agentshield scan --opus --stream

# ── Review (3-layer) ──────────────────────────────────────────────────────────

verify: ## Layer 2: Check implementation against OpenSpec specs
	openspec verify

review: ## Run 3-layer review (methodology + spec + re-index)
	@echo "==> Layer 1: Methodology review"
	@echo "    Run in Claude Code: /superpowers:code-review"
	@echo ""
	@echo "==> Layer 2: Spec compliance"
	openspec verify
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

# ── Memory ─────────────────────────────────────────────────────────────────────

mine: ## Mine conversations into MemPalace knowledge base
	mempalace mine ~/chats/ --mode convos --extract general

# ── Status ─────────────────────────────────────────────────────────────────────

status: ## Show status of all tools
	@echo "==> GitNexus"
	@gitnexus status 2>/dev/null || echo "    [not indexed]"
	@echo ""
	@echo "==> MemPalace"
	@mempalace status 2>/dev/null || echo "    [not initialized]"
	@echo ""
	@echo "==> OpenSpec"
	@openspec list 2>/dev/null || echo "    [no active changes]"
	@echo ""
	@echo "==> Graphify output"
	@ls graphify-out/ 2>/dev/null || echo "    [no output — run '/graphify .' in Claude Code]"
	@echo ""
	@echo "==> claude-mem"
	@curl -sf http://localhost:37777 >/dev/null 2>&1 && echo "    Web viewer: http://localhost:37777" || echo "    [web viewer not running]"

# ── Maintenance ────────────────────────────────────────────────────────────────

clean: ## Clean GitNexus index (requires confirmation)
	@read -p "This will remove the GitNexus index. Continue? [y/N] " confirm && \
		[ "$$confirm" = "y" ] && gitnexus clean || echo "Aborted."
