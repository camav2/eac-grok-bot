#!/usr/bin/env bash
set -euo pipefail

AGENTS_ROOT="/home/box/agent-data/agents"
OUT_JSON="/workspace/overwatch/registry/bots.json"
OUT_MD="/workspace/overwatch/registry/bots.md"

mkdir -p "$(dirname "$OUT_JSON")"

tmp_json="$(mktemp)"
echo "[" > "$tmp_json"
first=1
count=0

# Collect for markdown
md_tmp="$(mktemp)"
{
  echo "# Bot Registry"
  echo
  echo "Generated: $(date -u +"%Y-%m-%d %H:%M UTC")"
  echo
} > "$md_tmp"

shopt -s nullglob
for profile in "$AGENTS_ROOT"/*/profile.json; do
  dir="$(dirname "$profile")"
  id="$(basename "$dir")"
  if ! jq -e . "$profile" >/dev/null 2>&1; then
    echo "skip broken: $id" >&2
    continue
  fi
  name="$(jq -r '.name // ""' "$profile")"
  description="$(jq -r '.description // ""' "$profile")"
  title="$(jq -r '.title // empty' "$profile")"

  # Build JSON object
  if [[ -n "$title" ]]; then
    obj="$(jq -nc --arg id "$id" --arg name "$name" --arg description "$description" --arg title "$title" \
      '{id:$id, name:$name, description:$description, title:$title}')"
  else
    obj="$(jq -nc --arg id "$id" --arg name "$name" --arg description "$description" \
      '{id:$id, name:$name, description:$description}')"
  fi

  if [[ "$first" -eq 1 ]]; then
    first=0
  else
    echo "," >> "$tmp_json"
  fi
  printf '%s' "$obj" >> "$tmp_json"
  count=$((count + 1))

  # One-line description for md (collapse newlines)
  oneline="$(printf '%s' "$description" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | sed 's/^ //;s/ $//')"
  {
    echo "## ${name:-"(unnamed)"}"
    echo
    echo "- **id:** \`$id\`"
    if [[ -n "$title" ]]; then
      echo "- **title:** $title"
    fi
    echo "- **description:** ${oneline:-"(none)"}"
    echo
  } >> "$md_tmp"
done

echo "]" >> "$tmp_json"
# Pretty-print if possible
if jq . "$tmp_json" > "$OUT_JSON" 2>/dev/null; then
  :
else
  cp "$tmp_json" "$OUT_JSON"
fi
cp "$md_tmp" "$OUT_MD"
rm -f "$tmp_json" "$md_tmp"

echo "bots_registered=${count}"
exit 0
