#!/usr/bin/env bash
# Generates a verification report in docs/reviews/ from verify.sh output.
# Pairs with role-based reviews so conceptual + runtime checks are linked.
# Usage: ./scripts/verify-report.sh "<task-description>" [review-id]
#   task-description: what was verified (e.g., "US-024 implementation")
#   review-id: optional REVIEW-NNN to link to an existing role review

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REVIEWS_DIR="$ROOT_DIR/docs/reviews"
VERIFY_SCRIPT="$SCRIPT_DIR/verify.sh"

usage() {
  echo "Usage: $(basename "$0") \"<task-description>\" [REVIEW-NNN]"
  exit 1
}

[[ $# -lt 1 ]] && usage

TASK_DESC="$1"
LINKED_REVIEW="${2:-none}"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)

next_verify_id() {
  local LAST_ID
  LAST_ID=$(ls "$REVIEWS_DIR"/VERIFY-*.md 2>/dev/null | \
    sed 's/.*VERIFY-0*//' | sed 's/\.md//' | sort -n | tail -1)
  printf "VERIFY-%03d" "$(( ${LAST_ID:-0} + 1 ))"
}

VERIFY_ID=$(next_verify_id)
REPORT_FILE="$REVIEWS_DIR/${VERIFY_ID}.md"

echo "Running verification pipeline..."
echo ""

VERIFY_OUTPUT=$("$VERIFY_SCRIPT" 2>&1 || true)
EXIT_CODE=0
"$VERIFY_SCRIPT" > /dev/null 2>&1 || EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  OVERALL="PASSED"
else
  OVERALL="FAILED"
fi

TOTAL=$(echo "$VERIFY_OUTPUT" | grep '  Total:' | awk '{print $2}')
PASSED=$(echo "$VERIFY_OUTPUT" | grep '  Passed:' | awk '{print $2}')
FAILED=$(echo "$VERIFY_OUTPUT" | grep '  Failed:' | awk '{print $2}')
SKIPPED=$(echo "$VERIFY_OUTPUT" | grep '  Skipped:' | awk '{print $2}')

TOTAL="${TOTAL:-0}"
PASSED="${PASSED:-0}"
FAILED="${FAILED:-0}"
SKIPPED="${SKIPPED:-0}"

STEP_ROWS=""
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]+(PASS|FAIL|SKIP)[[:space:]]+(.*) ]]; then
    STATUS="${BASH_REMATCH[1]}"
    DETAIL="${BASH_REMATCH[2]}"
    case "$STATUS" in
      PASS) ICON="pass" ;;
      FAIL) ICON="**FAIL**" ;;
      SKIP) ICON="skip" ;;
    esac
    STEP_ROWS="${STEP_ROWS}| ${DETAIL%%:*} | ${ICON} | ${DETAIL#*: } |
"
  fi
done <<< "$VERIFY_OUTPUT"

if [[ -z "$STEP_ROWS" ]]; then
  STEP_ROWS="| (no steps executed) | skip | — |
"
fi

cat > "$REPORT_FILE" << EOF
# ${VERIFY_ID}: Verification Report

## Background

HarnessScaffold is a self-documenting repository scaffold enforcing a 200-line
file limit and INDEX.md navigation convention. This verification report records
the results of running the automated verification pipeline (scripts/verify.sh)
against the project after code changes, confirming structural and runtime
correctness before a task is marked complete.

## Date

${TODAY} (${TIMESTAMP})

## Task Verified

${TASK_DESC}

## Linked Review

${LINKED_REVIEW}

## Overall Result

**${OVERALL}**

## Summary

| Metric  | Count |
|---------|-------|
| Total   | ${TOTAL} |
| Passed  | ${PASSED} |
| Failed  | ${FAILED} |
| Skipped | ${SKIPPED} |

## Step Details

| Step | Result | Detail |
|------|--------|--------|
${STEP_ROWS}
## Raw Output

\`\`\`
${VERIFY_OUTPUT}
\`\`\`

## Glossary References

- **HarnessScaffold** — The self-documenting repository scaffold this project implements
- **Verification pipeline** — Automated checks (structure, conflicts, writing quality, build) run by scripts/verify.sh
- See [docs/GLOSSARY.md](../GLOSSARY.md) for additional project terms
EOF

INDEX_FILE="$REVIEWS_DIR/INDEX.md"
if grep -q "No review entries yet" "$INDEX_FILE" 2>/dev/null; then
  sed -i '' "s|.*No review entries yet.*|- \`./${VERIFY_ID}.md\` — Verification: ${TASK_DESC}|" "$INDEX_FILE"
else
  LAST_LINE=$(grep -n '^\- `\.\/' "$INDEX_FILE" | tail -1 | cut -d: -f1)
  if [[ -n "$LAST_LINE" ]]; then
    sed -i '' "${LAST_LINE}a\\
- \`./${VERIFY_ID}.md\` — Verification: ${TASK_DESC}" "$INDEX_FILE"
  fi
fi

echo "Created: ${REPORT_FILE}"
echo "Verify ID: ${VERIFY_ID}"
echo "Overall: ${OVERALL}"
echo "Linked Review: ${LINKED_REVIEW}"
