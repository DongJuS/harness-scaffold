#!/usr/bin/env bash
# Generates a new journal entry from the template with an auto-incremented ID.
# Usage: scripts/new-journal.sh "Objective of the session"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
JOURNALS_DIR="$ROOT_DIR/docs/journals"
TEMPLATE="$JOURNALS_DIR/TEMPLATE.md"

if [ $# -lt 1 ]; then
  echo "Usage: $0 \"Objective of the session\""
  echo "Example: $0 \"Implement user authentication module\""
  exit 1
fi

OBJECTIVE="$1"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template not found at $TEMPLATE"
  exit 1
fi

# Find the next ID by scanning existing JOURNAL files
LAST_ID=0
for f in "$JOURNALS_DIR"/JOURNAL-*.md; do
  [ -f "$f" ] || continue
  BASENAME="$(basename "$f" .md)"
  NUM="${BASENAME#JOURNAL-}"
  NUM_CLEAN="$(echo "$NUM" | sed 's/^0*//')"
  if [ -n "$NUM_CLEAN" ] && [ "$NUM_CLEAN" -gt "$LAST_ID" ] 2>/dev/null; then
    LAST_ID="$NUM_CLEAN"
  fi
done

NEXT_ID=$((LAST_ID + 1))
PADDED_ID=$(printf "%03d" "$NEXT_ID")
FILENAME="JOURNAL-${PADDED_ID}.md"
FILEPATH="$JOURNALS_DIR/$FILENAME"
TODAY=$(date +%Y-%m-%d)

cat > "$FILEPATH" << EOF
# JOURNAL-${PADDED_ID}: ${OBJECTIVE}

## Session ID

JOURNAL-${PADDED_ID}

## Date

${TODAY}

## Objective

${OBJECTIVE}

## Tasks Performed

1. ...
2. ...

## Files Changed

- \`./path/to/file\` — summary of changes

## Problems Encountered

- _Issues hit during work, or "None" if smooth sailing._

## Solutions Applied

- _How problems were resolved, or "N/A" if no problems._

## Open Questions

- _Unresolved items for human review, or "None" if all resolved._
EOF

echo "Created: $FILEPATH"

# Update INDEX.md if it exists
INDEX="$JOURNALS_DIR/INDEX.md"
if [ -f "$INDEX" ]; then
  ENTRY="- \`./${FILENAME}\` — ${OBJECTIVE}"
  if grep -q "No journal entries yet" "$INDEX" 2>/dev/null; then
    sed -i '' "s|- No journal entries yet.*|${ENTRY}|" "$INDEX"
  else
    LAST_LINE=$(grep -n '^- `\./' "$INDEX" | tail -1 | cut -d: -f1)
    if [ -n "$LAST_LINE" ]; then
      sed -i '' "${LAST_LINE}a\\
${ENTRY}
" "$INDEX"
    fi
  fi
  echo "Updated: $INDEX"
fi
