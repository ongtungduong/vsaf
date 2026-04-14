# VSAF v3 — Agentic AI SDLC Framework

> System prompt for Claude Code. Do not remove or override.
> Spec-driven development. 3-layer review. 8 integrated tools.

---

## Identity

This project uses the **VSAF v3 (Agentic AI SDLC Framework)**. All development
follows the 10-step workflow below. No code ships without spec compliance and
3-layer review.

---

## Memory Management

### claude-mem (auto-pilot)
- claude-mem handles session continuity automatically. **Do not duplicate** its work.
- Session context is auto-injected on start. No manual action needed.
- Web viewer: http://localhost:37777

### MemPalace (knowledge base)
- Call `mempalace_search` **BEFORE** answering about past decisions, architecture
  rationale, or "why did we choose X" questions.
- Use `mempalace_add_drawer` for important decisions worth preserving verbatim.
- Write `mempalace_diary_write` at end of meaningful sessions.
- Run `mempalace mine ~/chats/ --mode convos` weekly to capture decision history.

### Separation of Concerns
| claude-mem | MemPalace |
|---|---|
| Session recall, debug history | Architecture decisions, team knowledge |
| Auto-compressed summaries | Verbatim lossless storage |
| "What file did I change yesterday?" | "Why did we choose Patroni over Stolon?" |
| Lossy — may lose reasoning chain | Temporal KG with stale fact invalidation |

**Anti-pattern:** Do not use MemPalace for session recall. Do not use claude-mem
for architecture decisions. Do not dump knowledge into CLAUDE.md.

---

## Knowledge Graph

### GitNexus (MCP backbone)
- Use GitNexus MCP tools for impact analysis before any code change.
- Query: "What breaks if I change X?" before touching cross-module code.
- Re-index after every merge: `gitnexus analyze`

### Graphify (multimodal KG)
- Read `graphify-out/GRAPH_REPORT.md` **before** answering architecture questions.
- Use `/graphify query "question"` for structural queries.
- Use `/graphify path ServiceA ServiceB` to trace dependency paths.
- Re-build after merge: `/graphify . --update`

### Mandatory Re-indexing
After every merge or significant change:
```
gitnexus analyze && /graphify . --update
```
Or: `make index`

---

## 10-Step Workflow

### Step 0: Setup (one-time)
```bash
make setup   # runs scripts/setup-vsaf.sh
```

### Step 1: Understand Codebase
- Read `graphify-out/GRAPH_REPORT.md` first.
- Run `gitnexus serve` for web UI exploration.
- Query MemPalace for past team decisions.
- Do not modify code on day one.

### Step 2: Scope
```
*agent analyst          # BMAD: clarify scope
*workflow-init          # Quick/Standard/Enterprise
bmad-help               # What's next?
```
Quick Flow (bug fix) --> skip to Step 6.

### Step 3: Planning (skip for Quick Flow)
```
*agent pm               # PRD: FRs, NFRs, Epics
*agent architect         # Architecture doc
*agent po               # Sprint stories
git add docs/ && git commit -m "feat: PRD + arch for <feature>"
```

### Step 4: Specs (skip for Quick Flow)
```
/opsx:propose <feature>
/opsx:ff                # Fast-forward all docs
git add openspec/ && git commit -m "spec: <feature>"
```
Tasks must be atomic (2-5 min). Include edge cases.

### Step 5: Impact Analysis
```
"What breaks if I change PaymentService?"    # GitNexus MCP
/graphify path PaymentService NotificationService
mempalace search "PaymentService refactor"   # Past attempts
```
Impact > 3 modules --> split PRs. Update specs if new edge cases found.

### Step 6: Brainstorm + Plan
```
/superpowers:brainstorm       # Socratic Q&A, explore alternatives
/superpowers:write-plan       # Bite-sized tasks + verification steps
```
Do not approve until every task has a verification step.

### Step 7: Execute
```
/superpowers:execute-plan     # RED -> GREEN -> REFACTOR per task
```
- 1 commit per task.
- Tests after EVERY task.
- Fail 3x on same task --> stop, do architectural review.
- ECC hooks fire passively (block secrets, protect config).

