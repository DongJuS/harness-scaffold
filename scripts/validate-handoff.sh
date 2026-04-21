#!/usr/bin/env bash
# Validates HANDOFF.md for completeness, freshness, self-contained language,
# and that referenced file paths actually exist.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HANDOFF="$PROJECT_ROOT/HANDOFF.md"
ISSUES=0

if [ ! -f "$HANDOFF" ]; then
  echo "ERROR: HANDOFF.md does not exist at project root"
  exit 1
fi

echo "=== Validating HANDOFF.md ==="
echo ""

# --- 1. Check required fields ---
echo "[1/4] Checking required fields..."
REQUIRED_FIELDS=(
  "## Last Updated"
  "## Session ID"
  "## Completed This Session"
  "## In Progress"
  "## Next Up"
  "## Blockers"
  "## Warnings"
  "## Files Recently Changed"
)

for field in "${REQUIRED_FIELDS[@]}"; do
  if ! grep -q "^${field}$" "$HANDOFF"; then
    echo "  MISSING: '$field' section not found"
    ISSUES=$((ISSUES + 1))
  fi
done

if [ $ISSUES -eq 0 ]; then
  echo "  All 8 required fields present"
fi

# --- 2. Check freshness ---
echo ""
echo "[2/4] Checking freshness (Last Updated timestamp)..."
TIMESTAMP=$(grep -A2 "^## Last Updated" "$HANDOFF" | tail -1 | xargs)

if [ -z "$TIMESTAMP" ] || [ "$TIMESTAMP" = "## Session ID" ]; then
  echo "  WARNING: Last Updated field is empty or missing a value"
  ISSUES=$((ISSUES + 1))
else
  echo "  Last Updated: $TIMESTAMP"
  DATE_PART=$(echo "$TIMESTAMP" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
  if [ -z "$DATE_PART" ]; then
    echo "  WARNING: Timestamp does not start with ISO date (YYYY-MM-DD)"
    ISSUES=$((ISSUES + 1))
  fi
fi

# --- 3. Check self-contained language ---
echo ""
echo "[3/4] Checking for context-dependent phrases..."
BANNED_PHRASES=(
  "as mentioned"
  "as discussed"
  "see above"
  "the issue"
  "we agreed"
  "as noted"
  "the problem"
  "as before"
)

PHRASE_ISSUES=0
for phrase in "${BANNED_PHRASES[@]}"; do
  MATCHES=$(grep -in "$phrase" "$HANDOFF" | grep -v "^[0-9]*:.*Bad:" || true)
  if [ -n "$MATCHES" ]; then
    echo "  WARNING: Found context-dependent phrase '$phrase':"
    echo "$MATCHES" | while IFS= read -r line; do
      echo "    $line"
    done
    PHRASE_ISSUES=$((PHRASE_ISSUES + 1))
  fi
done

if [ $PHRASE_ISSUES -eq 0 ]; then
  echo "  No context-dependent phrases found"
fi
ISSUES=$((ISSUES + PHRASE_ISSUES))

# --- 4. Check referenced files exist ---
echo ""
echo "[4/4] Checking referenced file paths..."
FILE_ISSUES=0

PATHS=$(grep -oE '\`\./[^`]+\`' "$HANDOFF" | sed 's/`//g' || true)

while IFS= read -r rel_path; do
  if [ -z "$rel_path" ]; then
    continue
  fi
  full_path="$PROJECT_ROOT/$rel_path"
  if [ ! -e "$full_path" ]; then
    echo "  MISSING FILE: $rel_path does not exist"
    FILE_ISSUES=$((FILE_ISSUES + 1))
  fi
done <<< "$PATHS"

if [ $FILE_ISSUES -eq 0 ]; then
  echo "  All referenced files exist"
fi
ISSUES=$((ISSUES + FILE_ISSUES))

# --- Summary ---
echo ""
echo "=== Summary ==="
if [ $ISSUES -eq 0 ]; then
  echo "PASS: HANDOFF.md is valid (0 issues)"
  exit 0
else
  echo "FAIL: $ISSUES issue(s) found in HANDOFF.md"
  exit 1
fi
