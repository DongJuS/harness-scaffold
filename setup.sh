#!/usr/bin/env bash
# Initializes all sub-repos from REGISTRY.md and validates the directory structure.
# Usage: ./setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY="$SCRIPT_DIR/REGISTRY.md"

if [[ ! -f "$REGISTRY" ]]; then
  echo "Error: REGISTRY.md not found at $REGISTRY"
  exit 1
fi

echo "=== HarnessScaffold Setup ==="
echo ""

REPOS=()
PATHS=()
REMOTES=()

while IFS='|' read -r _ name path remote _; do
  name="$(echo "$name" | xargs)"
  path="$(echo "$path" | xargs | tr -d '`')"
  remote="$(echo "$remote" | xargs | tr -d '_' | tr -d '(' | tr -d ')')"

  [[ -z "$name" || "$name" == "Name" || "$name" == "---"* ]] && continue

  REPOS+=("$name")
  PATHS+=("$path")
  REMOTES+=("$remote")
done < "$REGISTRY"

echo "Found ${#REPOS[@]} sub-repo(s) in REGISTRY.md"
echo ""

ERRORS=0

for i in "${!REPOS[@]}"; do
  name="${REPOS[$i]}"
  path="${PATHS[$i]}"
  remote="${REMOTES[$i]}"

  full_path="$SCRIPT_DIR/$path"
  full_path="${full_path%/}"

  echo "--- [$name] $path ---"

  if [[ ! -d "$full_path" ]]; then
    echo "  WARNING: Directory $path does not exist. Skipping."
    ERRORS=$((ERRORS + 1))
    continue
  fi

  if [[ ! -d "$full_path/.git" ]]; then
    echo "  Initializing git repository..."
    git -C "$full_path" init -q
    echo "  Git initialized."
  else
    echo "  Git already initialized."
  fi

  if [[ "$remote" != "local only" && -n "$remote" ]]; then
    if git -C "$full_path" remote get-url origin >/dev/null 2>&1; then
      echo "  Remote 'origin' already set."
    else
      echo "  Adding remote origin: $remote"
      git -C "$full_path" remote add origin "$remote"
    fi
  else
    echo "  No remote configured (local only)."
  fi

  if [[ ! -f "$full_path/INDEX.md" ]]; then
    echo "  WARNING: Missing INDEX.md in $path"
    ERRORS=$((ERRORS + 1))
  else
    echo "  INDEX.md present."
  fi

  echo ""
done

echo "=== Setup Complete ==="
if [[ $ERRORS -gt 0 ]]; then
  echo "Warnings: $ERRORS issue(s) found. Review output above."
  echo "Run ./scripts/validate.sh for a full structural check."
else
  echo "All sub-repos initialized successfully."
fi
