# Core Structure Policy

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

## Directory Structure

```
./
├── REGISTRY.md          — Master list of all sub-repos
├── CLAUDE.md            — Policy entry point and routing guide
├── policies/            — Topic-based policy files
├── DASHBOARD.md         — Project status dashboard (auto-generated)
├── HANDOFF.md           — Session handoff: current state for next agent
├── START-HERE.md        — Context loading guide: which files to read per task type
├── setup.sh             — Clone-and-initialize automation
├── repos/               — All sub-repos live here
│   ├── core/            — Shared types, utils, constants
│   ├── services/        — Business logic modules
│   └── config/          — Environment configuration
├── scripts/             — Automation and tooling
└── templates/           — Reusable templates (INDEX.md, etc.)
```
