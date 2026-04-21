# File Claims

This file is a lock registry where sessions claim ownership of files or
directories before modifying them. Claiming prevents two sessions from
editing the same file simultaneously, which would cause merge conflicts
and inconsistent state.

## How to Use

- **Claiming a path:** Run `scripts/session-claim.sh <path> <session-id> "<reason>"`
- **Releasing claims:** Run `scripts/session-end.sh <session-id>` to release all claims for a session
- **Checking claims:** Read this file to see which paths are owned by which sessions

## Rules

1. A path can only be claimed by one active session at a time
2. Claims on directories cover all files within that directory
3. Claims are released automatically when a session ends via `scripts/session-end.sh`
4. If a claim conflicts with your intended work, coordinate with the owning session or wait

## Claims

| Path | Claimed By | Since | Reason |
|------|------------|-------|--------|
| _(no active claims)_ | | | |
