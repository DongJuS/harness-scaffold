# CLAUDE.md — AI Agent Rules for HarnessScaffold

This file defines the rules and conventions that any AI agent (or developer) must
follow when working in this repository. These rules maintain the architectural
integrity of the self-documenting scaffold.

## Core Rules

### 1. 200-Line File Limit

Every file in this repository must stay under 200 lines. No exceptions.

- Before saving any file, check its line count
- When a file approaches 200 lines, split it into smaller focused files
- After splitting, update the parent directory's INDEX.md to reflect the new files
- Run `scripts/validate.sh` to verify compliance before committing

### 2. INDEX.md Convention

Every directory with content must have an INDEX.md that maps purposes to files.

- **Before creating or modifying files**, check the INDEX.md in the target directory
  to understand what already exists and where new content belongs
- When you **add a new file** to a directory, update that directory's INDEX.md
  to include the new file with a one-line description
- When you **remove a file**, remove its entry from INDEX.md
- When you **rename a file**, update its INDEX.md entry
- Use `scripts/create-index.sh <dir>` to generate a new INDEX.md from the template
- INDEX.md format: `- \`./filename\` — what this file does and when to use it`

### 3. Registry Updates

All sub-repos must be registered in the root REGISTRY.md.

- When you **add a new sub-repo** under `repos/`, register it in REGISTRY.md
- Use `scripts/new-repo.sh <name> "<purpose>"` to scaffold a new sub-repo —
  it automatically registers in REGISTRY.md
- When removing a sub-repo, remove its REGISTRY.md entry

### 4. File Navigation

Always navigate before acting:

1. Start at `REGISTRY.md` to find the right sub-repo
2. Read the sub-repo's `INDEX.md` to find the right directory
3. Read the directory's `INDEX.md` to find the right file
4. Only then create or modify files

Do not create files without first checking whether a suitable file already exists
in the target directory's INDEX.md.

## Automation Scripts

Use the provided scripts to maintain consistency:

| Script | Purpose |
|--------|---------|
| `scripts/validate.sh` | Check all files under 200 lines, all dirs have INDEX.md, all repos registered |
| `scripts/create-index.sh <dir>` | Generate INDEX.md skeleton for a directory |
| `scripts/new-repo.sh <name> "<desc>"` | Scaffold a new sub-repo with INDEX.md and register it |
| `scripts/new-file.sh <path> "<desc>"` | Create a new file with header comment and update INDEX.md |
| `scripts/new-journal.sh "<objective>"` | Create a new journal entry with auto-incremented ID |
| `scripts/new-deliberation.sh "<question>"` | Create a new deliberation log with auto-incremented ID |
| `scripts/update-timeline.sh` | Regenerate docs/TIMELINE.md from all log entries |
| `scripts/supersede-decision.sh OLD NEW` | Deprecate an ADR and link it to its replacement |
| `scripts/check-conflicts.sh` | Detect document conflicts, orphaned refs, deprecated authorities |
| `scripts/check-writing.sh` | Check documents for self-contained writing quality violations |
| `scripts/validate-handoff.sh` | Validate HANDOFF.md for completeness, freshness, and file references |
| `scripts/rollback-decision.sh ID` | Cascade-deprecate an ADR and all ADRs that depend on it |
| `scripts/show-decision-tree.sh` | Visualize ADR dependency graph as ASCII tree |
| `scripts/session-broadcast.sh` | Broadcast a change to sessions/CHANGELOG.md for cross-session sync |
| `scripts/session-sync.sh` | Show other sessions' changes since last sync, flag conflicts |
| `scripts/activate-roles.sh <type>` | Look up ROUTING.md, output activated roles and combined checklist |
| `scripts/role-review.sh` | Generate pre-filled role review, or check completed review for critical issues |
| `scripts/verify.sh` | Run verification pipeline: typecheck, lint, test, build per sub-repo |
| `scripts/verify-report.sh` | Generate verification report in docs/reviews/ from verify.sh output |
| `scripts/update-dashboard.sh` | Regenerate DASHBOARD.md from all project sources |

## Workflow

Before committing any changes:

1. Run `scripts/verify.sh` to run the full verification pipeline (structure, conflicts, writing)
2. If any check fails, fix the code and re-run until all pass
3. Only proceed to role review after all verification checks pass
4. Never mark a task complete without a passing verification

## Directory Structure

