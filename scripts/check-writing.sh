#!/usr/bin/env bash
# Checks documents for self-contained writing quality violations.
# Usage: scripts/check-writing.sh [file_or_dir]
# Scans .md files under docs/ (or a specified path) for banned phrases,
# bare links, undefined acronyms, missing Background sections, and
# documents that are too short to be self-contained.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"

ERRORS=0
WARNINGS=0

err()  { echo "  ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "  WARNING: $1"; WARNINGS=$((WARNINGS + 1)); }

# Collect files to scan
FILES=()
if [ $# -gt 0 ] && [ -f "$1" ]; then
  FILES=("$1")
elif [ $# -gt 0 ] && [ -d "$1" ]; then
  while IFS= read -r f; do FILES+=("$f"); done < <(find "$1" -name "*.md" -type f)
else
  while IFS= read -r f; do FILES+=("$f"); done < <(find "$DOCS_DIR" -name "*.md" -type f)
fi

# Filter out non-authored files (indexes, templates, auto-generated)
SCAN_FILES=()
for f in "${FILES[@]}"; do
  fname="$(basename "$f")"
  case "$fname" in
    INDEX.md|TEMPLATE.md|TIMELINE.md|CONFLICTS.md|DASHBOARD.md) continue ;;
  esac
  SCAN_FILES+=("$f")
done

if [ ${#SCAN_FILES[@]} -eq 0 ]; then
  echo "No documents to scan."
  exit 0
fi

echo "=== Writing Quality Check ==="
echo "Scanning ${#SCAN_FILES[@]} document(s)..."
echo ""

BANNED="as mentioned|as discussed|as noted above|see above|the above issue|we agreed|as we decided"

for file in "${SCAN_FILES[@]}"; do
  rel_path="${file#"$ROOT_DIR"/}"
  FILE_ISSUES=0

  echo "--- $rel_path ---"

  # [1] Banned context-dependent phrases (skip example lines in quotes/backticks)
  while IFS=: read -r lineno line; do
    [ -n "$lineno" ] || continue
    # Skip lines showing banned phrases as examples (quoted or in backticks)
    echo "$line" | grep -qE '^\s*- (Bad|Good):' && continue
    echo "$line" | grep -qE '^\s*- "' && continue
    warn "$rel_path:$lineno — banned context-dependent phrase found"
    FILE_ISSUES=$((FILE_ISSUES + 1))
  done < <(grep -niE "$BANNED" "$file" 2>/dev/null || true)

  # [2] Bare links — path references without " — " description
  while IFS=: read -r lineno line; do
    [ -n "$lineno" ] || continue
    echo "$line" | grep -q ' — ' && continue
    echo "$line" | grep -q '^|' && continue
    echo "$line" | grep -qE '^#{1,6} ' && continue
    echo "$line" | grep -qE '^\s*_' && continue
    # Skip lines showing examples (Bad:/Good: prefixed)
    echo "$line" | grep -qE '^\s*- (Bad|Good):' && continue
    warn "$rel_path:$lineno — possible bare link without summary description"
    FILE_ISSUES=$((FILE_ISSUES + 1))
  done < <(grep -nE '\./[a-zA-Z]' "$file" 2>/dev/null || true)

  # [3] Undefined acronyms (all-caps words 2-5 chars, not expanded in doc)
  # Skip the glossary itself — it defines acronyms in table format
  fname_lower="$(basename "$file")"
  if [ "$fname_lower" = "GLOSSARY.md" ]; then
    : # skip acronym check for the glossary
  else
  ACRONYMS=$(grep -oE '\b[A-Z]{2,5}\b' "$file" 2>/dev/null | sort -u || true)
  SKIP="OK|OR|AND|NOT|THE|FOR|ALL|BUT|NOR|YES|NO|IF|IN|ON|TO|BY|AS|AT|UP|IS|IT|OF|SO|DO|BE|HAS"
  SKIP="$SKIP|ONE|TWO|WHAT|WHY|HOW|WHO|WHEN|WHERE|EACH|MAX|MIN|NEW|OLD|USE|RUN|SEE|BAD"
  SKIP="$SKIP|INDEX|MUST|ANY|MAY|CAN|DID|WAS|ARE|WERE|WILL|BEEN|ONLY|ALSO|BOTH|THAN"
  # Universally-known acronyms that don't need expansion
  SKIP="$SKIP|AI|API|URL|HTTP|JSON|HTML|CSS|SQL|CLI|SDK|CI|CD|PDF|CSV|XML|YAML|SSH|DNS"
  for acr in $ACRONYMS; do
    echo "$acr" | grep -qE "^($SKIP)$" && continue
    if ! grep -q "($acr)" "$file" 2>/dev/null && \
       ! grep -q "$acr (" "$file" 2>/dev/null; then
      if ! grep -qE "^#{1,6} .*$acr" "$file" 2>/dev/null; then
        warn "$rel_path — acronym '$acr' not expanded (define on first use or link to GLOSSARY.md)"
        FILE_ISSUES=$((FILE_ISSUES + 1))
      fi
    fi
  done
  fi

  # [4] Missing Background section (required for template-based docs)
  fname="$(basename "$file")"
  case "$fname" in
    ADR-*|JOURNAL-*|DELIB-*)
      if ! grep -q "^## Background" "$file" 2>/dev/null; then
        err "$rel_path — missing required '## Background' section"
        FILE_ISSUES=$((FILE_ISSUES + 1))
      fi
      ;;
  esac

  # [5] Minimum content threshold (non-empty, non-heading, non-separator lines)
  CONTENT_LINES=$(grep -cvE '^\s*$|^#{1,6} |^-{3,}|^\|' "$file" 2>/dev/null || echo "0")
  if [ "$CONTENT_LINES" -lt 5 ]; then
    warn "$rel_path — only $CONTENT_LINES content lines (may be too short to be self-contained)"
    FILE_ISSUES=$((FILE_ISSUES + 1))
  fi

  if [ "$FILE_ISSUES" -eq 0 ]; then
    echo "  ✓ No issues found"
  fi
  echo ""
done

echo "=== Writing Quality Summary ==="
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "FAILED — fix $ERRORS error(s) before proceeding."
  exit 1
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo ""
  echo "PASSED with $WARNINGS warning(s) — review and address if possible."
  exit 0
fi

echo ""
echo "PASSED — all documents meet writing quality standards."
exit 0
