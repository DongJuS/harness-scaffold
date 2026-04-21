#!/usr/bin/env bash
# Claims a file or directory for a session in sessions/CLAIMS.md.
# Prevents two sessions from editing the same file simultaneously.
# Usage: scripts/session-claim.sh <path> <session-id> "<reason>"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAIMS="$ROOT_DIR/sessions/CLAIMS.md"
ACTIVE="$ROOT_DIR/sessions/ACTIVE.md"

if [ $# -lt 3 ]; then
  echo "Usage: $0 <path> <session-id> \"<reason>\""
  echo "  path:       File or directory to claim (relative to project root)"
  echo "  session-id: Your session ID from session-start.sh"
  echo "  reason:     What you intend to do with this path"
  echo ""
  echo "Example: $0 \"repos/core/types\" \"SESSION-core-20260422-143000\" \"Adding new shared types\""
  exit 1
fi

CLAIM_PATH="$1"
SESSION_ID="$2"
REASON="$3"

if [ ! -f "$CLAIMS" ]; then
  echo "Error: sessions/CLAIMS.md not found. Run from project root."
  exit 1
fi

# Verify session is active
if [ -f "$ACTIVE" ]; then
  if ! grep -q "$SESSION_ID" "$ACTIVE" 2>/dev/null; then
    echo "Error: Session '$SESSION_ID' not found in ACTIVE.md."
    echo "Register first with: scripts/session-start.sh <name> <work-area>"
    exit 1
  fi
  if ! grep "$SESSION_ID" "$ACTIVE" | grep -q '| active |'; then
    echo "Error: Session '$SESSION_ID' is not active."
    exit 1
  fi
fi

# Check for existing claims that conflict
CONFLICT=0
while IFS='|' read -r _ path claimed_by _ _; do
  path=$(echo "$path" | xargs)
  claimed_by=$(echo "$claimed_by" | xargs)
  [ -z "$path" ] && continue
  [[ "$path" == "_"* ]] && continue

  # Check if the new claim overlaps with an existing one
  if [ "$path" = "$CLAIM_PATH" ] || \
     echo "$CLAIM_PATH" | grep -q "^${path}" 2>/dev/null || \
     echo "$path" | grep -q "^${CLAIM_PATH}" 2>/dev/null; then
    if [ "$claimed_by" = "$SESSION_ID" ]; then
      echo "You already own '$path'. No action needed."
      exit 0
    fi
    echo "CONFLICT: Path '$CLAIM_PATH' overlaps with '$path'"
    echo "  Claimed by: $claimed_by"
    echo "  You must coordinate with that session before proceeding."
    CONFLICT=1
  fi
done < <(grep '^|' "$CLAIMS" | grep -v '^| Path' | grep -v '^|---')

if [ "$CONFLICT" -eq 1 ]; then
  exit 1
fi

# Add the claim
ISO_TIME=$(date +%Y-%m-%dT%H:%M:%S)
NEW_ROW="| ${CLAIM_PATH} | ${SESSION_ID} | ${ISO_TIME} | ${REASON} |"

TEMP_FILE=$(mktemp)
if grep -q '_(no active claims)_' "$CLAIMS" 2>/dev/null; then
  awk -v row="$NEW_ROW" '/_\(no active claims\)_/{print row; next}{print}' "$CLAIMS" > "$TEMP_FILE"
else
  cp "$CLAIMS" "$TEMP_FILE"
  echo "$NEW_ROW" >> "$TEMP_FILE"
fi
mv "$TEMP_FILE" "$CLAIMS"

echo "Claimed: $CLAIM_PATH"
echo "  Session: $SESSION_ID"
echo "  Reason:  $REASON"
