#!/usr/bin/env bash
# Visualizes the dependency graph of all active ADRs as an ASCII tree.
# Shows which decisions depend on which, so developers can assess blast
# radius before making changes.
# Usage: scripts/show-decision-tree.sh [ADR-ID]
#   No argument: show full forest of all active ADRs
#   With ADR-ID: show only the subtree rooted at that ADR
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DECISIONS_DIR="$ROOT_DIR/docs/decisions"

get_title() {
  head -1 "$DECISIONS_DIR/$1.md" 2>/dev/null | sed 's/^# //'
}

get_status() {
  local sline
  sline=$(grep -n '^## Status' "$DECISIONS_DIR/$1.md" 2>/dev/null | head -1 | cut -d: -f1)
  [ -z "$sline" ] && echo "unknown" && return
  sed -n "$((sline + 2))p" "$DECISIONS_DIR/$1.md"
}

get_depends() {
  local dline
  dline=$(grep -n '^## Depends On' "$DECISIONS_DIR/$1.md" 2>/dev/null | head -1 | cut -d: -f1)
  [ -z "$dline" ] && return
  local val
  val=$(sed -n "$((dline + 2))p" "$DECISIONS_DIR/$1.md")
  [ "$val" = "none" ] && return
  echo "$val" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -E '^ADR-[0-9]+$'
}

# Collect all active ADRs
ACTIVE_ADRS=()
for f in "$DECISIONS_DIR"/ADR-*.md; do
  [ -f "$f" ] || continue
  id="$(basename "$f" .md)"
  status="$(get_status "$id")"
  [ "$status" = "deprecated" ] && continue
  ACTIVE_ADRS+=("$id")
done

if [ ${#ACTIVE_ADRS[@]} -eq 0 ]; then
  echo "No active ADRs found."
  exit 0
fi

# Build dependency map: for each ADR, find its dependents (who depends on it)
find_children() {
  local parent="$1"
  for adr in "${ACTIVE_ADRS[@]}"; do
    deps="$(get_depends "$adr")"
    if echo "$deps" | grep -qw "$parent"; then
      echo "$adr"
    fi
  done
}

# Print subtree recursively
print_tree() {
  local node="$1"
  local prefix="$2"
  local is_last="$3"

  local status
  status="$(get_status "$node")"
  local status_tag=""
  [ "$status" = "deprecated" ] && status_tag=" [DEPRECATED]"

  if [ "$prefix" = "ROOT" ]; then
    echo "$node: $(get_title "$node")${status_tag}"
    prefix=""
  else
    local connector="├── "
    if [ "$is_last" = "true" ]; then connector="└── "; fi
    echo "${prefix}${connector}${node}: $(get_title "$node")${status_tag}"
  fi

  local ext="│   "
  [ "$is_last" = "true" ] && ext="    "
  local child_prefix="${prefix}${ext}"

  local children=()
  while IFS= read -r child; do
    [ -z "$child" ] && continue
    children+=("$child")
  done < <(find_children "$node")

  for ((i=0; i<${#children[@]}; i++)); do
    local child_last="false"
    [ $((i + 1)) -eq ${#children[@]} ] && child_last="true"
    print_tree "${children[$i]}" "$child_prefix" "$child_last"
  done
}

# If a specific ADR is requested, show only its subtree
if [ $# -ge 1 ]; then
  TARGET="$1"
  if [ ! -f "$DECISIONS_DIR/${TARGET}.md" ]; then
    echo "Error: $TARGET not found"; exit 1
  fi
  echo "=== Decision Tree: $TARGET ==="
  echo ""
  print_tree "$TARGET" "ROOT" "true"
  exit 0
fi

# Full forest: find root ADRs (those with no dependencies or 'none')
echo "=== ADR Dependency Forest ==="
echo ""

ROOTS=()
for adr in "${ACTIVE_ADRS[@]}"; do
  deps="$(get_depends "$adr")"
  if [ -z "$deps" ]; then
    ROOTS+=("$adr")
  else
    all_deprecated=true
    while IFS= read -r dep; do
      [ -z "$dep" ] && continue
      status="$(get_status "$dep")"
      [ "$status" != "deprecated" ] && all_deprecated=false && break
    done <<< "$deps"
    [ "$all_deprecated" = true ] && ROOTS+=("$adr")
  fi
done

if [ ${#ROOTS[@]} -eq 0 ]; then
  echo "(No root ADRs found — possible circular dependencies)"
  echo ""
  echo "All active ADRs:"
  for adr in "${ACTIVE_ADRS[@]}"; do
    echo "  $adr: $(get_title "$adr")"
  done
  exit 0
fi

for ((r=0; r<${#ROOTS[@]}; r++)); do
  is_last="false"
  [ $((r + 1)) -eq ${#ROOTS[@]} ] && is_last="true"
  print_tree "${ROOTS[$r]}" "ROOT" "$is_last"
  echo ""
done

echo "Active: ${#ACTIVE_ADRS[@]} | Roots: ${#ROOTS[@]}"
