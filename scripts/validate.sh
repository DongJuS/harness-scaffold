#!/usr/bin/env bash
# Validates the project structure: file line counts, INDEX.md presence, and REGISTRY.md completeness.
# Usage: ./scripts/validate.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY="$PROJECT_ROOT/REGISTRY.md"
MAX_LINES=200

ERRORS=0
WARNINGS=0

pass() { echo "  ✓ $1"; }
warn() { echo "  ⚠ $1"; WARNINGS=$((WARNINGS + 1)); }
fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }

echo "=== HarnessScaffold Validation ==="
echo ""

echo "[1/3] Checking file line counts (max $MAX_LINES lines)..."

OVER_LIMIT=0
while IFS= read -r file; do
  [[ -f "$file" ]] || continue

  rel_path="${file#"$PROJECT_ROOT"/}"

  [[ "$rel_path" == .git/* ]] && continue
  [[ "$rel_path" == node_modules/* ]] && continue
  [[ "$rel_path" == scripts/ralph/* ]] && continue
  [[ "$rel_path" == prd.json ]] && continue

  line_count=$(wc -l < "$file" | tr -d ' ')

  if [[ "$line_count" -gt "$MAX_LINES" ]]; then
    fail "$rel_path — $line_count lines (over $MAX_LINES limit)"
    OVER_LIMIT=$((OVER_LIMIT + 1))
  fi
done < <(find "$PROJECT_ROOT" -type f \
  -not -path "$PROJECT_ROOT/.git/*" \
  -not -path "$PROJECT_ROOT/node_modules/*" \
  -not -name ".DS_Store")

if [[ "$OVER_LIMIT" -eq 0 ]]; then
  pass "All files under $MAX_LINES lines"
fi
echo ""

echo "[2/3] Checking INDEX.md presence in directories..."

MISSING_INDEX=0
while IFS= read -r dir; do
  rel_dir="${dir#"$PROJECT_ROOT"/}"

  [[ "$dir" == "$PROJECT_ROOT" ]] && continue
  [[ "$rel_dir" == .git* ]] && continue
  [[ "$rel_dir" == node_modules* ]] && continue
  [[ "$rel_dir" == .claude* ]] && continue
  [[ "$rel_dir" == scripts/ralph* ]] && continue

  has_files=false
  for f in "$dir"/*; do
    [[ -e "$f" ]] || continue
    fname="$(basename "$f")"
    [[ "$fname" == "INDEX.md" ]] && continue
    [[ "$fname" == ".git" ]] && continue
    [[ "$fname" == ".gitignore" ]] && continue
    [[ "$fname" == ".DS_Store" ]] && continue
    has_files=true
    break
  done

  if [[ "$has_files" == true && ! -f "$dir/INDEX.md" ]]; then
    fail "Missing INDEX.md in $rel_dir/"
    MISSING_INDEX=$((MISSING_INDEX + 1))
  fi
done < <(find "$PROJECT_ROOT" -type d \
  -not -path "$PROJECT_ROOT/.git" \
  -not -path "$PROJECT_ROOT/.git/*" \
  -not -path "$PROJECT_ROOT/node_modules" \
  -not -path "$PROJECT_ROOT/node_modules/*")

if [[ "$MISSING_INDEX" -eq 0 ]]; then
  pass "All directories with content have INDEX.md"
fi
echo ""

echo "[3/3] Checking REGISTRY.md completeness..."

if [[ ! -f "$REGISTRY" ]]; then
  fail "REGISTRY.md not found"
else
  pass "REGISTRY.md exists"

  for repo_dir in "$PROJECT_ROOT"/repos/*/; do
    [[ -d "$repo_dir" ]] || continue
    repo_name="$(basename "$repo_dir")"
    rel_path="./repos/$repo_name/"

    if grep -q "$rel_path" "$REGISTRY" 2>/dev/null; then
      pass "repos/$repo_name/ registered in REGISTRY.md"
    else
      fail "repos/$repo_name/ NOT registered in REGISTRY.md"
    fi
  done
fi
echo ""

echo "=== Validation Summary ==="
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
  echo ""
  echo "FAILED — fix $ERRORS error(s) before committing."
  exit 1
else
  echo ""
  echo "PASSED — structure is valid."
  exit 0
fi
