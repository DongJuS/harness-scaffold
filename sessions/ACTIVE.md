# Active Sessions

This file is the live registry of all currently running sessions in the
project. Each session registers here on start and updates its status on
completion. This enables multiple concurrent AI or developer sessions to
coordinate and avoid conflicting work.

## How to Use

- **Starting a session:** Run `scripts/session-start.sh <name> <work-area>` to register
- **Ending a session:** Run `scripts/session-end.sh <session-id>` to mark complete
- **Checking status:** Read this file to see who is working on what

## Sessions

| Session ID | Started | Owner | Working On | Status | Branch |
|------------|---------|-------|------------|--------|--------|
| _(no active sessions)_ | | | | | |
