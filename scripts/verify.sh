#!/usr/bin/env bash
# Runs a configurable verification pipeline: detects project type, runs
# typecheck/lint/test/build per sub-repo, and outputs a summary report.
# Usage: ./scripts/verify.sh [sub-repo-path]
#   No argument = run root pipeline + auto-detect in all sub-repos.
#   With path   = run only that sub-repo's pipeline.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/verify-config.json"

TOTAL=0; PASSED=0; FAILED=0; SKIPPED=0
FAILURES=""

log_pass() { TOTAL=$((TOTAL+1)); PASSED=$((PASSED+1)); echo "  PASS  $1"; }
log_fail() { TOTAL=$((TOTAL+1)); FAILED=$((FAILED+1)); echo "  FAIL  $1: $2"; FAILURES="${FAILURES}\n  - $1: $2"; }
log_skip() { TOTAL=$((TOTAL+1)); SKIPPED=$((SKIPPED+1)); echo "  SKIP  $1: $2"; }

TIMEOUT_CMD=""
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD="timeout"
elif command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_CMD="gtimeout"
fi

run_step() {
  local NAME="$1" CMD="$2" TIMEOUT="${3:-30}" DIR="$4"
  if ! command -v "$(echo "$CMD" | awk '{print $1}')" >/dev/null 2>&1 \
     && [[ ! -x "$ROOT_DIR/$CMD" ]] && [[ ! -f "$ROOT_DIR/$CMD" ]]; then
    log_skip "$NAME" "command not found"
    return
  fi
  local EXEC_CMD="$CMD"
  if [[ -f "$ROOT_DIR/$CMD" ]]; then
    EXEC_CMD="$ROOT_DIR/$CMD"
  fi
  local OUTPUT
  local RUNCMD="$EXEC_CMD"
  if [[ -n "$TIMEOUT_CMD" ]]; then
    RUNCMD="$TIMEOUT_CMD $TIMEOUT $EXEC_CMD"
  fi
  if OUTPUT=$(cd "$DIR" && bash -c "$RUNCMD" 2>&1); then
    log_pass "$NAME"
  else
    local EXIT_CODE=$?
    if [[ $EXIT_CODE -eq 124 ]]; then
      log_fail "$NAME" "timed out after ${TIMEOUT}s"
    else
      local LAST_LINE
      LAST_LINE=$(echo "$OUTPUT" | tail -1)
      log_fail "$NAME" "$LAST_LINE"
    fi
  fi
}

detect_and_run() {
  local DIR="$1" LABEL="$2"
  local DETECTED=false
  for MARKER in package.json Cargo.toml go.mod pyproject.toml Makefile; do
    if [[ -f "$DIR/$MARKER" ]]; then
      DETECTED=true
      echo ""
      echo "[$LABEL] Detected $MARKER"
      for STEP in typecheck lint test build; do
        local CMD
        CMD=$(python3 -c "
import json,sys
c=json.load(open('$CONFIG_FILE'))
d=c.get('detectors',{}).get('$MARKER',{})
print(d.get('$STEP',''))" 2>/dev/null || echo "")
        if [[ -n "$CMD" ]]; then
          run_step "${LABEL}:${STEP}" "$CMD" 60 "$DIR"
        fi
      done
      break
    fi
  done
  if [[ "$DETECTED" == false ]]; then
    echo ""
    echo "[$LABEL] No build system detected — structural checks only"
  fi
}

run_configured_pipeline() {
  local PIPELINE_KEY="$1" DIR="$2"
  local STEP_COUNT
  STEP_COUNT=$(python3 -c "
import json
c=json.load(open('$CONFIG_FILE'))
p=c.get('pipelines',{}).get('$PIPELINE_KEY',{})
print(len(p.get('steps',[])))" 2>/dev/null || echo "0")

  if [[ "$STEP_COUNT" -gt 0 ]]; then
    local I=0
    while [[ $I -lt $STEP_COUNT ]]; do
      local STEP_INFO
      STEP_INFO=$(python3 -c "
import json
c=json.load(open('$CONFIG_FILE'))
s=c['pipelines']['$PIPELINE_KEY']['steps'][$I]
print(s['name']+'|'+s['command']+'|'+str(s.get('timeout',30)))" 2>/dev/null)
      local S_NAME S_CMD S_TIMEOUT
      S_NAME=$(echo "$STEP_INFO" | cut -d'|' -f1)
      S_CMD=$(echo "$STEP_INFO" | cut -d'|' -f2)
      S_TIMEOUT=$(echo "$STEP_INFO" | cut -d'|' -f3)
      run_step "$S_NAME" "$S_CMD" "$S_TIMEOUT" "$DIR"
      I=$((I+1))
    done
  fi
}

echo "=== HarnessScaffold Verification ==="
echo ""

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  echo "[Root Pipeline]"
  run_configured_pipeline "_root" "$ROOT_DIR"

  for REPO_DIR in "$ROOT_DIR"/repos/*/; do
    [[ -d "$REPO_DIR" ]] || continue
    REPO_NAME=$(basename "$REPO_DIR")
    PIPELINE_KEY="repos/$REPO_NAME"
    echo ""
    echo "[repos/$REPO_NAME]"
    run_configured_pipeline "$PIPELINE_KEY" "$REPO_DIR"
    detect_and_run "$REPO_DIR" "repos/$REPO_NAME"
  done
else
  ABS_TARGET="$ROOT_DIR/$TARGET"
  if [[ ! -d "$ABS_TARGET" ]]; then
    echo "ERROR: Directory not found: $TARGET"
    exit 1
  fi
  PIPELINE_KEY="$TARGET"
  echo "[$TARGET]"
  run_configured_pipeline "$PIPELINE_KEY" "$ABS_TARGET"
  detect_and_run "$ABS_TARGET" "$TARGET"
fi

echo ""
echo "=== Verification Summary ==="
echo "  Total:   $TOTAL"
echo "  Passed:  $PASSED"
echo "  Failed:  $FAILED"
echo "  Skipped: $SKIPPED"

if [[ "$FAILED" -gt 0 ]]; then
  echo ""
  echo "Failures:"
  echo -e "$FAILURES"
  echo ""
  echo "RESULT: FAILED — fix $FAILED failure(s) before marking task complete."
  exit 1
else
  echo ""
  echo "RESULT: PASSED — all verification checks succeeded."
  exit 0
fi
