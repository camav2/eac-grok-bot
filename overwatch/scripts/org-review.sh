#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATUS_DIR="/workspace/overwatch/status"
OUT="$STATUS_DIR/org-review-latest.md"
mkdir -p "$STATUS_DIR"

# Refresh registry first
bash "$SCRIPT_DIR/registry-refresh.sh" >/dev/null

ts="$(date -u +"%Y-%m-%d %H:%M UTC")"
bot_count=0
if [[ -f /workspace/overwatch/registry/bots.json ]]; then
  bot_count="$(jq 'length' /workspace/overwatch/registry/bots.json)"
fi

{
  echo "# Org Review"
  echo
  echo "- **timestamp:** $ts"
  echo "- **bot count:** $bot_count"
  echo
  echo "## Bots"
  echo
  if [[ -f /workspace/overwatch/registry/bots.md ]]; then
    # Skip the header block of bots.md (title + generated line) and include listings
    sed -n '/^## /,$p' /workspace/overwatch/registry/bots.md
  else
    echo "(no registry)"
  fi

  echo "## Disk hotspots under /workspace"
  echo
  echo '```'
  du -sh /workspace/* 2>/dev/null | sort -hr | head -20 || true
  echo '```'
  echo

  echo "## shared/temp and shared/archive"
  echo
  for d in /workspace/shared/temp /workspace/shared/archive; do
    if [[ -d "$d" ]]; then
      size="$(du -sh "$d" 2>/dev/null | awk '{print $1}')"
      # count entries (files + dirs), not recursive file count only
      n="$(find "$d" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')"
      echo "- \`$d\`: exists, size≈$size, entries=$n"
    else
      echo "- \`$d\`: MISSING"
    fi
  done
  echo

  echo "## Backup health"
  echo
  cd /workspace
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "- git repo: yes"
    if git remote get-url origin >/dev/null 2>&1; then
      # Do not print full URL if it embeds credentials; sanitize
      origin="$(git remote get-url origin | sed -E 's#(://[^:/@]+):[^@]+@#\1:***@#')"
      echo "- origin: $origin"
    else
      echo "- origin: NONE"
    fi
    if git rev-parse HEAD >/dev/null 2>&1; then
      echo "- last commit: $(git log -1 --format='%h %ci %s' 2>/dev/null || echo unknown)"
    else
      echo "- last commit: (none yet)"
    fi
  else
    echo "- git repo: no"
    echo "- origin: n/a"
    echo "- last commit: n/a"
  fi
  echo

  echo "## Convention notes (/workspace root)"
  echo
  echo "Likely bot/project dirs vs clutter at /workspace root:"
  echo
  for entry in /workspace/*; do
    base="$(basename "$entry")"
    if [[ -d "$entry" ]]; then
      case "$base" in
        overwatch|shared)
          echo "- **$base/** — control-plane / shared (convention OK)"
          ;;
        whisper-venv|agent-tools|gmail-archive-bin|gmail-clear|transcripts|watchlist_batches)
          echo "- **$base/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)"
          ;;
        *)
          echo "- **$base/** — directory (review: bot project vs ad-hoc)"
          ;;
      esac
    else
      case "$base" in
        *.m4a|*.mp4|*.zip|*.json)
          echo "- **$base** — file clutter / large artifact at root (prefer shared/temp or bot folder)"
          ;;
        README.md|.gitignore)
          echo "- **$base** — repo meta (OK)"
          ;;
        *)
          echo "- **$base** — root file (review)"
          ;;
      esac
    fi
  done
  echo

  echo "## Recommendations"
  echo
  # Actionable recommendations based on live signals
  recs=()

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 || ! git remote get-url origin >/dev/null 2>&1; then
    recs+=("Add a git \`origin\` remote for /workspace and authenticate \`gh\`/\`git push\` so Overwatch backups can land off-box.")
  fi

  # Large media at root
  if ls /workspace/*.m4a /workspace/*.mp4 /workspace/*.zip 2>/dev/null | grep -q .; then
    recs+=("Move large media (e.g. *.m4a/*.mp4) out of /workspace root into a bot project or archive; they inflate disk and should stay gitignored.")
  fi

  # Empty/unnamed bots
  if [[ -f /workspace/overwatch/registry/bots.json ]]; then
    empty="$(jq '[.[] | select((.name=="" or .name=="New Bot") or (.description==""))] | length' /workspace/overwatch/registry/bots.json)"
    if [[ "$empty" -gt 0 ]]; then
      recs+=("Registry has $empty bot(s) with empty/placeholder name or description — name them or archive unused agent folders to reduce roster clutter.")
    fi
  fi

  # Disk hotspot: whisper-venv
  if [[ -d /workspace/whisper-venv ]]; then
    recs+=("\`whisper-venv/\` is a disk hotspot at root; keep it gitignored and consider documenting which bot owns it, or relocate under that bot's folder.")
  fi

  # Ensure 2–3 recommendations
  if [[ ${#recs[@]} -eq 0 ]]; then
    recs+=("Keep weekday cleanup + registry-refresh + backup cadence; verify archive retention stays at 30 days.")
    recs+=("Promote durable bot projects into named folders under /workspace and keep scratch under shared/temp.")
    recs+=("Re-run org-review weekly to catch convention drift and disk growth early.")
  elif [[ ${#recs[@]} -eq 1 ]]; then
    recs+=("Promote durable bot projects into named folders under /workspace; keep ephemeral scratch in shared/temp (7-day → archive).")
    recs+=("Re-run org-review weekly after backup auth is fixed to catch convention drift.")
  elif [[ ${#recs[@]} -eq 2 ]]; then
    recs+=("Re-run org-review weekly once backup remote/auth is healthy to catch convention drift and disk growth.")
  fi

  i=1
  for r in "${recs[@]}"; do
    echo "$i. $r"
    i=$((i + 1))
    # Cap at 3 for brevity
    if [[ $i -gt 3 ]]; then
      break
    fi
  done
  echo
} > "$OUT"

echo "org-review written: $OUT"
exit 0
