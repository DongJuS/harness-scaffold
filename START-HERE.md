# START-HERE.md — Context Loading Guide

This file tells AI agents and developers exactly which files to read based on
the type of task they are about to perform. HarnessScaffold is a self-documenting
hierarchical repository scaffold where every file stays under 200 lines and every
directory has an INDEX.md navigation index. Reading the right files first avoids
wasting time and context window budget on irrelevant documents.

## How to Use

1. Determine your task type from the sections below
2. Read ONLY the files listed, in the order shown
3. Do not read documents outside the list unless a document you read directs you to another
4. Each list is capped at 7 files to force prioritization over completeness

---

## First Time in This Repo

Read these files to understand the full project structure and conventions.

1. `./CLAUDE.md` — All rules for working in this repo: 200-line limit, INDEX.md convention, registry updates, validation workflow, and automation scripts
2. `./REGISTRY.md` — Master list of all sub-repos with paths, remotes, and one-line purposes; includes Quick Start clone instructions
3. `./docs/AUTHORITY.md` — Single Source of Truth registry mapping each topic to exactly one authoritative document; tells you where to look for any given concern
4. `./docs/WRITING-STANDARD.md` — Self-contained writing rules that every document must follow; defines banned phrases, acronym expansion, and background section requirements
5. `./docs/GLOSSARY.md` — Alphabetical glossary of all project-specific terms (ADR, sub-repo, HarnessScaffold, etc.) with definitions

---

## Adding a New Sub-Repo

Read these files before creating a new sub-repo under `repos/`.

1. `./REGISTRY.md` — Check what sub-repos already exist and how they are registered; your new sub-repo must be added here
2. `./scripts/INDEX.md` — Find the `new-repo.sh` script that automates sub-repo scaffolding with INDEX.md and registry entry
3. `./repos/core/INDEX.md` — Reference example of a well-structured sub-repo with types/, utils/, constants/ subdirectories

---

## Adding a New File to an Existing Sub-Repo

Read these files before creating or modifying files in an existing sub-repo.

1. `./REGISTRY.md` — Locate the sub-repo you need to work in by path and purpose
2. The target sub-repo's `INDEX.md` — Understand what files already exist so you do not duplicate; find the right directory for your new file

---

## Making a New Architectural Decision

Read these files before proposing or recording an architectural choice.

1. `./docs/decisions/INDEX.md` — See all existing ADRs (Architecture Decision Records) to check if your topic is already covered
2. `./docs/AUTHORITY.md` — Verify which document currently owns the topic you are deciding about; if one exists, you must supersede it rather than create a parallel decision
3. `./docs/decisions/TEMPLATE.md` — ADR template with required fields: ID, Date, Status, Background, Context, Options, Decision, Reasoning, Consequences, Supersedes, Depends On, Glossary References
4. `./scripts/INDEX.md` — Find `new-decision.sh` for auto-generating ADRs with incremented IDs, and `supersede-decision.sh` for deprecating old decisions

---

## Debugging / Investigating an Issue

Read these files to understand the project state and trace the history of changes.

1. `./docs/TIMELINE.md` — Reverse-chronological list of all ADRs, journals, and deliberations; shows what changed and when
2. `./docs/AUTHORITY.md` — Find the authoritative document for the area you are investigating; do not trust non-authoritative documents if they conflict
3. `./scripts/validate.sh` — Run this script to detect structural issues: files over 200 lines, missing INDEX.md, unregistered sub-repos, document conflicts, writing quality violations

---

## Continuing Work from a Previous Session

Read these files to pick up where the last session left off without re-discovering state.

1. `./HANDOFF.md` — If this file exists, read it FIRST; it contains what the previous session completed, what is in progress, what to do next, and what to watch out for
2. `./docs/TIMELINE.md` — Review recent entries to understand what changed since you last worked; entries are reverse-chronological across all log types
3. `./docs/journals/INDEX.md` — Find the most recent journal entry for detailed task-by-task accounting of the last session, including problems encountered and solutions applied
4. `./CLAUDE.md` — Re-read the rules to ensure you follow all conventions; rules may have been updated by the previous session

---

## Creating a New Log Entry (Journal, Deliberation, or ADR)

Read these files before writing any log entry.

1. `./docs/WRITING-STANDARD.md` — All log entries must follow self-contained writing rules: background section, no context-dependent phrases, expanded acronyms, described links
2. `./docs/GLOSSARY.md` — Reference project-specific terms and their definitions; use these terms consistently and link to this glossary in your Glossary References section
3. The relevant `TEMPLATE.md` in `docs/decisions/`, `docs/journals/`, or `docs/deliberations/` — Follow the exact field structure; do not omit required fields
