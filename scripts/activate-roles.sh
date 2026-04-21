#!/usr/bin/env bash
# Activate role profiles for a given task type.
# Reads roles/ROUTING.md to determine which roles are required and optional,
# then outputs the role file paths and combined review checklist.
#
# Usage: scripts/activate-roles.sh <task-type>
# Example: scripts/activate-roles.sh backend-api

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROUTING_FILE="$PROJECT_ROOT/roles/ROUTING.md"
ROLES_DIR="$PROJECT_ROOT/roles"

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <task-type>"
  echo ""
  echo "Available task types:"
  grep '^| ' "$ROUTING_FILE" | grep -v '^| Task Type' | grep -v '^|---' | \
    awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print "  " $2}'
  exit 1
fi

TASK_TYPE="$1"

if [ ! -f "$ROUTING_FILE" ]; then
  echo "ERROR: Routing file not found: $ROUTING_FILE"
  exit 1
fi

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

echo "============================================"
echo "  Role Activation for: ${TASK_TYPE}"
echo "============================================"
echo ""

echo "## Required Roles (MUST review)"
echo ""
IFS=',' read -ra REQ_ROLES <<< "$REQUIRED"
REQ_FILES=()
for role in "${REQ_ROLES[@]}"; do
  role=$(echo "$role" | xargs)
  if [[ "$role" == _* ]]; then
    echo "  → ${role} (manual selection needed)"
    continue
  fi
  ROLE_FILE="$ROLES_DIR/${role}.md"
  if [ -f "$ROLE_FILE" ]; then
    echo "  → roles/${role}.md"
    REQ_FILES+=("$ROLE_FILE")
  else
    echo "  → roles/${role}.md (NOT FOUND)"
  fi
done

echo ""
echo "## Optional Roles (review if time allows)"
echo ""
IFS=',' read -ra OPT_ROLES <<< "$OPTIONAL"
for role in "${OPT_ROLES[@]}"; do
  role=$(echo "$role" | xargs)
  if [[ "$role" == _* ]]; then
    echo "  → ${role} (manual selection needed)"
    continue
  fi
  ROLE_FILE="$ROLES_DIR/${role}.md"
  if [ -f "$ROLE_FILE" ]; then
    echo "  → roles/${role}.md"
  else
    echo "  → roles/${role}.md (NOT FOUND)"
  fi
done

echo ""
echo "============================================"
echo "  Combined Review Checklist"
echo "============================================"
echo ""

if [ ${#REQ_FILES[@]} -eq 0 ]; then
  echo "(No automatic checklist — select the role matching the affected area)"
  echo ""
fi

for ROLE_FILE in ${REQ_FILES[@]+"${REQ_FILES[@]}"}; do
  ROLE_NAME=$(head -1 "$ROLE_FILE" | sed 's/^# Role: //')
  echo "--- ${ROLE_NAME} ---"
  echo ""
  IN_CHECKLIST=false
  while IFS= read -r line; do
    if [[ "$line" == "## Review Checklist"* ]]; then
      IN_CHECKLIST=true
      continue
    fi
    if $IN_CHECKLIST && [[ "$line" == "## "* ]]; then
      break
    fi
    if $IN_CHECKLIST && [[ -n "$line" ]] && [[ "$line" != "Answer every"* ]]; then
      echo "$line"
    fi
  done < "$ROLE_FILE"
  echo ""
done

echo "============================================"
echo "Answer ALL questions above before approving."
echo "============================================"
