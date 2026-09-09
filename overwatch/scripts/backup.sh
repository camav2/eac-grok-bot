#!/usr/bin/env bash
set -euo pipefail

cd /workspace

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -b main
  cat > .gitignore << 'GI'
# Secrets & credentials
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
**/credentials*
**/secrets*
**/*token*
**/*secret*
id_rsa
id_ed25519
.ssh/
.aws/
.gnupg/

# Browser / session data
**/browser-profile*/
**/chrome-profile*/
**/chromium*/
**/.config/google-chrome/
**/Cookies
**/Login Data

# Agent runtime DBs
*.db
*.db-wal
*.db-shm
*.sqlite
*.sqlite3

# Large media / dumps
*.m4a
*.mp4
*.mov
*.avi
*.mkv
*.zip
*.tar
*.tar.gz
*.tgz
*.7z
*.rar

# Virtualenvs / caches
whisper-venv/
**/venv/
**/.venv/
**/node_modules/
**/__pycache__/
*.pyc
.cache/
GI
  if [[ ! -f README.md ]]; then
    cat > README.md << 'RM'
# Workspace

Shared multi-bot workspace backed by Overwatch control-plane scripts under `overwatch/`.

Do not commit secrets, browser profiles, or large media. See `.gitignore`.
RM
  fi
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "NO_REMOTE"
  exit 2
fi

# Stage safe changes (respect .gitignore)
git add -A

if git diff --cached --quiet && git diff --quiet; then
  # Also check untracked that might have been ignored already — nothing staged
  if [[ -z "$(git status --porcelain)" ]]; then
    echo "NOTHING_TO_COMMIT"
    exit 0
  fi
fi

# If there is something staged or modified after add
if git diff --cached --quiet; then
  echo "NOTHING_TO_COMMIT"
  exit 0
fi

msg="overwatch backup: $(date -u +"%Y-%m-%d %H:%M UTC")"
git commit -m "$msg"

branch="$(git rev-parse --abbrev-ref HEAD)"
if ! git push -u origin "$branch"; then
  echo "AUTH_OR_PUSH_FAILED"
  exit 3
fi

echo "BACKUP_OK"
exit 0
