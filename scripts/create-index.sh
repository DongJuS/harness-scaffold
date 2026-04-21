#!/usr/bin/env bash
# Generates an INDEX.md skeleton for a given directory.
# Usage: ./scripts/create-index.sh <directory-path>

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <directory-path>"
  echo "Example: $0 repos/core/types"
  exit 1
fi

TARGET_DIR="$1"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

OUTPUT="$TARGET_DIR/INDEX.md"

if [[ -f "$OUTPUT" ]]; then
  echo "Error: INDEX.md already exists at '$OUTPUT'."
  echo "Remove it first to regenerate."
  exit 1
fi

DIR_NAME="$(basename "$TARGET_DIR")"

FILES_SECTION=""
for f in "$TARGET_DIR"/*; do
  [[ -e "$f" ]] || continue
  fname="$(basename "$f")"
  [[ "$fname" == "INDEX.md" ]] && continue
  if [[ -d "$f" ]]; then
    FILES_SECTION="$FILES_SECTION- \`./${fname}/\` — _describe this directory_
"
  else
    FILES_SECTION="$FILES_SECTION- \`./${fname}\` — _describe this file_
"
  fi
done

if [[ -z "$FILES_SECTION" ]]; then
  FILES_SECTION="- _No files yet_
"
fi

cat > "$OUTPUT" << EOF
# ${DIR_NAME}

## Purpose

_Brief description of what this directory contains and why it exists._

## Files

${FILES_SECTION}
## Dependencies

_Relative paths to other directories this one depends on._

- _None yet_

## Related

_Relative paths to sibling or parent directories with related concerns._

- _None yet_
EOF

echo "Created INDEX.md at $OUTPUT"
echo "Next steps: edit $OUTPUT to fill in descriptions."
