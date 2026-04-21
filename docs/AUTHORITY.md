# Authority Registry — Single Source of Truth

This file maps each topic or domain in the HarnessScaffold project to exactly
ONE authoritative document. For any given topic, there is only one row. If you
find conflicting information in another document, the document listed here wins.

## Rules

- Each topic has exactly ONE authoritative document — no duplicates
- When a document is superseded, update this table to point to the replacement
- If a topic is not listed, there is no established authority — propose one via ADR
- Deprecated documents must be removed from this table immediately

## Authority Table

| Topic / Domain | Authoritative Document | Last Verified |
|---|---|---|
| File size convention (200-line limit) | `./decisions/ADR-001.md` — Adopts the 200-line file limit with reasoning and trade-offs | 2026-04-22 |
| Directory structure convention (INDEX.md) | `./decisions/ADR-001.md` — Adopts the INDEX.md navigation convention | 2026-04-22 |
| Naming convention (files, directories) | `../CLAUDE.md` — Defines file and directory naming rules for AI agents | 2026-04-22 |
| Logging convention (AI work journals) | `./journals/TEMPLATE.md` — Defines the structure for AI work session logs | 2026-04-22 |
| Decision logging convention (ADR) | `./decisions/TEMPLATE.md` — Defines the structure for architecture decision records | 2026-04-22 |
| Deliberation logging convention | `./deliberations/TEMPLATE.md` — Defines the structure for AI reasoning traces | 2026-04-22 |
| Config management | `../repos/config/INDEX.md` — Entry point for environment configuration architecture | 2026-04-22 |
| Core sub-repo architecture | `../repos/core/INDEX.md` — Shared types, utils, and constants structure | 2026-04-22 |
| Services sub-repo architecture | `../repos/services/INDEX.md` — Business logic module structure and example service | 2026-04-22 |
| Config sub-repo architecture | `../repos/config/INDEX.md` — Environment-based configuration with base/dev/prod split | 2026-04-22 |
| Sub-repo registry | `../REGISTRY.md` — Master list of all sub-repos with paths and purposes | 2026-04-22 |
| AI agent rules | `../CLAUDE.md` — All rules AI agents must follow when working in this repo | 2026-04-22 |
| Project timeline | `./TIMELINE.md` — Chronological view of all log entries (auto-generated) | 2026-04-22 |
| Validation rules | `../scripts/validate.sh` — Enforces structural rules: line counts, INDEX.md, registry | 2026-04-22 |
| Writing standard | `./WRITING-STANDARD.md` — Self-contained writing rules all documents must follow | 2026-04-22 |
| Project glossary | `./GLOSSARY.md` — Alphabetical glossary of all project-specific terms and abbreviations | 2026-04-22 |
| Context loading strategy | `../START-HERE.md` — Task-type-specific reading lists for efficient context loading | 2026-04-22 |
| Session handoff | `../HANDOFF.md` — Living document capturing current project state for next session | 2026-04-22 |

## How to Update This Table

1. When creating a new ADR that establishes authority on a new topic, add a row here
2. When superseding an ADR, update the row to point to the new ADR
3. When deprecating a document, remove its row — deprecated docs are never authoritative
4. Run `scripts/validate.sh` after any changes to verify referenced files exist
