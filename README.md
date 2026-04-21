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

## Example: Building a New Feature

**Scenario:** Thêm tính năng "export báo cáo ra PDF".

---

**Step 1 — Spec** · *Bạn làm*

```
/opsx:propose export báo cáo ra PDF
```

> AI tạo spec file với danh sách tasks, edge cases, acceptance criteria. Bạn review và approve.

---

**Step 2 — Impact Analysis** · *AI làm tự động*

AI chạy GitNexus để tìm các module bị ảnh hưởng:

```
gitnexus_impact({target: "ReportService", direction: "upstream"})
```

> AI báo cáo: "3 module phụ thuộc vào ReportService. Recommend tách thành 2 PR."
> Bạn quyết định: tách PR hay giữ nguyên.

---

**Step 3 — Brainstorm + Plan** · *AI dẫn dắt, bạn approve*

```
/superpowers:brainstorm
```

> AI đề xuất 3 approach (wkhtmltopdf / Puppeteer / server-side LaTeX), phân tích trade-off, recommend Puppeteer.
> Bạn chọn approach → AI tạo implementation plan với từng task 2–5 phút.
> Bạn review plan, approve.

---

**Step 4 — Execute** · *AI làm, bạn theo dõi*

```
/superpowers:execute-plan
```

> AI code từng task theo TDD (viết test trước, implement sau), commit sau mỗi task.
> Nếu task fail 3 lần, AI dừng lại và báo cáo để bạn quyết định hướng đi.

---

**Step 5 — Review + Ship** · *AI làm, bạn approve merge*

```
/superpowers:code-review   # AI review methodology
make verify                # OpenSpec kiểm tra spec compliance
make scan                  # AgentShield quét bảo mật
git push origin feature/export-pdf
```

> Bạn review PR, merge.

---

| Bước | Con người | AI |
|---|---|---|
| Spec | Mô tả feature, approve spec | Tạo spec, edge cases |
| Impact | Quyết định có split PR không | Chạy blast radius analysis |
| Brainstorm | Trả lời câu hỏi, chọn approach, approve plan | Đề xuất options, tạo plan |
| Execute | Theo dõi, unblock nếu AI stuck | Code, test, commit từng task |
| Review | Review PR, approve merge | Chạy 3-layer review, scan bảo mật |

---

**Core principles:** Spec before code. Context is king. 3-layer review before every PR.