```
./
├── REGISTRY.md          — Master list of all sub-repos
├── CLAUDE.md            — This file: AI agent rules
├── DASHBOARD.md         — Project status dashboard (auto-generated)
├── HANDOFF.md           — Session handoff: current state for next agent (overwritten each session)
├── START-HERE.md        — Context loading guide: which files to read per task type
├── setup.sh             — Clone-and-initialize automation
├── repos/               — All sub-repos live here
│   ├── core/            — Shared types, utils, constants
│   ├── services/        — Business logic modules
│   └── config/          — Environment configuration
├── scripts/             — Automation and tooling
│   ├── validate.sh      — Structure validation
│   ├── create-index.sh  — INDEX.md generator
│   ├── new-repo.sh      — Sub-repo scaffolder
│   └── new-file.sh      — File creator with INDEX.md update
└── templates/           — Reusable templates (INDEX.md, etc.)
```

## AI Work Journals

After completing any significant work session, create a journal entry before finishing:

- Use `scripts/new-journal.sh "<objective>"` to generate a new entry
- Fill in all fields: tasks performed, files changed, problems, solutions, open questions
- Journal entries live in `docs/journals/` with IDs like JOURNAL-001, JOURNAL-002, etc.

## Deliberation Logs

When facing a non-trivial choice (multiple valid approaches, unclear trade-offs,
or architectural impact), create a deliberation log before proceeding:

- Use `scripts/new-deliberation.sh "<question>"` to generate a new entry
- Fill in all fields: constraints, step-by-step thinking, conclusion, confidence level
- Deliberation entries live in `docs/deliberations/` with IDs like DELIB-001, DELIB-002, etc.
- Link to related ADRs and journal entries where applicable

## Timeline

After creating any log entry (ADR, journal, or deliberation), run `scripts/update-timeline.sh`
to regenerate `docs/TIMELINE.md` with the new entry in chronological order.

## Authority Registry

Before acting on information from any document, check `docs/AUTHORITY.md` to confirm
that document is the current authority for that topic. If the document is not listed
or is marked deprecated, do not follow it.

## Decision Supersede Chain

Never follow a decision marked deprecated. Always follow the supersede chain to
the latest active decision. Use `scripts/supersede-decision.sh OLD_ID NEW_ID` to
deprecate an ADR — it updates both ADRs, AUTHORITY.md, and TIMELINE.md automatically.

## Cascading Rollback

When adding a new ADR, always fill in the Depends On field honestly. When you
realize a past decision was wrong, use `scripts/rollback-decision.sh` instead of
manually deprecating — it finds all downstream decisions you might miss.

## Conflict Detection

Before starting any work session, run `scripts/check-conflicts.sh`. If critical
conflicts exist, resolve them before proceeding with new work. When creating a
new decision that touches a topic already covered by an existing decision, you
MUST use `scripts/supersede-decision.sh` — never create a parallel competing decision.

## Writing Standard

Every document you write must pass `scripts/check-writing.sh`. Write every sentence
as if the reader just opened this one file with zero context about the project. If
you reference a concept, define it. If you reference a decision, restate it. If you
reference a file, explain what it contains. See `docs/WRITING-STANDARD.md` for full
rules and `docs/GLOSSARY.md` for project term definitions.

## Session Handoff

At the END of every work session, update HANDOFF.md with current state before
finishing — this is the LAST thing you do. At the START of every session, if
HANDOFF.md exists, read it FIRST before START-HERE.md. Write HANDOFF.md as if the
next reader is a completely different AI with no knowledge of what you did.

## Context Loading

At the start of every session, determine your task type and follow the reading
list in START-HERE.md. Do not read documents outside the list unless a document
you read explicitly directs you to another.

## Cross-Session Sync

Before modifying any file, run `scripts/session-claim.sh` to claim it. After
any significant change, run `scripts/session-broadcast.sh` to notify other sessions.
Every 3-5 task completions, run `scripts/session-sync.sh` to check what others did.

## Role-Based Review

Before starting any task, run `scripts/activate-roles.sh <task-type>` to determine
which role profiles to read. After completing work, run `scripts/role-review.sh` to
generate and complete a review. All critical issues must be resolved before marking
done. Save completed reviews to `docs/reviews/`.

## External Projects

When this project connects to another project:

- Both projects must register each other in their `REGISTRY.md` External Projects table
- Use relationship types: `depends-on`, `provides-to`, `shares-with`, or `related`
- When referencing an external project in any document, always include the project
  name, its URL/path, and a one-sentence description of what it does
- Before modifying code that an external project depends on, check that project's
  REGISTRY.md to understand the dependency direction
- See START-HERE.md "Connecting to Another Project" for the full reading list

## Dashboard

Run `scripts/update-dashboard.sh` after completing any task, review, or session change.
DASHBOARD.md is auto-generated — never edit it manually.
