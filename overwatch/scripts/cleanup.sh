#!/usr/bin/env bash
set -euo pipefail

TEMP_DIR="/workspace/shared/temp"
ARCHIVE_DIR="/workspace/shared/archive"

mkdir -p "$TEMP_DIR" "$ARCHIVE_DIR"

moved=0
deleted=0

# Move items in temp older than 7 days into archive (preserve names; collision -> append timestamp)
shopt -s nullglob
for item in "$TEMP_DIR"/*; do
  [ -e "$item" ] || continue
  # Only consider items older than 7 days
  if [[ -n "$(find "$item" -maxdepth 0 -mtime +7 2>/dev/null)" ]]; then
    base="$(basename "$item")"
    dest="$ARCHIVE_DIR/$base"
    if [[ -e "$dest" ]]; then
      ts="$(date -u +%Y%m%d%H%M%S)"
      dest="$ARCHIVE_DIR/${base}.${ts}"
    fi
    mv "$item" "$dest"
    moved=$((moved + 1))
  fi
done

# Delete items in archive older than 30 days
for item in "$ARCHIVE_DIR"/*; do
  [ -e "$item" ] || continue
  if [[ -n "$(find "$item" -maxdepth 0 -mtime +30 2>/dev/null)" ]]; then
    rm -rf "$item"
    deleted=$((deleted + 1))
  fi
done

if [[ "$moved" -eq 0 && "$deleted" -eq 0 ]]; then
  echo "nothing to do"
else
  echo "moved=${moved} deleted=${deleted}"
fi

exit 0
