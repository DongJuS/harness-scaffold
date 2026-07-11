# Automation and Workflow Policy

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
