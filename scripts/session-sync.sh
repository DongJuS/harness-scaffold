#!/usr/bin/env bash
# Shows CHANGELOG.md entries from OTHER sessions since last sync.
# Highlights entries that affect files/topics this session has claimed.
# Usage: scripts/session-sync.sh <session-id>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANGELOG="$ROOT_DIR/sessions/CHANGELOG.md"
CLAIMS="$ROOT_DIR/sessions/CLAIMS.md"
ACTIVE="$ROOT_DIR/sessions/ACTIVE.md"
SYNC_DIR="$ROOT_DIR/sessions/.sync"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <session-id>"
  echo "  Shows changes from other sessions since your last sync."
  echo ""
  echo "Example: $0 \"SESSION-core-20260422-143000\""
  exit 1
fi

SESSION_ID="$1"

if [ ! -f "$CHANGELOG" ]; then
  echo "Error: sessions/CHANGELOG.md not found. Run from project root."
  exit 1
fi

# Verify session exists
if [ -f "$ACTIVE" ]; then
  if ! grep -q "$SESSION_ID" "$ACTIVE" 2>/dev/null; then
    echo "Error: Session '$SESSION_ID' not found in ACTIVE.md."
    exit 1
  fi
fi

# Get last sync timestamp for this session
mkdir -p "$SYNC_DIR"
SYNC_FILE="$SYNC_DIR/${SESSION_ID}.lastsync"
LAST_SYNC=""
if [ -f "$SYNC_FILE" ]; then
  LAST_SYNC=$(cat "$SYNC_FILE")
fi

# Collect this session's claimed paths for conflict detection
MY_CLAIMS=()
if [ -f "$CLAIMS" ]; then
  while IFS='|' read -r _ path claimed_by _ _; do
    path=$(echo "$path" | xargs)
    claimed_by=$(echo "$claimed_by" | xargs)
    [ -z "$path" ] && continue
    [[ "$path" == "_"* ]] && continue
    if [ "$claimed_by" = "$SESSION_ID" ]; then
      MY_CLAIMS+=("$path")
    fi
  done < <(grep '^|' "$CLAIMS" | grep -v '^| Path' | grep -v '^|---')
fi

echo "=== Session Sync: $SESSION_ID ==="
echo ""
if [ -n "$LAST_SYNC" ]; then
  echo "Last synced: $LAST_SYNC"
else
  echo "First sync — showing all entries from other sessions."
fi
echo ""

# Check if changelog has entries
if grep -q '_(no entries yet)_' "$CHANGELOG" 2>/dev/null; then
  echo "No changelog entries yet. Nothing to sync."
  # Record sync time
  date +%Y-%m-%dT%H:%M:%S > "$SYNC_FILE"
  exit 0
fi

# Parse entries from other sessions, filtering by last sync time
NEW_ENTRIES=0
CONFLICTS=0

echo "--- New entries from other sessions ---"
echo ""

while IFS='|' read -r _ timestamp sid entry_type summary paths _; do
  timestamp=$(echo "$timestamp" | xargs)
  sid=$(echo "$sid" | xargs)
  entry_type=$(echo "$entry_type" | xargs)
  summary=$(echo "$summary" | xargs)
  paths=$(echo "$paths" | xargs)

  [ -z "$sid" ] && continue
  [ "$sid" = "$SESSION_ID" ] && continue

  # Filter by last sync time if set
  if [ -n "$LAST_SYNC" ] && [[ "$timestamp" < "$LAST_SYNC" ]]; then
    continue
  fi

  NEW_ENTRIES=$((NEW_ENTRIES + 1))

  # Check if this entry affects any of our claimed paths
  IS_CONFLICT=0
  for claim in "${MY_CLAIMS[@]+"${MY_CLAIMS[@]}"}"; do
    if echo "$paths" | grep -q "$claim" 2>/dev/null || \
       echo "$claim" | grep -q "$paths" 2>/dev/null; then
      IS_CONFLICT=1
      CONFLICTS=$((CONFLICTS + 1))
      break
    fi
  done

  if [ "$IS_CONFLICT" -eq 1 ]; then
    echo "  !! CONFLICT [$entry_type] $timestamp — $sid"
    echo "     $summary"
    echo "     Paths: $paths"
    echo "     Overlaps with YOUR claimed path(s)!"
    echo ""
  else
    echo "  [$entry_type] $timestamp — $sid"
    echo "     $summary"
    echo "     Paths: $paths"
    echo ""
  fi

done < <(grep '^|' "$CHANGELOG" | grep -v '^| Timestamp' | grep -v '^|---')

echo "--- Summary ---"
echo "  New entries:       $NEW_ENTRIES"
echo "  Potential conflicts: $CONFLICTS"

if [ "$CONFLICTS" -gt 0 ]; then
  echo ""
  echo "  ACTION REQUIRED: Review conflicts above before continuing."
  echo "  Another session modified paths that overlap with your claims."
fi

# Record sync time
date +%Y-%m-%dT%H:%M:%S > "$SYNC_FILE"
echo ""
echo "Sync timestamp recorded."
