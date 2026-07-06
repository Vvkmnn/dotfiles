---
name: save-space
author: Vvkmnn
description: Systematic disk space cleanup - recover 10-50GB by targeting highest-impact items first
---

# Disk Space Recovery

Use this skill when disk usage exceeds 70% or you need to free up significant space quickly.

## How to Run This Skill

1. **Baseline** - Record starting `df` AND `diskutil apfs list` (both matter, see APFS section)
2. **Blitz** - Run blitz mode first for instant 3-8GB (zero risk, no decisions)
3. **Assess** - Run assessment commands in parallel (they're independent). Include project dirs (Work/Projects/Dev) for backups and build artifacts
4. **Propose** - Present a ranked table of targets >500MB with sizes and risk levels
5. **Confirm** - Get user approval before deletions (especially sudo)
6. **Execute** - Delete in tiers, starting with biggest wins
7. **Empty Trash** - Always check `du -sh ~/.Trash` and empty after deletions. Deleted files don't free space until Trash is emptied
8. **Track** - After each batch, run `df -h /System/Volumes/Data` and report delta. Note: `df` may NOT drop if a TM snapshot exists — this is expected, not a failure
9. **Snapshots** - Delete old TM snapshots LAST (after all other cleanup). **This is critical**: every file deleted while a snapshot exists becomes "purgeable" but NOT freed. The snapshot deletion is what releases ALL accumulated space at once. Provide sudo command for user. Warn: if `df` hasn't moved despite deleting GBs, this is why
10. **Verify** - Final `df` and `diskutil apfs list` check

**Focus on targets >500MB.** Items under 500MB are rarely worth the effort unless doing a final sweep after all big targets are exhausted.

**sudo commands**: Claude cannot run sudo. Provide the exact commands and tell the user to run them in their terminal.

**Shell gotcha**: `find` may be aliased to `fd` (from Homebrew). Use `command find` for POSIX find behavior. Paths with brackets (e.g., `[Gmail].mbox`) need quoting — avoid glob expansion with `du -sh path/*`, use `command find path -maxdepth 1 -type d | while read d; do du -sh "$d"; done` instead.

---

## Blitz Mode (3-8GB, zero risk)

Check sizes first, then delete. All auto-rebuild on next use:

```bash
# Check sizes before deleting
echo "=== Blitz Mode Targets ==="
du -sh ~/.cache/uv ~/.npm/_npx ~/.npm/_cacache ~/.cache/puppeteer ~/.cache/prisma 2>/dev/null
du -sh ~/.cache/chrome-devtools-mcp 2>/dev/null
du -sh ~/.bun/install ~/Library/pnpm ~/.claude/debug 2>/dev/null
du -sh ~/Library/Application\ Support/Slack/Service\ Worker 2>/dev/null
du -sh ~/Library/Application\ Support/Code/CachedData 2>/dev/null
du -sh ~/Library/Application\ Support/Code/CachedExtensionVSIXs 2>/dev/null
du -sh ~/Library/Application\ Support/discord/logs ~/Library/Application\ Support/discord/Cache ~/Library/Application\ Support/discord/Code\ Cache 2>/dev/null
du -sh ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache 2>/dev/null
du -sh ~/Library/Caches/Google ~/Library/Caches/Homebrew 2>/dev/null
du -sh ~/Library/Caches/Steam ~/Library/Caches/node-gyp 2>/dev/null
du -sh ~/Library/Application\ Support/Steam/appcache 2>/dev/null
```

Then delete:

```bash
# Package manager caches
rm -rf ~/.cache/uv ~/.npm/_npx ~/.npm/_cacache ~/.cache/puppeteer ~/.cache/prisma
rm -rf ~/.cache/chrome-devtools-mcp ~/.cache/pip
rm -rf ~/.bun/install && mkdir -p ~/.bun/install
rm -rf ~/Library/pnpm  # Full nuke — pnpm store prune often has 0 effect
rm -rf ~/.claude/debug  # Debug logs, can grow to 800MB+
brew cleanup --prune=all && brew autoremove

# Electron app caches (rebuild on app open)
rm -rf ~/Library/Application\ Support/Slack/Service\ Worker
rm -rf ~/Library/Application\ Support/Code/CachedData
rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs
rm -rf ~/Library/Application\ Support/discord/logs ~/Library/Application\ Support/discord/Cache ~/Library/Application\ Support/discord/Code\ Cache

# Google caches
rm -rf ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache
rm -rf ~/Library/Caches/Google ~/Library/Caches/Homebrew
rm -rf ~/Library/Caches/Steam ~/Library/Caches/node-gyp

# Old Claude Code versions (keep latest)
cd ~/.local/share/claude/versions 2>/dev/null && ls -1 | grep -v "$(ls -t | head -1)" | xargs rm -f; cd -

# Steam cache
rm -rf ~/Library/Application\ Support/Steam/appcache/*

# Check delta
df -h /System/Volumes/Data
```

---

## Assessment

Run these in parallel to find where space is going:

```bash
# Disk state (THREE views — all matter)
df -h /System/Volumes/Data
diskutil apfs list | grep -E "Capacity In Use|Capacity Not Allocated" | head -4
tmutil listlocalsnapshots /

# Home directory breakdown
du -sh ~/* 2>/dev/null | sort -hr | head -15

# Hidden folders (dev tools, caches)
du -sh ~/.[^.]* 2>/dev/null | sort -hr | head -15

# Library subdirectories
for d in ~/Library/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15

# Applications by size
du -sh /Applications/* 2>/dev/null | sort -hr | head -15

# Project directories — scan for backups and build artifacts
du -sh ~/Work/*/ ~/Projects/*/ ~/Dev/*/ 2>/dev/null | sort -hr | head -20

# Large files (>500MB)
command find ~ -type f -size +500M 2>/dev/null -exec du -sh {} \; | sort -hr | head -15

# Downloads and Trash (ALWAYS check Trash — files aren't freed until emptied)
du -sh ~/Downloads ~/Temp ~/.Trash 2>/dev/null

# iOS device backups
du -sh ~/Library/Application\ Support/MobileSync/Backup 2>/dev/null

# Mail (often 5-20GB but mostly not actionable — see Mail section)
du -sh ~/Library/Mail 2>/dev/null

# Application Support deep dive
for d in ~/Library/Application\ Support/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15
```

After assessment, present findings as a ranked table (only items >500MB):

| Target | Size | Risk | Action |
|--------|------|------|--------|
| Time Machine snapshots | 15GB | None | sudo tmutil deletelocalsnapshots |
| ~/Downloads old files | 8GB | Low | Review and delete |
| Xcode.app | 4.7GB | None | sudo rm + switch to CLT |
| ... | ... | ... | ... |

---

## Tiers 1-3 + System Level

Full per-target runbook (Tier 1 big wins 5-20GB, Tier 2 medium 1-5GB, Tier 3 sweep, system-level manual actions): `references/tiers.md` — open when executing, after Assessment picks targets. Every deletion still needs per-path approval.

## Pitfalls

Common mistakes and gotchas from past cleanup sessions:

- **TM snapshots are the #1 recurring space problem**: If disk keeps growing despite cleanup, check `tmutil listlocalsnapshots /` FIRST. The external TM drive must be plugged in regularly (matching the backup frequency) or snapshots accumulate indefinitely. This has caused 10-30G+ of unexplained growth across multiple sessions. Fix: plug in drive (auto-prunes after backup) or `quicksave -d` to delete all snapshots manually
- **`pnpm` not in PATH**: Use `npx pnpm store prune` instead of `pnpm store prune`
- **Sparse files inflate sizes**: Colima/VM datadisks appear huge via `stat` or `ls -l` but actual disk usage is tiny. Always verify with `du -sh`
- **Docker on external SSD**: If `COLIMA_HOME` points to external storage, `docker system prune` frees space there, not on main SSD
- **`/private/var/folders`**: Never manually delete. Use Safe Mode boot instead - manual deletion can brick the Mac
- **APFS vs df discrepancy**: `diskutil apfs list` always shows higher % than `df` because it includes snapshots and purgeable space. Both numbers are correct for different purposes
- **sudo operations**: Claude cannot run sudo. Provide exact commands for the user to paste into their terminal
- **Small targets waste time**: Don't chase items under 500MB when multi-GB targets remain. Move to Tier 3 sweep only after Tier 1 and 2 are done
- **Time Machine creates new snapshots**: After deleting snapshots, TM may create new ones. Check again after a few hours if % seems unchanged
- **Purgeable space blocking installs**: If apps refuse to install despite "available" space, APFS purgeable space isn't being reclaimed. Force it: `dd if=/dev/zero of=~/bigfile.tmp bs=20m; rm ~/bigfile.tmp` - this fills the disk forcing APFS to purge, then removes the temp file
- **Rust 1.88+ auto GC**: Cargo 1.88+ has automatic garbage collection of old registry/cache entries. On older versions, use `cargo cache --autoclean` (install with `cargo install cargo-cache`)
- **Trash must be emptied**: Deleting files (even `rm -r` from Finder) may send to Trash instead of freeing space. Always check `du -sh ~/.Trash` and empty with `rm -r ~/.Trash/*` after bulk deletions
- **`find` aliased to `fd`**: On systems with `fd` installed, `find` may be aliased. Use `command find` for POSIX behavior. Bracket paths like `[Gmail].mbox` also break glob expansion — quote carefully
- **Multiple APFS containers**: Macs with external drives (especially TM SSDs) have multiple APFS containers. Menu bar disk widgets may show the wrong container's %. Always verify with `diskutil apfs list` and match the container to the physical disk
- **Mail cleanup is mostly cosmetic**: Synced IMAP/Gmail accounts re-download mail. "Erase Deleted Items" and "Erase Junk" only help if there's actually accumulated junk. The bulk of Mail storage is "All Mail" which can't be reduced without removing the account or server-side deletion
- **Mason packages auto-reinstall**: LazyVim's `ensure_installed` and extras configs re-download deleted Mason packages on next Neovim open. To permanently remove, also remove from `~/.config/nvim/` config
- **pnpm store prune is useless**: `npx pnpm store prune` often reports "Removed 0 packages" even with 3.4GB store. Use `rm -rf ~/Library/pnpm` instead — packages reinstall on demand
- **TM snapshot blocks ALL space recovery**: Deleting files while a snapshot exists doesn't free space — it becomes "purgeable" held by the snapshot. Delete the snapshot LAST after all other cleanup to release everything at once. This is the single most impactful step
- **iCloud resync after macOS updates**: CloudKit cache (4GB+), CloudDocs session (5-7GB), and FileProvider (3GB) can balloon after major updates. This is temporary (24-48h) — don't delete CloudDocs or FileProvider, they rebuild worse if nuked
- **App Store apps need sudo to delete**: `rm -rf /Applications/Pages.app` fails with permission denied. Use `sudo mas uninstall <app-id>` (install mas via `brew install mas`) or `sudo rm -rf`
- **Duplicate iWork apps after macOS updates**: macOS updates can install "Creator Studio" versions of Pages/Keynote alongside old ones. Check with `mas list | grep -iE "pages|keynote"` — the newer version has bundle ID `com.apple.Pages`, the old one has `com.apple.iWork.Pages`
- **macOS Install Data (3.5GB)**: Left over after macOS updates. Safe to delete with `sudo rm -rf "/System/Volumes/Data/macOS Install Data"` after successful update. "Locked Files" subfolder may need SIP disable. Alternative: wait — macOS cleans it up eventually
- **"Put hard disks to sleep" removed from UI**: In macOS Tahoe, this setting is gone from System Settings > Battery > Options. Use `sudo pmset -a disksleep 0` instead. Only affects spinning HDDs, no battery impact on SSDs
- **Disk full = macOS crashes**: macOS needs ~10-15% free for swap, iCloud sync, and system operations. Below that, expect freezes, app crashes, and kernel panics. If at >80%, treat cleanup as urgent
- **~/.claude/debug grows silently**: Debug log directory can accumulate thousands of files (800MB+). Safe to nuke entirely — `rm -rf ~/.claude/debug`
- **CloudKit cache balloons post-update**: `~/Library/Caches/CloudKit/com.apple.bird` can hit 4GB+ during iCloud resync after macOS updates. It's temporary — don't manually delete, it rebuilds and extends the sync. Let it settle over 24-48h
- **Enable "Optimize Mac Storage" for iCloud**: System Settings > Apple ID > iCloud > iCloud Drive > toggle on. Keeps only recent files locally, offloads rest to cloud. Essential on 256GB Macs

---

## Reference

### APFS vs df

`df` and `diskutil apfs list` report different numbers:
- **`df`** shows actual consumed space - what you feel day-to-day
- **`diskutil apfs list`** includes APFS metadata, snapshots, and purgeable space
- APFS % is always higher than df %. Both are correct for different purposes

**Multiple APFS containers**: Macs with external drives (Time Machine SSDs, etc.) have multiple APFS containers. Each reports its own capacity/usage. Menu bar disk widgets (iStatistica, Stats, etc.) may show the wrong container — a TM drive at 80% instead of the internal data volume at 66%. Always verify which container you're looking at:
```bash
# Show all containers with their physical disks
diskutil apfs list | grep -E "Container|Capacity|Physical Store"
# Match container to physical disk to know which is internal vs external
```

### Safety Rules

**Always safe to delete:**
- Package manager caches (`~/.cache/uv`, `~/.npm/_npx`, `~/.bun/install`, `~/.cache/pip`, `~/.cargo/registry/cache`)
- Build artifacts (`target/`, `build/`, `dist/`, `.venv` in inactive projects)
- Browser automation caches (Puppeteer, Playwright, chrome-devtools-mcp)
- Old application versions (keep latest only)
- Electron app caches (Slack Service Worker, VS Code CachedData)
- Google Updater crx_cache
- Old Time Machine snapshots (keep most recent)
- Trash contents
- Xcode DerivedData

**Requires consideration:**
- `node_modules/` - only if project is inactive
- Application support data - check if app is actively used
- Chrome variant data - only for unused variants
- Xcode.app - only if CLT is sufficient for workflow
- iOS backups - only if using iCloud backup
- AI model files - only for tools no longer used
- Neovim Mason packages - verify you don't use the LSP
- Mail - make sure old emails aren't needed

**Never delete:**
- Active project source code
- `~/.ssh/` - SSH keys
- `~/.aws/` - AWS credentials
- Active `COLIMA_HOME` directory (check `echo $COLIMA_HOME`)
- `~/.claude/` (except legacy backups)
- `/private/var/folders` manually (use Safe Mode boot)
- `/private/var/db`, `/private/var/vm` - system critical

### Expected Recovery

| Tier | Typical Range | Depends On |
|------|---------------|------------|
| Blitz Mode | 3-8GB | How long since last cleanup |
| Tier 1 (Big Wins) | 10-30GB | TM snapshots, Xcode, active projects |
| Tier 2 (Medium) | 3-15GB | Chrome variants, unused apps, iOS backups, Mail |
| Tier 3 (Sweep) | 1-5GB | Abandoned tools, caches |
| System Level | 2-10GB | /var/folders, CleanMyMac findings |
| **Total possible** | **15-50GB** | |

### Maintenance Schedule

**Monthly**: Blitz Mode (package caches, Electron caches, old versions)
**Quarterly**: Full audit including Tier 2 (apps, Chrome, iOS backups, Mail)
**As needed**: Time Machine snapshots, CleanMyMac, Safe Mode boot
**After major work**: Clean build artifacts when switching projects
