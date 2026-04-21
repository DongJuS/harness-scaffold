#!/usr/bin/env bash
# Scaffolds a new sub-repo under repos/ with INDEX.md, .gitignore, and registers it in REGISTRY.md.
# Usage: ./scripts/new-repo.sh <repo-name> "<purpose>"

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <repo-name> \"<purpose>\""
  echo "Example: $0 auth \"Authentication and authorization modules\""
  exit 1
fi

REPO_NAME="$1"
PURPOSE="$2"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY="$PROJECT_ROOT/REGISTRY.md"
REPO_DIR="$PROJECT_ROOT/repos/$REPO_NAME"

if [[ -d "$REPO_DIR" ]]; then
  echo "Error: Directory repos/$REPO_NAME/ already exists."
  exit 1
fi

if [[ ! -f "$REGISTRY" ]]; then
  echo "Error: REGISTRY.md not found at $REGISTRY"
  exit 1
fi

echo "Creating sub-repo: $REPO_NAME"
echo "  Purpose: $PURPOSE"
echo ""

mkdir -p "$REPO_DIR"

cat > "$REPO_DIR/INDEX.md" << EOF
# ${REPO_NAME}

## Purpose

${PURPOSE}

## Files

- _No files yet_

## How To

_Add task-to-file mappings as files are created._

## Dependencies

- _None yet_

## Related

- \`../\` — sibling sub-repos in the repos/ directory
EOF

cat > "$REPO_DIR/.gitignore" << 'EOF'
# Dependencies
node_modules/
vendor/

# Build output
dist/
build/
*.js.map

# OS files
.DS_Store
Thumbs.db

# Editor files
*.swp
*.swo
*~

# Environment
.env
.env.local
EOF

echo "  Created repos/$REPO_NAME/"
echo "  Created repos/$REPO_NAME/INDEX.md"
echo "  Created repos/$REPO_NAME/.gitignore"

REL_PATH="./repos/$REPO_NAME/"

if grep -q "| \`$REL_PATH\`" "$REGISTRY" 2>/dev/null; then
  echo "  Already registered in REGISTRY.md"
else
  REGISTRY_LINE="| $REPO_NAME | \`$REL_PATH\` | _(local only)_ | $PURPOSE |"

  LAST_TABLE_LINE=$(grep -n '^|' "$REGISTRY" | tail -1 | cut -d: -f1)

  if [[ -n "$LAST_TABLE_LINE" ]]; then
    head -n "$LAST_TABLE_LINE" "$REGISTRY" > "$REGISTRY.tmp"
    echo "$REGISTRY_LINE" >> "$REGISTRY.tmp"
    tail -n +"$((LAST_TABLE_LINE + 1))" "$REGISTRY" >> "$REGISTRY.tmp"
    mv "$REGISTRY.tmp" "$REGISTRY"
    echo "  Registered in REGISTRY.md"
  else
    echo "  WARNING: Could not find table in REGISTRY.md. Add manually:"
    echo "  $REGISTRY_LINE"
  fi
fi

echo ""
echo "Done! Next steps:"
echo "  1. Add files to repos/$REPO_NAME/"
echo "  2. Update repos/$REPO_NAME/INDEX.md with file descriptions"
echo "  3. Run ./scripts/validate.sh to verify structure"
