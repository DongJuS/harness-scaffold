# Session Changelog

This file is an append-only log where each session records significant changes
as they happen. Other sessions use this log (via `scripts/session-sync.sh`) to
detect what changed while they were working, preventing conflicts from building
on outdated assumptions.

## How to Use

- **Broadcasting a change:** Run `scripts/session-broadcast.sh <session-id> <type> "<message>" "<paths>"`
- **Syncing with others:** Run `scripts/session-sync.sh <session-id>` to see changes from other sessions
- **Types:** `file-change` | `decision` | `warning` | `blocker`

## Rules

1. Broadcast after any significant change (new file, new ADR, structural change)
2. Sync every 3-5 task completions to catch up with other sessions
3. Never edit or remove existing entries — this log is append-only

## Entries

_(no entries yet)_
