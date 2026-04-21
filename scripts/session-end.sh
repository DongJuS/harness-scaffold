#!/usr/bin/env bash
# Ends a session: releases all claims, marks status as completed.
# Usage: scripts/session-end.sh <session-id>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ACTIVE="$ROOT_DIR/sessions/ACTIVE.md"
CLAIMS="$ROOT_DIR/sessions/CLAIMS.md"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <session-id>"
  echo "Example: $0 \"SESSION-core-20260422-143000\""
  exit 1
fi

SESSION_ID="$1"

if [ ! -f "$ACTIVE" ]; then
  echo "Error: sessions/ACTIVE.md not found. Run from project root."
  exit 1
fi

# Verify session exists
if ! grep -q "$SESSION_ID" "$ACTIVE" 2>/dev/null; then
  echo "Error: Session '$SESSION_ID' not found in ACTIVE.md."
  exit 1
fi

echo "=== Ending Session: $SESSION_ID ==="
echo ""

# Release all claims for this session
if [ -f "$CLAIMS" ]; then
  RELEASED=0
  TEMP_FILE=$(mktemp)
  while IFS= read -r line; do
    if echo "$line" | grep -q "$SESSION_ID"; then
      CLAIM_PATH=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
      echo "  Released claim: $CLAIM_PATH"
      RELEASED=$((RELEASED + 1))
    else
      echo "$line" >> "$TEMP_FILE"
    fi
  done < "$CLAIMS"
  mv "$TEMP_FILE" "$CLAIMS"

  # If no claims remain, restore the placeholder row
  if ! grep -q '^|' "$CLAIMS" 2>/dev/null || \
     [ "$(grep '^|' "$CLAIMS" | grep -v '^| Path' | grep -v '^|---' | wc -l | tr -d ' ')" -eq 0 ]; then
    # Rebuild the claims table with placeholder
    cat > "$CLAIMS" << 'CLAIMSEOF'
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
CLAIMSEOF
  fi

  echo ""
  echo "  Released $RELEASED claim(s)."
fi

# Update session status to completed in ACTIVE.md
TEMP_FILE=$(mktemp)
awk -v sid="$SESSION_ID" '{
  if (index($0, sid) > 0) {
    gsub(/\| active \|/, "| completed |")
  }
  print
}' "$ACTIVE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$ACTIVE"

echo ""
echo "Session '$SESSION_ID' marked as completed."
echo ""
echo "Reminders:"
echo "  1. Update HANDOFF.md with current state: what was done, what is next"
echo "  2. Create a journal entry if significant work was completed"
echo "  3. Run scripts/update-timeline.sh if any log entries were created"
