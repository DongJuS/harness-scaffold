# docs

## Purpose

Project documentation including architecture decisions, AI work journals,
and deliberation logs. Each subdirectory holds a specific type of record.

## Files

- `./decisions/` — Architecture Decision Records (ADRs) tracing why choices were made
- `./journals/` — AI work journal entries recording session tasks, changes, and learnings
- `./deliberations/` — AI reasoning traces capturing thought process behind non-trivial choices
- `./TIMELINE.md` — All entries across all log types in reverse chronological order (auto-generated)
- `./AUTHORITY.md` — Single Source of Truth registry mapping each topic to exactly one authoritative document
- `./CONFLICTS.md` — Auto-generated conflict report listing detected issues with severity and resolution suggestions
- `./WRITING-STANDARD.md` — Self-contained writing rules that all documents must follow
- `./GLOSSARY.md` — Project-wide glossary of terms, conventions, and abbreviations
- `./reviews/` — Role-based review records with per-role checklists, issue tracking, and verdicts

## Dependencies

- `../scripts/` — Scripts that generate and manage documentation entries

## Related

- `../CLAUDE.md` — AI agent rules that reference documentation conventions
- `../REGISTRY.md` — Master registry of all sub-repos in the project
