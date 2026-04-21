#!/usr/bin/env bash
# Generate and validate role-based reviews for completed tasks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REVIEWS_DIR="$PROJECT_ROOT/docs/reviews"
ROLES_DIR="$PROJECT_ROOT/roles"
ROUTING_FILE="$ROLES_DIR/ROUTING.md"

usage() {
  echo "Usage: $(basename "$0") generate <task-type> \"<description>\" | check <review-file>"
  exit 1
}

[ $# -lt 2 ] && usage

MODE="$1"

next_review_id() {
  LAST_ID=$(ls "$REVIEWS_DIR"/REVIEW-*.md 2>/dev/null | \
    sed 's/.*REVIEW-0*//' | sed 's/\.md//' | sort -n | tail -1)
  printf "REVIEW-%03d" "$(( ${LAST_ID:-0} + 1 ))"
}

extract_checklist() {
  local ROLE_FILE="$1"
  local Q_NUM=0
  local IN_CHECKLIST=false
  while IFS= read -r line; do
    if [[ "$line" == "## Review Checklist"* ]]; then
      IN_CHECKLIST=true; continue
    fi
    if $IN_CHECKLIST && [[ "$line" == "## "* ]]; then break; fi
    if $IN_CHECKLIST && [[ "$line" =~ ^[0-9]+\.\  ]]; then
      Q_NUM=$((Q_NUM + 1))
      QUESTION=$(echo "$line" | sed 's/^[0-9]*\. \*\*[^*]*\*\* — //')
      echo "| ${Q_NUM} | ${QUESTION} | {pass/fail/na} | {explanation} |"
    fi
  done < "$ROLE_FILE"
}

generate_review() {
  local TASK_TYPE="$1"
  local TASK_DESC="${2:-$TASK_TYPE}"

  ROW=$(grep "^| ${TASK_TYPE} " "$ROUTING_FILE" || true)
  if [ -z "$ROW" ]; then
    echo "ERROR: Unknown task type '${TASK_TYPE}'"
    echo ""
    echo "Available task types:"
    grep '^| ' "$ROUTING_FILE" | grep -v '^| Task Type' | grep -v '^|---' | \
      awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print "  " $2}'
    exit 1
  fi

  REQUIRED=$(echo "$ROW" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
  OPTIONAL=$(echo "$ROW" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $4); print $4}')
  TODAY=$(date +%Y-%m-%d)
  REVIEW_ID=$(next_review_id)
  REVIEW_FILE="$REVIEWS_DIR/${REVIEW_ID}.md"

  ROLE_SECTIONS=""
  IFS=',' read -ra REQ_ROLES <<< "$REQUIRED"
  for role in "${REQ_ROLES[@]}"; do
    role=$(echo "$role" | xargs)
    [[ "$role" == _* ]] && continue
    ROLE_FILE="$ROLES_DIR/${role}.md"
    [ ! -f "$ROLE_FILE" ] && continue
    ROLE_NAME=$(head -1 "$ROLE_FILE" | sed 's/^# Role: //')
    CHECKLIST_ROWS=$(extract_checklist "$ROLE_FILE")
    ROLE_SECTIONS="${ROLE_SECTIONS}
### ${ROLE_NAME}

| # | Question | Result | Explanation |
|---|----------|--------|-------------|
${CHECKLIST_ROWS}
"
  done

  cat > "$REVIEW_FILE" << EOF
# ${REVIEW_ID}: ${TASK_DESC}

## Date

${TODAY}

## Background

_Write as if the reader has never seen this project before._

## Task

${TASK_DESC}

## Activated Roles

- **Required:** ${REQUIRED}
- **Optional:** ${OPTIONAL}

## Per-Role Review
${ROLE_SECTIONS}
## Issues Found

| # | Severity | Role | Description |
|---|----------|------|-------------|

_(none)_

## Resolution

_What was fixed, or why flagged issues are acceptable._

## Final Verdict

{approved | approved-with-caveats | blocked}

## Glossary References

_See [docs/GLOSSARY.md](../GLOSSARY.md) for project terms._
EOF

  echo "Created: ${REVIEW_FILE}"
  echo "Review ID: ${REVIEW_ID}"
  echo ""
  echo "Next steps:"
  echo "  1. Fill in all {pass/fail/na} and {explanation} placeholders"
  echo "  2. Record any issues in the Issues Found table"
  echo "  3. Set the Final Verdict"
  echo "  4. Run: scripts/role-review.sh check ${REVIEW_FILE}"

  INDEX_FILE="$REVIEWS_DIR/INDEX.md"
  if grep -q "No review entries yet" "$INDEX_FILE" 2>/dev/null; then
    sed -i '' "s|.*No review entries yet.*|- \`./${REVIEW_ID}.md\` — Review: ${TASK_DESC}|" "$INDEX_FILE"
  else
    LAST_LINE=$(grep -n '^\- `\./REVIEW-' "$INDEX_FILE" | tail -1 | cut -d: -f1)
    if [ -n "$LAST_LINE" ]; then
      sed -i '' "${LAST_LINE}a\\
- \`./${REVIEW_ID}.md\` — Review: ${TASK_DESC}" "$INDEX_FILE"
    fi
  fi
}

check_review() {
  local REVIEW_FILE="$1"
  if [ ! -f "$REVIEW_FILE" ]; then
    echo "ERROR: Review file not found: $REVIEW_FILE"
    exit 1
  fi

  ISSUES=0
  echo "Checking: $(basename "$REVIEW_FILE")"
  echo ""

  if grep -q '{pass/fail/na}' "$REVIEW_FILE"; then
    echo "CRITICAL: Unanswered checklist questions ('{pass/fail/na}' placeholders remain)"
    ISSUES=$((ISSUES + 1))
  fi

  if grep -q '{approved' "$REVIEW_FILE"; then
    echo "CRITICAL: Final verdict not set (placeholder remains)"
    ISSUES=$((ISSUES + 1))
  fi

  if grep -qi '| critical |' "$REVIEW_FILE"; then
    CRITICAL_COUNT=$(grep -ci '| critical |' "$REVIEW_FILE")
    echo "CRITICAL: ${CRITICAL_COUNT} critical issue(s) in Issues Found table"
    ISSUES=$((ISSUES + CRITICAL_COUNT))
  fi

  if grep -qi '| fail |' "$REVIEW_FILE"; then
    FAIL_COUNT=$(grep -ci '| fail |' "$REVIEW_FILE")
    echo "WARNING: ${FAIL_COUNT} failed checklist item(s)"
  fi

  VERDICT=$(grep -A2 '^## Final Verdict' "$REVIEW_FILE" | tail -1 | xargs)
  if [ "$VERDICT" = "blocked" ]; then
    echo "CRITICAL: Final verdict is BLOCKED"
    ISSUES=$((ISSUES + 1))
  fi

  echo ""
  if [ "$ISSUES" -gt 0 ]; then
    echo "RESULT: BLOCKED — ${ISSUES} critical issue(s) must be resolved before completion"
    exit 1
  else
    echo "RESULT: PASSED — Review complete with no blocking issues"
  fi
}

case "$MODE" in
  generate) [ $# -lt 3 ] && usage; generate_review "$2" "$3" ;;
  check)    check_review "$2" ;;
  *)        usage ;;
esac
