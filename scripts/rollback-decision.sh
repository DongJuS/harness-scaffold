#!/usr/bin/env bash
# Cascading rollback: deprecates an ADR and all ADRs that depend on it
# (directly or transitively). Updates AUTHORITY.md and TIMELINE.md, and
# creates a journal entry documenting the rollback.
# Usage: scripts/rollback-decision.sh ADR-001 [-y]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DECISIONS_DIR="$ROOT_DIR/docs/decisions"
AUTHORITY="$ROOT_DIR/docs/AUTHORITY.md"
AUTO_CONFIRM=false

if [ $# -lt 1 ]; then
  echo "Usage: $0 ADR_ID [-y]"
  echo "Example: $0 ADR-001"
  echo "  -y  Skip confirmation prompt"
  exit 1
fi

ROOT_ADR="$1"
[ "${2:-}" = "-y" ] && AUTO_CONFIRM=true
ROOT_FILE="$DECISIONS_DIR/${ROOT_ADR}.md"

if [ ! -f "$ROOT_FILE" ]; then
  echo "Error: $ROOT_FILE does not exist"; exit 1
fi
if grep -q '^deprecated' "$ROOT_FILE"; then
  echo "Error: $ROOT_ADR is already deprecated"; exit 1
fi

# --- Find all dependents (direct + transitive) ---
find_dependents() {
  local target="$1"
  for f in "$DECISIONS_DIR"/ADR-*.md; do
    [ -f "$f" ] || continue
    local id
    id="$(basename "$f" .md)"
    grep -q '^deprecated' "$f" && continue
    local deps_line
    deps_line=$(grep -n '^## Depends On' "$f" | head -1 | cut -d: -f1)
    [ -z "$deps_line" ] && continue
    local deps_val
    deps_val=$(sed -n "$((deps_line + 2))p" "$f")
    if echo "$deps_val" | grep -qw "$target"; then
      echo "$id"
    fi
  done
}

collect_all() {
  local queue=("$1")
  local visited=("$1")
  local i=0
  while [ $i -lt ${#queue[@]} ]; do
    local current="${queue[$i]}"
    while IFS= read -r dep; do
      [ -z "$dep" ] && continue
      local already=false
      for v in "${visited[@]}"; do
        [ "$v" = "$dep" ] && already=true && break
      done
      if [ "$already" = false ]; then
        visited+=("$dep")
        queue+=("$dep")
      fi
    done < <(find_dependents "$current")
    i=$((i + 1))
  done
  printf '%s\n' "${visited[@]}"
}

ALL_AFFECTED=()
while IFS= read -r line; do
  ALL_AFFECTED+=("$line")
done < <(collect_all "$ROOT_ADR")

# --- Display dependency tree ---
echo "=== Cascade Rollback from $ROOT_ADR ==="
echo ""
echo "Root: $ROOT_ADR"
get_title() {
  head -1 "$DECISIONS_DIR/$1.md" | sed 's/^# //'
}
echo "  $(get_title "$ROOT_ADR")"
if [ ${#ALL_AFFECTED[@]} -gt 1 ]; then
  echo ""
  echo "Dependent ADRs that will also be deprecated:"
  for ((j=1; j<${#ALL_AFFECTED[@]}; j++)); do
    adr="${ALL_AFFECTED[$j]}"
    echo "  - $adr: $(get_title "$adr")"
  done
fi
echo ""
echo "Total ADRs to deprecate: ${#ALL_AFFECTED[@]}"
echo ""

# --- Confirm ---
if [ "$AUTO_CONFIRM" = false ]; then
  read -rp "Proceed with rollback? [y/N] " answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    echo "Aborted."; exit 0
  fi
fi

# --- Deprecate all affected ADRs ---
for adr in "${ALL_AFFECTED[@]}"; do
  adr_file="$DECISIONS_DIR/${adr}.md"
  STATUS_LINE=$(grep -n '^## Status' "$adr_file" | head -1 | cut -d: -f1)
  STATUS_VAL=$((STATUS_LINE + 2))
  sed -i '' "${STATUS_VAL}s/.*/deprecated/" "$adr_file"
  TEMP=$(mktemp)
  head -1 "$adr_file" > "$TEMP"
  echo "" >> "$TEMP"
  echo "> **DEPRECATED** — cascade rollback from ${ROOT_ADR}. Do not follow this document." >> "$TEMP"
  tail -n +2 "$adr_file" >> "$TEMP"
  mv "$TEMP" "$adr_file"
  echo "  + $adr deprecated (cascade rollback from $ROOT_ADR)"
done

# --- Update AUTHORITY.md ---
if [ -f "$AUTHORITY" ]; then
  for adr in "${ALL_AFFECTED[@]}"; do
    if grep -q "${adr}" "$AUTHORITY"; then
      sed -i '' "/${adr}/d" "$AUTHORITY"
      echo "  + Removed $adr from AUTHORITY.md"
    fi
  done
fi

# --- Regenerate TIMELINE.md ---
"$SCRIPT_DIR/update-timeline.sh"
echo "  + TIMELINE.md regenerated"

# --- Create journal entry ---
JOURNALS_DIR="$ROOT_DIR/docs/journals"
LAST_JID=0
for f in "$JOURNALS_DIR"/JOURNAL-*.md; do
  [ -f "$f" ] || continue
  NUM="$(basename "$f" .md)"
  NUM="${NUM#JOURNAL-}"
  NUM_CLEAN="$(echo "$NUM" | sed 's/^0*//')"
  if [ -n "$NUM_CLEAN" ] && [ "$NUM_CLEAN" -gt "$LAST_JID" ] 2>/dev/null; then
    LAST_JID="$NUM_CLEAN"
  fi
done
NEXT_JID=$((LAST_JID + 1))
PADDED_JID=$(printf "%03d" "$NEXT_JID")
JFILE="$JOURNALS_DIR/JOURNAL-${PADDED_JID}.md"
TODAY=$(date +%Y-%m-%d)

cat > "$JFILE" << EOF
# JOURNAL-${PADDED_JID}: Cascade rollback from ${ROOT_ADR}

## Date

${TODAY}

## Background

A cascade rollback was triggered on HarnessScaffold (a self-documenting repository
scaffold) because ${ROOT_ADR} needed rollback. All ADRs (Architecture Decision Records)
depending on ${ROOT_ADR} — directly or transitively — were deprecated.

## Objective

Deprecate ${ROOT_ADR} and all downstream dependent ADRs to prevent inconsistent state.

## Tasks Performed

1. Identified all ADRs depending on ${ROOT_ADR} (direct and transitive)
2. Deprecated all ${#ALL_AFFECTED[@]} affected ADRs with cascade rollback warning
3. Removed deprecated entries from AUTHORITY.md (single source of truth registry)
4. Regenerated TIMELINE.md (chronological log index)

## Files Changed

$(printf '%s\n' "${ALL_AFFECTED[@]}" | sed "s|.*|- \`./docs/decisions/&.md\` — deprecated (cascade rollback)|")
- \`./docs/AUTHORITY.md\` — removed deprecated entries
- \`./docs/TIMELINE.md\` — regenerated

## Open Questions

- Replacement decisions may need to be created for the deprecated ADRs

## Glossary References

- **ADR** — Architecture Decision Record, a document capturing a project decision
- **Cascade rollback** — deprecating an ADR and all ADRs that depend on it
EOF
echo "  + Created journal: $JFILE"
echo ""
echo "Done. ${#ALL_AFFECTED[@]} ADRs deprecated. Journal: JOURNAL-${PADDED_JID}"
