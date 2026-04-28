# HarnessScaffold

> **DO NOT MODIFY THIS REPOSITORY DIRECTLY.**
> This is a **template repository** — its sole purpose is to be cloned/copied to create new projects.
> All changes should be made in the cloned project, not here.
> If you believe the template itself needs improvement, make sure you understand this purpose first
> and confirm that the change is intended for the template, not for a specific project.

A self-documenting, AI-agent-ready repository template for solo full-stack developers.

## Philosophy

- **Every file under 200 lines** — forced decomposition for readability
- **Every directory has INDEX.md** — "for X purpose, go to this file" navigation
- **Self-contained docs** — any document is understandable with zero prior context
- **Role-based review** — 8 professional perspectives (product, architect, backend, frontend, data, devops, security, finance), activated only when relevant
- **Multi-session coordination** — multiple AI sessions can work in parallel without conflicts
- **Decision traceability** — every choice logged with alternatives, reasoning, and dependency chain

## Quick Start

```bash
# Clone the template
git clone https://github.com/YOUR_USERNAME/harness-scaffold.git my-project
cd my-project

# Initialize
./setup.sh

# Start working
# 1. Edit prd.json with your user stories
# 2. Run Ralph Loop (optional)
./scripts/ralph/ralph.sh --tool claude 10
```

## Directory Structure

```
./
├── README.md              — This file
├── CLAUDE.md              — AI agent rules (200-line limit, INDEX.md, workflow)
├── REGISTRY.md            — Master list of all sub-repos
├── START-HERE.md          — Context loading guide per task type
├── HANDOFF.md             — Session handoff for next AI agent
├── DASHBOARD.md           — Auto-generated project status
├── prd.json               — Product requirements for Ralph Loop
├── setup.sh               — One-command project initialization
│
├── repos/                 — Sub-repos (your actual code goes here)
│   ├── core/              — Shared types, utils, constants (EXAMPLE)
│   ├── services/          — Business logic modules (EXAMPLE)
│   └── config/            — Environment configuration (EXAMPLE)
│
├── docs/                  — All documentation and logs
│   ├── AUTHORITY.md       — Single source of truth per topic
│   ├── GLOSSARY.md        — Project term definitions
│   ├── WRITING-STANDARD.md — Self-contained writing rules
│   ├── TIMELINE.md        — Chronological view of all log entries
│   ├── decisions/         — Architecture Decision Records (ADR)
│   ├── journals/          — AI work session journals
│   ├── deliberations/     — AI reasoning trace logs
│   └── reviews/           — Role-based review records
│
├── roles/                 — 8 professional role profiles
│   ├── ROUTING.md         — Task type -> role mapping
│   ├── product.md         — CEO/PM perspective
│   ├── architect.md       — CTO/system design perspective
│   ├── backend.md         — Backend developer perspective
│   ├── frontend.md        — Frontend developer perspective
│   ├── data.md            — Data engineer / AI scientist perspective
│   ├── devops.md          — DevOps perspective
│   ├── security.md        — Security perspective
│   └── finance.md         — Cost/budget perspective
│
├── sessions/              — Multi-session coordination
│   ├── ACTIVE.md          — Currently running sessions
│   ├── CLAIMS.md          — File ownership locks
│   └── CHANGELOG.md       — Cross-session change notifications
│
├── scripts/               — Automation (all under 200 lines each)
│   ├── validate.sh        — Structure, conflict, writing quality check
│   ├── verify.sh          — Code verification: typecheck, lint, test, build
│   ├── activate-roles.sh  — Determine relevant roles for a task
│   ├── role-review.sh     — Generate and check role-based reviews
│   ├── check-conflicts.sh — Detect document contradictions
│   ├── check-writing.sh   — Enforce self-contained writing standard
│   ├── new-repo.sh        — Scaffold a new sub-repo
│   ├── new-file.sh        — Create file + update INDEX.md
│   ├── new-decision.sh    — Create new ADR
│   ├── new-journal.sh     — Create new work journal entry
│   ├── new-deliberation.sh — Create new deliberation log
│   ├── supersede-decision.sh — Deprecate and replace an ADR
│   ├── rollback-decision.sh  — Cascade-rollback a bad decision
│   ├── session-start.sh   — Register a new session
│   ├── session-claim.sh   — Claim file ownership
│   ├── session-end.sh     — Release claims, mark complete
│   ├── session-sync.sh    — Check other sessions' changes
│   ├── session-broadcast.sh — Notify other sessions
│   ├── update-timeline.sh — Regenerate TIMELINE.md
│   └── update-dashboard.sh — Regenerate DASHBOARD.md
│
└── templates/             — Reusable templates
    └── INDEX-TEMPLATE.md  — INDEX.md skeleton
```

## About Example Code

`repos/core/`, `repos/services/`, and `repos/config/` contain **example reference implementations** showing the intended structure. You can:

- **Keep them** as a starting point and modify for your project
- **Delete them** and create your own sub-repos with `scripts/new-repo.sh`
- **Use them as reference** to understand the conventions, then replace

## Prerequisites

- **git** — version control
- **jq** — JSON processing (`brew install jq` on macOS)
- **Claude Code** — optional, for Ralph Loop (`npm install -g @anthropic-ai/claude-code`)

## Ralph Loop (Optional)

Ralph Loop runs AI agents in an autonomous loop, one user story per iteration:

```bash
# Edit prd.json with your user stories, then:
./scripts/ralph/ralph.sh --tool claude 10
```

## Version Control Workflow

This template uses **GitHub push as the primary version control method**.

```bash
# After completing work or reaching a milestone:
git add -A
git commit -m "feat: description of what changed"
git push origin main

# For Ralph Loop work, use feature branches:
git push origin ralph/your-branch-name
```

- Every meaningful change gets committed and pushed to GitHub
- Clone from GitHub to start a new project or restore any previous state
- Ralph Loop automatically commits per user story — push after the loop completes

## License

MIT
