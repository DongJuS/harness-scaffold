# Session Collaboration Policy

## Writing Standard

Every document you write must pass `scripts/check-writing.sh`. Write every sentence
as if the reader just opened this one file with zero context about the project. If
you reference a concept, define it. If you reference a decision, restate it. If you
reference a file, explain what it contains. See `docs/WRITING-STANDARD.md` for full
rules and `docs/GLOSSARY.md` for project term definitions.

## Session Handoff

At the END of every work session, update HANDOFF.md with current state before
finishing — this is the LAST thing you do. At the START of every session, if
HANDOFF.md exists, read it FIRST before START-HERE.md. Write HANDOFF.md as if the
next reader is a completely different AI with no knowledge of what you did.

## Context Loading

At the start of every session, determine your task type and follow the reading
list in START-HERE.md. Do not read documents outside the list unless a document
you read explicitly directs you to another.

## Cross-Session Sync

Before modifying any file, run `scripts/session-claim.sh` to claim it. After
any significant change, run `scripts/session-broadcast.sh` to notify other sessions.
Every 3-5 task completions, run `scripts/session-sync.sh` to check what others did.

## Role-Based Review

Before starting any task, run `scripts/activate-roles.sh <task-type>` to determine
which role profiles to read. After completing work, run `scripts/role-review.sh` to
generate and complete a review. All critical issues must be resolved before marking
done. Save completed reviews to `docs/reviews/`.

## Dashboard

Run `scripts/update-dashboard.sh` after completing any task, review, or session change.
DASHBOARD.md is auto-generated — never edit it manually.
