# sessions

## Purpose

Multi-session coordination system for parallel AI and developer sessions. Tracks
which sessions are active, what files each session has claimed, and prevents
conflicts when multiple sessions modify the project simultaneously.

## Files

- `./ACTIVE.md` — Live registry of all currently running sessions with their status and work areas
- `./CLAIMS.md` — File-level lock registry where sessions claim ownership of files or directories before modifying them
- `./CHANGELOG.md` — Append-only log where sessions broadcast significant changes for cross-session awareness

## Dependencies

- `../scripts/session-start.sh` — Registers a new session in ACTIVE.md and checks for conflicts
- `../scripts/session-claim.sh` — Claims a file or directory for a session in CLAIMS.md
- `../scripts/session-end.sh` — Releases all claims and marks a session as completed
- `../scripts/session-broadcast.sh` — Appends a change entry to CHANGELOG.md for other sessions
- `../scripts/session-sync.sh` — Shows other sessions' changes since last sync, highlights conflicts

## Related

- `../HANDOFF.md` — Session handoff document updated at end of each session
- `../docs/journals/` — Historical records of completed session work