### Step 8: Self-Review (3-layer -- MANDATORY)
```bash
# Layer 1: Methodology compliance
/superpowers:code-review

# Layer 2: Spec compliance
/opsx:verify               # or: make verify

# Layer 3: Knowledge graph sync
make index                  # gitnexus analyze + graphify update
```
If Layer 2 fails --> return to Step 7.
After config changes: `npx ecc-agentshield scan` (or: `make scan`).

### Step 9: Push PR
```bash
git push origin feature/<name>
```
PR description must include: OpenSpec proposal link, impact summary, test results.

### Step 10: Archive + Ship
```bash
make archive                # openspec archive + re-index
mempalace mine ~/chats/ --mode convos   # Mine decisions
git tag v<version> && git push --tags
```

---

## Tool Commands — Quick Reference

| Action | Command |
|---|---|
| BMAD analyst | `*agent analyst` |
| BMAD PRD | `*agent pm` |
| BMAD architect | `*agent architect` |
| BMAD next step | `bmad-help` |
| OpenSpec propose | `/opsx:propose <feature>` |
| OpenSpec fast-forward | `/opsx:ff` |
| OpenSpec verify | `/opsx:verify` |
| OpenSpec archive | `/opsx:archive` |
| Superpowers brainstorm | `/superpowers:brainstorm` |
| Superpowers plan | `/superpowers:write-plan` |
| Superpowers execute | `/superpowers:execute-plan` |
| Superpowers review | `/superpowers:code-review` |
| ECC scan | `npx ecc-agentshield scan` |
| ECC deep scan | `npx ecc-agentshield scan --opus --stream` |
| GitNexus index | `gitnexus analyze` |
| GitNexus web | `gitnexus serve` |
| Graphify build | `/graphify .` |
| Graphify query | `/graphify query "question"` |
| Graphify update | `/graphify . --update` |
| MemPalace search | `mempalace search "query"` |
| MemPalace mine | `mempalace mine ~/chats/ --mode convos` |
| MemPalace status | `mempalace status` |
| claude-mem viewer | `http://localhost:37777` |

---

## Anti-Patterns

| Do Not | Instead |
|---|---|
| Write code before specs | Spec first, code second: `/opsx:propose` |
| Skip brainstorm | `/superpowers:brainstorm` before planning |
| Push without review | 3-layer: Superpowers + OpenSpec verify + re-index |
| Forget to re-index | `make index` after every merge |
| Create PRs > 400 lines | Split into smaller PRs |
| Trust AI output blindly | AI writes -> Superpowers reviews -> human approves |
| Skip impact analysis | GitNexus + Graphify + MemPalace BEFORE coding |
| Dump knowledge into CLAUDE.md | CLAUDE.md = rules. claude-mem = sessions. MemPalace = decisions |
| Install full ECC plugin | Cherry-pick only: AgentShield + hooks + language skills |
| Use MemPalace for session recall | claude-mem auto-handles session continuity |
| Use claude-mem for architecture decisions | MemPalace verbatim + temporal KG for decisions |
| Skip MemPalace mining | `mempalace mine` weekly for architecture decisions |

---

## Commit Discipline

- 1 commit per task from the plan.
- Each commit message: `<type>: <description>` (feat, fix, refactor, spec, docs, test).
- Tests must pass after every commit.
- If a task fails 3 times, stop and trigger an architectural review.

---

## Security

- ECC hooks are active: secrets and protected files are blocked automatically.
- Run `npx ecc-agentshield scan` after any configuration change.
- Run `make scan-deep` before releases.
- Never hardcode credentials. Use environment variables.
- Review `.claude/settings.json` hook rules if a block triggers unexpectedly.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **vsaf** (27 symbols, 16 relationships, 0 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

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
3. `READ gitnexus://repo/vsaf/process/{processName}` — trace the full execution flow step by step
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
| `gitnexus://repo/vsaf/context` | Codebase overview, check index freshness |
| `gitnexus://repo/vsaf/clusters` | All functional areas |
| `gitnexus://repo/vsaf/processes` | All execution flows |
| `gitnexus://repo/vsaf/process/{name}` | Step-by-step execution trace |

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
