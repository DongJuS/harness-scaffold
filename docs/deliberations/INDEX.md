# deliberations

## Purpose

AI reasoning traces that capture the thinking process behind non-trivial choices —
what options were weighed, what concerns arose, and what heuristics were applied.
Separate from final decisions (ADRs) to preserve the reasoning journey itself.

## Files

- `./TEMPLATE.md` — Deliberation template used by scripts/new-deliberation.sh to create new entries
- No deliberation entries yet — use `scripts/new-deliberation.sh "Question"` to create the first one

## Dependencies

- `../../scripts/new-deliberation.sh` — Script that generates new deliberation entries from the template

## Related

- `../../CLAUDE.md` — AI agent rules that reference deliberation conventions
- `../decisions/` — Architecture Decision Records (the outcomes deliberations feed into)
- `../journals/` — AI work journals (related documentation type)
- `../` — Parent docs directory linking all documentation systems
