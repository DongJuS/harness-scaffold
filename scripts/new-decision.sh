#!/usr/bin/env bash
# Generates a new ADR file from the template with an auto-incremented ID.
# Usage: scripts/new-decision.sh "Title of the decision"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DECISIONS_DIR="$ROOT_DIR/docs/decisions"
TEMPLATE="$DECISIONS_DIR/TEMPLATE.md"

if [ $# -lt 1 ]; then
  echo "Usage: $0 \"Title of the decision\""
  echo "Example: $0 \"Use PostgreSQL for primary datastore\""
  exit 1
fi

TITLE="$1"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template not found at $TEMPLATE"
  exit 1
fi

# Find the next ID by scanning existing ADR files
LAST_ID=0
for f in "$DECISIONS_DIR"/ADR-*.md; do
  [ -f "$f" ] || continue
  BASENAME="$(basename "$f" .md)"
  NUM="${BASENAME#ADR-}"
  NUM_CLEAN="$(echo "$NUM" | sed 's/^0*//')"
  if [ -n "$NUM_CLEAN" ] && [ "$NUM_CLEAN" -gt "$LAST_ID" ] 2>/dev/null; then
    LAST_ID="$NUM_CLEAN"
  fi
done

NEXT_ID=$((LAST_ID + 1))
PADDED_ID=$(printf "%03d" "$NEXT_ID")
FILENAME="ADR-${PADDED_ID}.md"
FILEPATH="$DECISIONS_DIR/$FILENAME"
TODAY=$(date +%Y-%m-%d)

cat > "$FILEPATH" << EOF
# ADR-${PADDED_ID}: ${TITLE}

## Status

proposed

## Supersedes

none

## Superseded By

active

## Date

${TODAY}

## Context

_What problem or situation prompted this decision? Describe the forces at play._

## Options

### Option A: {Name}

- **Pros:** ...
- **Cons:** ...

### Option B: {Name}

- **Pros:** ...
- **Cons:** ...

## Decision

_Which option was chosen?_

## Reasoning

_Why did this option win over the alternatives?_

## Consequences

### Enables

- ...

### Costs

- ...
EOF

echo "Created: $FILEPATH"

# Update INDEX.md if it exists
INDEX="$DECISIONS_DIR/INDEX.md"
if [ -f "$INDEX" ]; then
  ENTRY="- \`./${FILENAME}\` — ${TITLE}"
  if grep -q "No files yet" "$INDEX" 2>/dev/null; then
    sed -i '' "s/- No files yet.*/${ENTRY}/" "$INDEX"
  else
    # Find last '- `./...' entry in ## Files and append after it
    LAST_LINE=$(grep -n '^- `\./' "$INDEX" | tail -1 | cut -d: -f1)
    if [ -n "$LAST_LINE" ]; then
      sed -i '' "${LAST_LINE}a\\
${ENTRY}
" "$INDEX"
    fi
  fi
  echo "Updated: $INDEX"
fi
