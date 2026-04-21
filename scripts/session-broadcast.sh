#!/usr/bin/env bash
# Appends a new entry to sessions/CHANGELOG.md to notify other sessions.
# Usage: scripts/session-broadcast.sh <session-id> <type> "<message>" "<paths>"
# Types: file-change | decision | warning | blocker
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANGELOG="$ROOT_DIR/sessions/CHANGELOG.md"
ACTIVE="$ROOT_DIR/sessions/ACTIVE.md"

if [ $# -lt 4 ]; then
  echo "Usage: $0 <session-id> <type> \"<message>\" \"<paths>\""
  echo "  session-id: Your session ID from session-start.sh"
  echo "  type:       file-change | decision | warning | blocker"
  echo "  message:    One-sentence description of what changed and why"
  echo "  paths:      Comma-separated list of affected file/directory paths"
  echo ""
  echo "Example: $0 \"SESSION-core-20260422-143000\" file-change \\"
  echo "  \"Added shared Result type to core types\" \"repos/core/types/common.ts\""
  exit 1
fi

SESSION_ID="$1"
ENTRY_TYPE="$2"
MESSAGE="$3"
AFFECTED_PATHS="$4"

# Validate type
case "$ENTRY_TYPE" in
  file-change|decision|warning|blocker) ;;
  *)
    echo "Error: Invalid type '$ENTRY_TYPE'."
    echo "Valid types: file-change | decision | warning | blocker"
    exit 1
    ;;
esac

if [ ! -f "$CHANGELOG" ]; then
  echo "Error: sessions/CHANGELOG.md not found. Run from project root."
  exit 1
fi

# Verify session exists and is active
if [ -f "$ACTIVE" ]; then
  if ! grep -q "$SESSION_ID" "$ACTIVE" 2>/dev/null; then
    echo "Error: Session '$SESSION_ID' not found in ACTIVE.md."
    exit 1
  fi
  if ! grep "$SESSION_ID" "$ACTIVE" | grep -q '| active |'; then
    echo "Error: Session '$SESSION_ID' is not active."
    exit 1
  fi
fi

ISO_TIME=$(date +%Y-%m-%dT%H:%M:%S)

# Format the entry as a table row
NEW_ENTRY="| ${ISO_TIME} | ${SESSION_ID} | ${ENTRY_TYPE} | ${MESSAGE} | ${AFFECTED_PATHS} |"

# Append to CHANGELOG.md
TEMP_FILE=$(mktemp)
if grep -q '_(no entries yet)_' "$CHANGELOG" 2>/dev/null; then
  # Replace placeholder with table header + first entry
  head_end=$(grep -n '_(no entries yet)_' "$CHANGELOG" | head -1 | cut -d: -f1)
  head -n $((head_end - 1)) "$CHANGELOG" > "$TEMP_FILE"
  cat >> "$TEMP_FILE" << 'EOF'
| Timestamp | Session ID | Type | Summary | Affected Paths |
|-----------|------------|------|---------|----------------|
EOF
  echo "$NEW_ENTRY" >> "$TEMP_FILE"
  mv "$TEMP_FILE" "$CHANGELOG"
else
  echo "$NEW_ENTRY" >> "$CHANGELOG"
  rm -f "$TEMP_FILE"
fi

echo "Broadcast sent:"
echo "  Time:    $ISO_TIME"
echo "  Session: $SESSION_ID"
echo "  Type:    $ENTRY_TYPE"
echo "  Message: $MESSAGE"
echo "  Paths:   $AFFECTED_PATHS"
