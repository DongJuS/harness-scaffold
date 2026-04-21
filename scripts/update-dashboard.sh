#!/usr/bin/env bash
# Generates DASHBOARD.md at project root from all project sources.
# DASHBOARD.md is auto-generated — never edit it manually.
# Usage: scripts/update-dashboard.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PRD="$SCRIPT_DIR/ralph/prd.json"
OUT="$ROOT/DASHBOARD.md"
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

section_prd() {
  if [[ ! -f "$PRD" ]]; then echo "_(prd.json not found)_"; return; fi
  PRD_FILE="$PRD" python3 -c "
import json, os
with open(os.environ['PRD_FILE']) as f:
    stories = json.load(f).get('userStories', [])
done = sum(1 for s in stories if s.get('passes'))
total = len(stories)
pct = int(done * 100 / total) if total else 0
filled = int(20 * pct / 100)
bar = chr(9608) * filled + chr(9617) * (20 - filled)
print('**' + str(done) + '/' + str(total) + '** stories complete (' + str(pct) + '%) \`' + bar + '\`')
print()
print('| ID | Title | Status |')
print('|---|---|---|')
for s in stories:
    sid = s['id']
    title = s['title'][:50]
    passes = s.get('passes', False)
    icon = chr(9989) if passes else chr(11036)
    st = 'Done' if passes else 'Todo'
    print('| ' + sid + ' | ' + title + ' | ' + icon + ' ' + st + ' |')
"
}

section_sessions() {
  local ACTIVE="$ROOT/sessions/ACTIVE.md"
  if [[ ! -f "$ACTIVE" ]]; then echo "_(sessions/ACTIVE.md not found)_"; return; fi
  local ROWS
  ROWS=$(grep '^|' "$ACTIVE" | grep -v '^| Session ID' | grep -v '^|---' | grep -v 'no active sessions' || true)
  if [[ -z "$ROWS" ]]; then
    echo "_(no active sessions)_"
  else
    echo "| Session ID | Owner | Working On | Status |"
    echo "|---|---|---|---|"
    echo "$ROWS" | while IFS='|' read -r _ SID _ OWNER WORKING STATUS _; do
      echo "| $(echo "$SID" | xargs) | $(echo "$OWNER" | xargs) | $(echo "$WORKING" | xargs) | $(echo "$STATUS" | xargs) |"
    done
  fi
}

section_timeline() {
  local TL="$ROOT/docs/TIMELINE.md"
  if [[ ! -f "$TL" ]]; then echo "_(docs/TIMELINE.md not found)_"; return; fi
  local ROWS
  ROWS=$(grep '^|' "$TL" | grep -v '^| Date' | grep -v '^|---' | head -10 || true)
  if [[ -z "$ROWS" ]]; then
    echo "_(no entries)_"
  else
    echo "| Date | Type | ID | Title |"
    echo "|---|---|---|---|"
    echo "$ROWS" | while IFS='|' read -r _ DATE TYPE ID TITLE _; do
      echo "| $(echo "$DATE" | xargs) | $(echo "$TYPE" | xargs) | $(echo "$ID" | xargs) | $(echo "$TITLE" | xargs) |"
    done
  fi
}

section_issues() {
  local FOUND=false
  local CONFLICTS="$ROOT/docs/CONFLICTS.md"
  if [[ -f "$CONFLICTS" ]]; then
    local CRIT WARN
    CRIT=$(grep -c '| critical |' "$CONFLICTS" 2>/dev/null || true)
    WARN=$(grep -c '| warning |' "$CONFLICTS" 2>/dev/null || true)
    [[ -z "$CRIT" ]] && CRIT=0
    [[ -z "$WARN" ]] && WARN=0
    if [[ "$CRIT" -gt 0 || "$WARN" -gt 0 ]]; then
      echo "- Conflicts: **$CRIT** critical, **$WARN** warning (\`docs/CONFLICTS.md\`)"
      FOUND=true
    fi
  fi
  for REVIEW in "$ROOT"/docs/reviews/REVIEW-*.md; do
    [[ -f "$REVIEW" ]] || continue
    if grep -q '| critical |' "$REVIEW" 2>/dev/null; then
      echo "- \`$(basename "$REVIEW")\` has unresolved critical issues"
      FOUND=true
    fi
  done
  if [[ "$FOUND" == false ]]; then echo "_(no open issues)_"; fi
}

