#!/usr/bin/env bash
# Supersedes one ADR with another: deprecates the old ADR, links both
# directions, adds a deprecation warning, updates AUTHORITY.md, and
# regenerates TIMELINE.md.
# Usage: scripts/supersede-decision.sh ADR-001 ADR-005
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DECISIONS_DIR="$ROOT_DIR/docs/decisions"
AUTHORITY="$ROOT_DIR/docs/AUTHORITY.md"

if [ $# -lt 2 ]; then
  echo "Usage: $0 OLD_ADR_ID NEW_ADR_ID"
  echo "Example: $0 ADR-001 ADR-005"
  exit 1
fi

OLD_ID="$1"
NEW_ID="$2"
OLD_FILE="$DECISIONS_DIR/${OLD_ID}.md"
NEW_FILE="$DECISIONS_DIR/${NEW_ID}.md"

if [ ! -f "$OLD_FILE" ]; then
  echo "Error: $OLD_FILE does not exist"
  exit 1
fi
if [ ! -f "$NEW_FILE" ]; then
  echo "Error: $NEW_FILE does not exist"
  exit 1
fi

if grep -q '^deprecated' "$OLD_FILE"; then
  echo "Error: $OLD_ID is already deprecated"
  exit 1
fi

echo "Superseding $OLD_ID with $NEW_ID..."

# --- Step 1: Set old ADR status to 'deprecated' ---
STATUS_LINE=$(grep -n '^## Status' "$OLD_FILE" | head -1 | cut -d: -f1)
STATUS_VAL=$((STATUS_LINE + 2))
sed -i '' "${STATUS_VAL}s/.*/deprecated/" "$OLD_FILE"
echo "  + $OLD_ID status set to deprecated"

# --- Step 2: Set 'Superseded By' in old ADR ---
if grep -q '^## Superseded By' "$OLD_FILE"; then
  SUP_BY_LINE=$(grep -n '^## Superseded By' "$OLD_FILE" | head -1 | cut -d: -f1)
  SUP_BY_VAL=$((SUP_BY_LINE + 2))
  sed -i '' "${SUP_BY_VAL}s/.*/${NEW_ID}/" "$OLD_FILE"
else
  TEMP=$(mktemp)
  head -n "$STATUS_VAL" "$OLD_FILE" > "$TEMP"
  echo "" >> "$TEMP"
  echo "## Superseded By" >> "$TEMP"
  echo "" >> "$TEMP"
  echo "${NEW_ID}" >> "$TEMP"
  tail -n "+$((STATUS_VAL + 1))" "$OLD_FILE" >> "$TEMP"
  mv "$TEMP" "$OLD_FILE"
fi
echo "  + $OLD_ID superseded by $NEW_ID"

# --- Step 3: Set 'Supersedes' in new ADR ---
if grep -q '^## Supersedes' "$NEW_FILE"; then
  SUP_LINE=$(grep -n '^## Supersedes' "$NEW_FILE" | head -1 | cut -d: -f1)
  SUP_VAL=$((SUP_LINE + 2))
  sed -i '' "${SUP_VAL}s/.*/${OLD_ID}/" "$NEW_FILE"
else
  NEW_STATUS_LINE=$(grep -n '^## Status' "$NEW_FILE" | head -1 | cut -d: -f1)
  NEW_STATUS_VAL=$((NEW_STATUS_LINE + 2))
  TEMP=$(mktemp)
  head -n "$NEW_STATUS_VAL" "$NEW_FILE" > "$TEMP"
  echo "" >> "$TEMP"
  echo "## Supersedes" >> "$TEMP"
  echo "" >> "$TEMP"
  echo "${OLD_ID}" >> "$TEMP"
  tail -n "+$((NEW_STATUS_VAL + 1))" "$NEW_FILE" >> "$TEMP"
  mv "$TEMP" "$NEW_FILE"
fi
echo "  + $NEW_ID supersedes $OLD_ID"

# --- Step 4: Add deprecation warning header to old ADR ---
TEMP=$(mktemp)
head -1 "$OLD_FILE" > "$TEMP"
echo "" >> "$TEMP"
cat >> "$TEMP" << EOF
> **DEPRECATED** — replaced by [${NEW_ID}](${NEW_ID}.md). Do not follow this document.
EOF
tail -n +2 "$OLD_FILE" >> "$TEMP"
mv "$TEMP" "$OLD_FILE"
echo "  + Deprecation warning added to $OLD_ID"

# --- Step 5: Update AUTHORITY.md references ---
if [ -f "$AUTHORITY" ]; then
  if grep -q "${OLD_ID}" "$AUTHORITY"; then
    sed -i '' "s|./decisions/${OLD_ID}.md|./decisions/${NEW_ID}.md|g" "$AUTHORITY"
    echo "  + AUTHORITY.md updated: ${OLD_ID} references now point to ${NEW_ID}"
  else
    echo "  (no ${OLD_ID} references in AUTHORITY.md)"
  fi
fi

# --- Step 6: Regenerate TIMELINE.md ---
"$SCRIPT_DIR/update-timeline.sh"
echo "  + TIMELINE.md regenerated"

echo ""
echo "Done. $OLD_ID is now deprecated, superseded by $NEW_ID."
echo "Review: git diff docs/decisions/ docs/AUTHORITY.md"
