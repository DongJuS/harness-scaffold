#!/usr/bin/env bash
# Creates a new file with a 200-line-limit header comment and updates the parent INDEX.md.
# Usage: ./scripts/new-file.sh <file-path> "<description>"

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <file-path> \"<description>\""
  echo "Example: $0 repos/core/utils/array.ts \"Array utility functions (filter, sort, group)\""
  exit 1
fi

FILE_PATH="$1"
DESCRIPTION="$2"

if [[ -f "$FILE_PATH" ]]; then
  echo "Error: File '$FILE_PATH' already exists."
  exit 1
fi

PARENT_DIR="$(dirname "$FILE_PATH")"

if [[ ! -d "$PARENT_DIR" ]]; then
  echo "Error: Parent directory '$PARENT_DIR' does not exist."
  echo "Create the directory first or use scripts/new-repo.sh for new sub-repos."
  exit 1
fi

FILENAME="$(basename "$FILE_PATH")"
EXTENSION="${FILENAME##*.}"

case "$EXTENSION" in
  ts|js|tsx|jsx)
    COMMENT_PREFIX="//"
    ;;
  py)
    COMMENT_PREFIX="#"
    ;;
  sh|bash)
    COMMENT_PREFIX="#"
    ;;
  rs)
    COMMENT_PREFIX="//"
    ;;
  go)
    COMMENT_PREFIX="//"
    ;;
  md)
    COMMENT_PREFIX=""
    ;;
  *)
    COMMENT_PREFIX="//"
    ;;
esac

if [[ "$EXTENSION" == "sh" || "$EXTENSION" == "bash" ]]; then
  cat > "$FILE_PATH" << EOF
#!/usr/bin/env bash
$COMMENT_PREFIX $DESCRIPTION
$COMMENT_PREFIX Max 200 lines — split into focused files if approaching limit.

set -euo pipefail
EOF
elif [[ "$EXTENSION" == "md" ]]; then
  cat > "$FILE_PATH" << EOF
# ${FILENAME%.*}

${DESCRIPTION}
EOF
elif [[ -n "$COMMENT_PREFIX" ]]; then
  cat > "$FILE_PATH" << EOF
$COMMENT_PREFIX $DESCRIPTION
$COMMENT_PREFIX Max 200 lines — split into focused files if approaching limit.
EOF
else
  touch "$FILE_PATH"
fi

echo "Created $FILE_PATH"

INDEX_FILE="$PARENT_DIR/INDEX.md"

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "  Note: No INDEX.md in $PARENT_DIR — consider running scripts/create-index.sh"
  exit 0
fi

ENTRY="- \`./${FILENAME}\` — ${DESCRIPTION}"

if grep -qF "./${FILENAME}" "$INDEX_FILE" 2>/dev/null; then
  echo "  INDEX.md already references $FILENAME"
else
  FILES_LINE=$(grep -n "^## Files" "$INDEX_FILE" | head -1 | cut -d: -f1)

  if [[ -n "$FILES_LINE" ]]; then
    NO_FILES_LINE=$(grep -n "^- _No files yet_" "$INDEX_FILE" | head -1 | cut -d: -f1)
    if [[ -n "$NO_FILES_LINE" ]]; then
      head -n "$((NO_FILES_LINE - 1))" "$INDEX_FILE" > "$INDEX_FILE.tmp"
      echo "$ENTRY" >> "$INDEX_FILE.tmp"
      tail -n +"$((NO_FILES_LINE + 1))" "$INDEX_FILE" >> "$INDEX_FILE.tmp"
      mv "$INDEX_FILE.tmp" "$INDEX_FILE"
    else
      NEXT_SECTION=$(tail -n +"$((FILES_LINE + 1))" "$INDEX_FILE" | grep -n "^## " | head -1 | cut -d: -f1)
      if [[ -n "$NEXT_SECTION" ]]; then
        INSERT_AT=$((FILES_LINE + NEXT_SECTION - 1))
        head -n "$((INSERT_AT - 1))" "$INDEX_FILE" > "$INDEX_FILE.tmp"
        echo "$ENTRY" >> "$INDEX_FILE.tmp"
        tail -n +"$INSERT_AT" "$INDEX_FILE" >> "$INDEX_FILE.tmp"
        mv "$INDEX_FILE.tmp" "$INDEX_FILE"
      else
        echo "$ENTRY" >> "$INDEX_FILE"
      fi
    fi
    echo "  Updated $INDEX_FILE"
  else
    echo "  Note: Could not find ## Files section in $INDEX_FILE — add entry manually:"
    echo "  $ENTRY"
  fi
fi
