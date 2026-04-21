# Writing Standard — Self-Contained Document Rules

## Purpose

This document defines the self-contained writing rules for all documents in the
HarnessScaffold project (a self-documenting repository scaffold where every file
stays under 200 lines and every directory has navigation indexes). Every document
must be fully understandable by someone with zero prior context — no implicit
knowledge, no abbreviations without expansion, no references without summaries.

## Rule 1: Background Section Required

Every template-based document (Architecture Decision Records, journals,
deliberation logs) must open with a "Background" section that explains the full
situation from scratch — what project this is, what problem exists, why this
document was created. Write as if the reader has never seen this project before.

## Rule 2: No Context-Dependent Phrases

Never use phrases that assume prior context:

- "as mentioned" / "as discussed" / "as noted above"
- "see above" / "the above issue"
- "we agreed" / "as we decided" (without restating what was agreed/decided)
- "this problem" / "the issue is" (without defining the problem first)

Always restate the full context instead of referencing invisible conversations.

## Rule 3: Expand All Acronyms

Every acronym and abbreviation must be expanded on first use, even
project-internal ones. Write "Architecture Decision Record (ADR)" on first
use, then "ADR" thereafter within the same document.

## Rule 4: Describe All Links

Every reference to another document must include both the relative path AND
a one-sentence summary of what that document contains. Never use bare links.

- Bad: `See ./decisions/ADR-001.md`
- Good: `See ./decisions/ADR-001.md — defines the 200-line file limit and INDEX.md navigation convention`

## Rule 5: Define Technical Terms

Every technical term specific to this project must be defined inline or linked
to `./GLOSSARY.md` — the project-wide glossary of terms and abbreviations. If
a reader cannot look up the term in a standard dictionary, explain it.

## Rule 6: Restate Decision Context

When describing a decision, always restate the full problem context, not just
the solution. The reader must understand WHY the decision was made, not just
WHAT was decided.

## Enforcement

Run `scripts/check-writing.sh` to scan documents for violations. The script
checks for:

1. Banned phrases (context-dependent language)
2. Bare links without summary descriptions
3. Undefined acronyms (all-caps terms not expanded in the document)
4. Missing Background section in template-based documents
5. Documents under a minimum content threshold (too short to be self-contained)

The script outputs a quality report with file paths, line numbers, and
suggested resolutions. Errors must be fixed; warnings should be reviewed.
