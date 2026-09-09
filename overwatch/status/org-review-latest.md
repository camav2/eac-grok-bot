# Org Review

- **timestamp:** 2026-09-09 06:03 UTC
- **bot count:** 10

## Bots

## Overwatch

- **id:** `02f11b8e-fe45-4bc2-92ee-42b540b7ed02`
- **description:** Keeps a shared multi-bot workspace organized, git-backed, and portable. Owns layout conventions, retention cleanup, a bot registry, and weekday backup plus weekly org recommendations.

## New Bot

- **id:** `728508eb-b931-41b8-9bc0-e7674da40d0a`
- **description:** (none)

## 🚦 Set Up

- **id:** `7fed5df5-9c35-4834-9454-a2fb7fbdae81`
- **description:** Walks someone new to Grok Bot through building a small, intentional team: one chief, a few project leads, and specialists. Asks one question at a time so the roster stays useful instead of chaotic.

## Launch Lead

- **id:** `916d4615-3e85-4d87-b5e7-649d003494d0`
- **title:** launch
- **description:** The user primarily works in as a launch lead for Expert Author Community intakes

## Chief

- **id:** `9244bfb2-10ae-4558-99ec-47d32e2ccddf`
- **description:** A personal chief of staff for people who run a small team of specialist AI agents. Coordinates calendar, projects, and inbound mail, runs weekday standup plus a private morning brief, and never sends messages as you unless you ask.

## Linkedin EAC Member Amplificaton

- **id:** `a9a9eb31-5f34-4b6f-9de3-3267e8b0881f`
- **title:** Linkedin
- **description:** The role of this bot: - watch Linkedin and amplify our members posts by reposting under the Expert Author Community Linkedin Page.

## Hello Inbox Support

- **id:** `cdd4618b-7886-4a27-84f2-08b219433396`
- **title:** Inbox
- **description:** Operation Assistant: - manages the hello@expertauthor.community inbox and day-to-day ops. - Looks for zoom events that have videos and uploads to Vimeo, preps, downloads transcripts to use in circle posts.

## Alfred

- **id:** `d4861718-9fac-4417-9ceb-0c0db09dc19a`
- **description:** Designs, audits, and governs your Grok Bot organization so it matches real company outcomes, with clear human owners and no duplicate jobs. Recommends the smallest useful structure, defaults new bots to zero, and never creates or changes anything without your exact yes.

## Linkedin Growth Lead

- **id:** `eaa007b1-6aff-4783-98dd-a4b7b85c60fa`
- **description:** (none)

## ✍️ Copy & Creative

- **id:** `f7afb032-0a80-45e1-ae4e-d32028d83b34`
- **description:** Specialist for Expert Author Community copywriting and creative. Writes and concepts LinkedIn posts, launch copy, emails, and campaign creative in one voice. Works from brand context and prior published work. Project leads (Linkedin Growth Lead, Launch Lead) delegate jobs here; do not invent new projects or spin up bots. Prefer Notion for drafts when available. Stay tightly scoped to words and creative concepts — scheduling, posting, and amplification stay with other specialists. Created by 🚦 Set Up on 2026.09.09 16:00 on Grok Bot.

## Disk hotspots under /workspace

```
397M	/workspace/whisper-venv
52M	/workspace/michelle-roundtable-sept.m4a
8.0M	/workspace/agent-tools
2.7M	/workspace/watchlist_batches
1016K	/workspace/gmail-archive-bin
748K	/workspace/eac_posts.json
228K	/workspace/transcripts
204K	/workspace/gmail-clear
96K	/workspace/eac_share_stats.json
48K	/workspace/overwatch
12K	/workspace/shared
12K	/workspace/eac_top_posts_summary.json
8.0K	/workspace/eac-alumni-thought-leader-engagement-plan.md
4.0K	/workspace/vimeo_upload_meta.json
4.0K	/workspace/batch6_ids.txt
4.0K	/workspace/batch5_ids.txt
4.0K	/workspace/batch3_ids.txt
4.0K	/workspace/batch13_ids.txt
4.0K	/workspace/README.md
```

## shared/temp and shared/archive

- `/workspace/shared/temp`: exists, size≈4.0K, entries=0
- `/workspace/shared/archive`: exists, size≈4.0K, entries=0

## Backup health

- git repo: yes
- origin: NONE
- last commit: (none yet)

## Convention notes (/workspace root)

Likely bot/project dirs vs clutter at /workspace root:

- **README.md** — repo meta (OK)
- **agent-tools/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)
- **batch13_ids.txt** — root file (review)
- **batch3_ids.txt** — root file (review)
- **batch5_ids.txt** — root file (review)
- **batch6_ids.txt** — root file (review)
- **eac-alumni-thought-leader-engagement-plan.md** — root file (review)
- **eac_posts.json** — file clutter / large artifact at root (prefer shared/temp or bot folder)
- **eac_share_stats.json** — file clutter / large artifact at root (prefer shared/temp or bot folder)
- **eac_top_posts_summary.json** — file clutter / large artifact at root (prefer shared/temp or bot folder)
- **gmail-archive-bin/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)
- **gmail-clear/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)
- **michelle-roundtable-sept.m4a** — file clutter / large artifact at root (prefer shared/temp or bot folder)
- **overwatch/** — control-plane / shared (convention OK)
- **shared/** — control-plane / shared (convention OK)
- **transcripts/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)
- **vimeo_upload_meta.json** — file clutter / large artifact at root (prefer shared/temp or bot folder)
- **watchlist_batches/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)
- **whisper-venv/** — tooling/clutter or job scratch (consider relocating under a bot folder or shared/temp)

## Recommendations

1. Add a git `origin` remote for /workspace and authenticate `gh`/`git push` so Overwatch backups can land off-box.
2. Registry has 2 bot(s) with empty/placeholder name or description — name them or archive unused agent folders to reduce roster clutter.
3. `whisper-venv/` is a disk hotspot at root; keep it gitignored and consider documenting which bot owns it, or relocate under that bot's folder.

