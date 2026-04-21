# scripts

## Purpose

Automation scripts for project scaffolding, validation, and maintenance. All scripts are portable bash and work on macOS (BSD) and Linux.

## Files

- `./create-index.sh` — Generates an INDEX.md skeleton for a given directory, auto-detecting existing files
- `./new-repo.sh` — Scaffolds a new sub-repo with INDEX.md, .gitignore, and registers it in REGISTRY.md
- `./new-file.sh` — Creates a new file with 200-line-limit header and updates the parent INDEX.md
- `./validate.sh` — Checks structural rules: file line counts, INDEX.md presence, REGISTRY.md completeness
- `./new-decision.sh` — Generates a new ADR file from template with auto-incremented ID
- `./new-journal.sh` — Generates a new journal entry from template with auto-incremented ID
- `./new-deliberation.sh` — Generates a new deliberation log from template with auto-incremented ID
- `./update-timeline.sh` — Scans all log directories and regenerates docs/TIMELINE.md
- `./supersede-decision.sh` — Deprecates an old ADR and links it to its replacement, updating AUTHORITY.md and TIMELINE.md
- `./check-conflicts.sh` — Scans for document conflicts: duplicate topics, deprecated authorities, orphaned references
- `./check-writing.sh` — Checks documents for self-contained writing quality: banned phrases, bare links, undefined acronyms, missing Background
- `./validate-handoff.sh` — Validates HANDOFF.md for completeness (all fields filled), freshness, self-contained language, and valid file references

## Dependencies

- `../REGISTRY.md` — Read and updated by new-repo.sh; read by validate.sh
- `../templates/INDEX-TEMPLATE.md` — Reference template used by create-index.sh

## Related

- `../setup.sh` — Root-level setup script that initializes all sub-repos
- `../templates/` — Template files used by these scripts
