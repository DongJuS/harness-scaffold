# Logs and Decisions Policy

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