section_decisions() {
  local DEC_DIR="$ROOT/docs/decisions"
  if [[ ! -d "$DEC_DIR" ]]; then echo "_(no decisions directory)_"; return; fi
  local ACTIVE_CT=0 DEPR_CT=0 LATEST=""
  for ADR in "$DEC_DIR"/ADR-*.md; do
    [[ -f "$ADR" ]] || continue
    if grep -q 'DEPRECATED' "$ADR" 2>/dev/null; then
      DEPR_CT=$((DEPR_CT + 1))
    else
      ACTIVE_CT=$((ACTIVE_CT + 1))
      LATEST="$ADR"
    fi
  done
  echo "- **$ACTIVE_CT** active, **$DEPR_CT** deprecated"
  if [[ -n "$LATEST" ]]; then
    local TITLE FNAME
    TITLE=$(head -1 "$LATEST" | sed 's/^# //')
    FNAME=$(basename "$LATEST")
    echo "- Latest: [\`$FNAME\`](./docs/decisions/$FNAME) — $TITLE"
  fi
}

section_next_up() {
  if [[ ! -f "$PRD" ]]; then echo "_(prd.json not found)_"; return; fi
  PRD_FILE="$PRD" python3 -c "
import json, os
with open(os.environ['PRD_FILE']) as f:
    stories = json.load(f).get('userStories', [])
for s in sorted(stories, key=lambda x: x.get('priority', 999)):
    if not s.get('passes'):
        sid = s['id']
        title = s['title']
        pri = s.get('priority', '?')
        desc = s.get('description', '')
        print('**' + sid + '** ' + chr(8212) + ' ' + title + ' (priority ' + str(pri) + ')')
        print()
        print('> ' + desc)
        break
else:
    print('_All stories complete!_')
"
}

section_health() {
  echo "| Check | Status | Timestamp |"
  echo "|---|---|---|"
  local TS LABEL
  for CHECK in verify.sh check-conflicts.sh check-writing.sh; do
    TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    case "$CHECK" in
      verify.sh) LABEL="Verification" ;;
      check-conflicts.sh) LABEL="Conflict check" ;;
      check-writing.sh) LABEL="Writing quality" ;;
    esac
    if [[ ! -x "$SCRIPT_DIR/$CHECK" ]]; then
      echo "| $LABEL (\`$CHECK\`) | SKIP | $TS |"
    elif "$SCRIPT_DIR/$CHECK" >/dev/null 2>&1; then
      echo "| $LABEL (\`$CHECK\`) | PASS | $TS |"
    else
      echo "| $LABEL (\`$CHECK\`) | FAIL | $TS |"
    fi
  done
}

# --- Generate DASHBOARD.md ---
{
  echo "# Project Dashboard"
  echo ""
  echo "> Auto-generated by \`scripts/update-dashboard.sh\` — do not edit manually."
  echo "> Last updated: $NOW"
  echo ""
  echo "## PRD Progress"
  echo ""
  section_prd
  echo ""
  echo "## Active Sessions"
  echo ""
  section_sessions
  echo ""
  echo "## Recent Activity"
  echo ""
  section_timeline
  echo ""
  echo "## Open Issues"
  echo ""
  section_issues
  echo ""
  echo "## Decision Summary"
  echo ""
  section_decisions
  echo ""
  echo "## Next Up"
  echo ""
  section_next_up
  echo ""
  echo "## Health Check"
  echo ""
  section_health
} > "$OUT"

LINES=$(wc -l < "$OUT")
echo "Dashboard generated: $OUT ($LINES lines)"
if [[ "$LINES" -gt 200 ]]; then
  echo "WARNING: DASHBOARD.md exceeds 200 lines ($LINES lines)"
  exit 1
fi
