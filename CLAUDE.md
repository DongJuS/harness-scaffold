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

## Workflow

Before committing any changes:

1. Run `scripts/validate.sh` to catch structural issues
2. Verify all new directories have INDEX.md
3. Verify all new sub-repos are in REGISTRY.md
4. Verify no file exceeds 200 lines

## Directory Structure

```
./
├── REGISTRY.md          — Master list of all sub-repos
├── CLAUDE.md            — This file: AI agent rules
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

## Conventions Summary

- Files: max 200 lines, single responsibility
- Directories: always have INDEX.md
- Sub-repos: always registered in REGISTRY.md
- Navigation: INDEX.md first, then act
- Splitting: when a file grows, split and update INDEX.md
- Validation: run `scripts/validate.sh` before every commit
