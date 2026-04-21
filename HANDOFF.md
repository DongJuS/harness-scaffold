# HANDOFF.md — Session Handoff Document

This file captures the current state of the HarnessScaffold project so that the
next AI agent or developer can continue work immediately without re-discovering
project state. HarnessScaffold is a self-documenting hierarchical repository
scaffold where every file stays under 200 lines and every directory has an
INDEX.md navigation index.

This document is overwritten every session. Historical records are in
`docs/journals/` (AI work journal entries recording tasks, changes, and learnings).

---

## Last Updated

2026-04-22T23:00:00+09:00

## Session ID

No journal entry created yet for this session. Previous sessions documented in
`scripts/ralph/progress.txt` (Ralph Loop progress log tracking each user story).

## Completed This Session

- [x] US-017: Created HANDOFF.md (this file), a living session handoff document
  that gets overwritten each session to tell the next agent exactly where work
  left off, what is in progress, and what to do next.
- [x] Created `scripts/validate-handoff.sh` to check HANDOFF.md for completeness,
  freshness, self-contained language, and valid file references.

## In Progress

No items are currently in progress. US-017 was completed fully this session.

## Next Up

**US-018: Create cascading rollback system for decisions** (priority 18)

This story adds dependency tracking to Architecture Decision Records (ADRs).
The ADR template at `docs/decisions/TEMPLATE.md` needs a new "Depends On" field.
Two new scripts are needed: `scripts/rollback-decision.sh` (cascading deprecation
of an ADR and all downstream dependents) and `scripts/show-decision-tree.sh`
(ASCII visualization of ADR dependency graph). CLAUDE.md needs a new rule about
filling the Depends On field and using rollback instead of manual deprecation.

## Blockers

None. All structural validation passes. No conflicts detected.

## Warnings

- CLAUDE.md is at ~170 lines (limit is 200). Future stories adding rules must be
  extremely concise — consider consolidating or splitting if it approaches the limit.
- `scripts/validate.sh` is at ~149 lines. Similar headroom concern.
- BSD sed on macOS has quirks with multi-line operations — use head/tail with temp
  files instead of sed `a\` for multi-line insertions. See Codebase Patterns in
  `scripts/ralph/progress.txt` for all known gotchas.

## Files Recently Changed

- `./HANDOFF.md` — Created: session handoff document (this file)
- `./scripts/validate-handoff.sh` — Created: validates HANDOFF.md completeness and quality
- `./CLAUDE.md` — Updated: added Session Handoff section with 3 handoff rules
- `./scripts/INDEX.md` — Updated: added validate-handoff.sh entry
- `./docs/AUTHORITY.md` — Updated: added session handoff authority entry
