# Glossary — HarnessScaffold Project Terms

## Purpose

Alphabetically sorted glossary of terms, conventions, and abbreviations used
in the HarnessScaffold project. Every project-specific term used in any document
should have an entry here. When writing a document, define acronyms inline on
first use AND ensure they appear in this glossary.

## Terms

| Term | Definition |
|------|------------|
| ADR | Architecture Decision Record — a structured document recording an architectural decision, its context, options considered, and reasoning. Lives in `docs/decisions/`. |
| AUTHORITY.md | The Single Source of Truth (SSOT) registry (`docs/AUTHORITY.md`) that maps each topic to exactly one authoritative document. |
| CLAUDE.md | The AI agent rules file at project root that defines conventions and workflows all AI agents must follow when working in this repository. |
| CONFLICTS.md | Auto-generated conflict report (`docs/CONFLICTS.md`) listing detected contradictions between documents with severity levels. |
| DELIB | Deliberation log — an AI reasoning trace capturing the thought process behind a non-trivial choice. Lives in `docs/deliberations/`. |
| GLOSSARY.md | This file — the project-wide glossary of terms and abbreviations. |
| HarnessScaffold | The name of this project — a self-documenting hierarchical repository scaffold where every file stays under 200 lines and every directory has INDEX.md navigation indexes. |
| INDEX.md | A navigation file present in every content directory that maps purposes to files with relative paths and one-line descriptions. |
| JOURNAL | An AI work journal entry recording what was done in a session — tasks performed, files changed, problems encountered, and solutions applied. Lives in `docs/journals/`. |
| REGISTRY.md | The root-level file listing all sub-repos with their relative paths, git remote URLs, and one-line purposes. |
| SSOT | Single Source of Truth — the principle that each topic has exactly one authoritative document, tracked in `docs/AUTHORITY.md`. |
| Sub-repo | A self-contained repository directory under `repos/` (e.g., `repos/core/`, `repos/services/`, `repos/config/`) holding a specific domain of the project. |
| Supersede chain | The linked chain of Architecture Decision Records (ADRs) where deprecated decisions include a forward pointer to their replacement, ensuring no one follows stale decisions. |
| TIMELINE.md | Auto-generated chronological list of all log entries (ADRs, journals, deliberations) in `docs/TIMELINE.md`. |

## How to Update

When using a new project-specific term in any document:

1. Add the term to the table above in alphabetical order
2. In the source document, define the term inline on first use OR link here
3. Run `scripts/check-writing.sh` to verify no undefined acronyms remain
