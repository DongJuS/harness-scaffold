#!/usr/bin/env bash
# Registers a new session in sessions/ACTIVE.md and checks for conflicts.
# Usage: scripts/session-start.sh <session-name> <work-area>
# Example: scripts/session-start.sh "core-refactor" "repos/core"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ACTIVE="$ROOT_DIR/sessions/ACTIVE.md"
CLAIMS="$ROOT_DIR/sessions/CLAIMS.md"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <session-name> <work-area>"
  echo "  session-name: Short identifier for this session (e.g. 'core-refactor')"
  echo "  work-area:    Sub-repo or path this session will focus on (e.g. 'repos/core')"
  echo ""
  echo "Example: $0 \"auth-feature\" \"repos/services/auth\""
  exit 1
fi

SESSION_NAME="$1"
WORK_AREA="$2"

if [ ! -f "$ACTIVE" ]; then
  echo "Error: sessions/ACTIVE.md not found. Run from project root."
  exit 1
fi

# Generate a unique session ID from name + timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SESSION_ID="SESSION-${SESSION_NAME}-${TIMESTAMP}"
ISO_TIME=$(date +%Y-%m-%dT%H:%M:%S)

# Detect current git branch
BRANCH=$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || echo "unknown")

# Check for overlapping active sessions
echo "=== Session Registration ==="
echo ""
echo "Checking for conflicts with active sessions..."

CONFLICTS=0
while IFS='|' read -r _ sid _ owner working_on status _; do
  sid=$(echo "$sid" | xargs)
  status=$(echo "$status" | xargs)
  working_on=$(echo "$working_on" | xargs)

  [ "$status" = "active" ] || continue

  if echo "$working_on" | grep -qi "$WORK_AREA" 2>/dev/null; then
    echo "  WARNING: Session '$sid' is already working on '$working_on'"
    CONFLICTS=$((CONFLICTS + 1))
  fi
done < <(grep '^|' "$ACTIVE" | grep -v '^| Session ID' | grep -v '^|---')

if [ "$CONFLICTS" -gt 0 ]; then
  echo ""
  echo "  Found $CONFLICTS overlapping session(s) in work area '$WORK_AREA'."
  echo "  Proceeding anyway — coordinate with the other session(s) to avoid conflicts."
  echo ""
fi

# Check CLAIMS.md for existing claims on this work area
if [ -f "$CLAIMS" ]; then
  CLAIM_CONFLICTS=0
  while IFS='|' read -r _ path claimed_by _ _; do
    path=$(echo "$path" | xargs)
    claimed_by=$(echo "$claimed_by" | xargs)
    [ -z "$path" ] && continue
    [[ "$path" == "_"* ]] && continue

    if echo "$WORK_AREA" | grep -q "$path" 2>/dev/null || \
       echo "$path" | grep -q "$WORK_AREA" 2>/dev/null; then
      echo "  WARNING: Path '$path' is claimed by session '$claimed_by'"
      CLAIM_CONFLICTS=$((CLAIM_CONFLICTS + 1))
    fi
  done < <(grep '^|' "$CLAIMS" | grep -v '^| Path' | grep -v '^|---')

  if [ "$CLAIM_CONFLICTS" -gt 0 ]; then
    echo ""
    echo "  Found $CLAIM_CONFLICTS file claim(s) overlapping with '$WORK_AREA'."
    echo "  Use scripts/session-claim.sh to check specific paths before modifying."
  fi
fi

# Register the session in ACTIVE.md
NEW_ROW="| ${SESSION_ID} | ${ISO_TIME} | ${SESSION_NAME} | ${WORK_AREA} | active | ${BRANCH} |"

TEMP_FILE=$(mktemp)
if grep -q '_(no active sessions)_' "$ACTIVE" 2>/dev/null; then
  awk -v row="$NEW_ROW" '/_\(no active sessions\)_/{print row; next}{print}' "$ACTIVE" > "$TEMP_FILE"
else
  cp "$ACTIVE" "$TEMP_FILE"
  echo "$NEW_ROW" >> "$TEMP_FILE"
fi
mv "$TEMP_FILE" "$ACTIVE"

echo ""
echo "Session registered:"
echo "  ID:        $SESSION_ID"
echo "  Work Area: $WORK_AREA"
echo "  Branch:    $BRANCH"
echo "  Status:    active"
echo ""
echo "Next steps:"
echo "  1. Claim files before modifying: scripts/session-claim.sh <path> $SESSION_ID \"reason\""
echo "  2. When done: scripts/session-end.sh $SESSION_ID"
