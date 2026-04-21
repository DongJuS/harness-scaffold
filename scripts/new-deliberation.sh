#!/usr/bin/env bash
# Generates a new deliberation log from the template with an auto-incremented ID.
# Usage: scripts/new-deliberation.sh "Core question being reasoned about"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DELIB_DIR="$ROOT_DIR/docs/deliberations"
TEMPLATE="$DELIB_DIR/TEMPLATE.md"

if [ $# -lt 1 ]; then
  echo "Usage: $0 \"Core question being reasoned about\""
  echo "Example: $0 \"Should we use monorepo or polyrepo structure?\""
  exit 1
fi

QUESTION="$1"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template not found at $TEMPLATE"
  exit 1
fi

# Find the next ID by scanning existing DELIB files
LAST_ID=0
for f in "$DELIB_DIR"/DELIB-*.md; do
  [ -f "$f" ] || continue
  BASENAME="$(basename "$f" .md)"
  NUM="${BASENAME#DELIB-}"
  NUM_CLEAN="$(echo "$NUM" | sed 's/^0*//')"
  if [ -n "$NUM_CLEAN" ] && [ "$NUM_CLEAN" -gt "$LAST_ID" ] 2>/dev/null; then
    LAST_ID="$NUM_CLEAN"
  fi
done

NEXT_ID=$((LAST_ID + 1))
PADDED_ID=$(printf "%03d" "$NEXT_ID")
FILENAME="DELIB-${PADDED_ID}.md"
FILEPATH="$DELIB_DIR/$FILENAME"
TODAY=$(date +%Y-%m-%d)

cat > "$FILEPATH" << EOF
# DELIB-${PADDED_ID}: ${QUESTION}

## ID

DELIB-${PADDED_ID}

## Date

${TODAY}

## Background

_Write as if the reader has never seen this project before. State the full context: what project, what problem, what has been tried, why this matters._

## Related Decision

_Link to ADR if applicable, e.g. \`../decisions/ADR-001.md\`, or "None"._

## Related Journal

_Link to journal entry if applicable, e.g. \`../journals/JOURNAL-001.md\`, or "None"._

## Question

${QUESTION}

## Constraints

- _Known limitations or requirements that narrow the solution space._

## Thinking

_Step-by-step reasoning with options explored. Show the thought process._

1. ...
2. ...

## Conclusion

_Final judgment reached after reasoning._

## Confidence

**Level:** high | medium | low

_Explanation of why this confidence level was chosen._

## Glossary References

_List any project-specific terms used in this document with definitions or links to [docs/GLOSSARY.md](../GLOSSARY.md)._
EOF

echo "Created: $FILEPATH"

# Update INDEX.md if it exists
INDEX="$DELIB_DIR/INDEX.md"
if [ -f "$INDEX" ]; then
  ENTRY="- \`./${FILENAME}\` — ${QUESTION}"
  if grep -q "No deliberation entries yet" "$INDEX" 2>/dev/null; then
    sed -i '' "s|- No deliberation entries yet.*|${ENTRY}|" "$INDEX"
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
