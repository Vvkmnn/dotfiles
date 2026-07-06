# Cleanup Tiers Runbook (1: Big Wins · 2: Medium · 3: Sweep · System)

> Moved verbatim from SKILL.md (lines 138-557) in the 2026-07-06 restructure — the full per-target commands. SKILL.md keeps blitz mode + assessment + pitfalls; open this when executing tiers.

## Tier 1: Big Wins (5-20GB each)

### Time Machine Local Snapshots (5-30GB+)

**Often the single biggest win — and the most invisible.** Snapshots hold references to ALL deleted files since the snapshot was created. This means every other cleanup step (caches, backups, build artifacts) may not show up in `df` until old snapshots are deleted.

**Critical ordering**: Delete snapshots LAST, after all other cleanup. This ensures the snapshot references to deleted files are released. A snapshot created before cleanup holds references to everything you deleted — removing it releases all that space at once.

**APFS purgeable gotcha**: `df` may show minimal improvement after deletions because APFS marks freed-but-snapshot-referenced space as "purgeable" rather than "free." The space only truly frees when the referencing snapshot is deleted. This can make it look like cleanup didn't work when it actually did.

```bash
# List all snapshots
tmutil listlocalsnapshots /

# Check APFS container to see purgeable vs truly free
diskutil apfs list | grep -E "Capacity In Use|Capacity Not Allocated" | head -4

# Delete old ones (keep most recent) - USER MUST RUN THESE
# sudo tmutil deletelocalsnapshots <date>
# Repeat for each old snapshot date
```

**Preventing snapshot creep — the #1 recurring space problem:**

Local snapshots are TM's safety net between external backups. They only prune after a successful backup to the external drive. If the external drive isn't plugged in regularly, snapshots accumulate silently and can consume 10-30G+ within weeks. This has been the single largest cause of unexplained disk growth across multiple cleanup sessions.

**How it works in macOS Sequoia/Tahoe:** Snapshot creation frequency follows the backup frequency setting (changed from older macOS where snapshots were always hourly):
- Every Hour → ~168 snapshots/week (10-20G+)
- Every Day → ~7 snapshots/week (3-7G)
- Every Week → ~1 snapshot/week (1-2G)
- Manually → 0 snapshots

**Recommended: "Automatically Every Week" + plug in external drive weekly.** This creates only ~1 local snapshot between plug-ins. When the drive connects, TM backs up automatically and prunes the snapshot. Minimal disk cost, forget-proof, auto-prunes.

**The failure mode (has happened twice):** User sets Weekly but leaves the external drive unplugged for a month+. Snapshots accumulate, hold references to all deleted files as "purgeable" space, and `df` shows disk usage climbing even after cleaning caches. Fix: plug in the drive (triggers backup + prune), or delete snapshots manually with `sudo tmutil deletelocalsnapshots <date>`.

**Diagnosis checklist when disk space keeps climbing:**
1. `tmutil listlocalsnapshots /` — if stale snapshots exist, this is likely the cause
2. `tmutil destinationinfo` — check if TM destination is connected/reachable
3. `tmutil latestbackup` — when was the last successful backup? If weeks ago, snapshots are accumulating
4. Fix: plug in external drive and let backup complete, OR delete snapshots manually

**`tmutil disablelocal` is deprecated** — throws `Unrecognized verb` on modern macOS. The only way to stop automatic snapshots is System Settings > General > Time Machine > Options > Backup Frequency > Manually. macOS Tahoe only offers: Manually, Every Hour, Every Day, Every Week (no Monthly option).

**On-demand snapshots for risky installs (`quicksave`):** Before installing anything outside the App Store or running `npm install`/`pip install` on untrusted packages:
```bash
quicksave        # creates APFS snapshot (alias for sudo tmutil snapshot)
quicksave -l     # list existing snapshots
quicksave -d     # delete all snapshots to reclaim space
```
Creates a local APFS snapshot recoverable from Recovery Mode. Read-only after creation (malware running post-snapshot can't tamper with it). macOS auto-reclaims these as disk fills.

**Compromise recovery strategy:**
- Local snapshots are NOT reliable for compromise recovery (live on the same disk, can be tampered with by privileged malware)
- External TM backup is the trustworthy restore point — especially if the drive was unplugged during the compromise window
- For confirmed compromise: clean install via Recovery Mode + selective data restore from TM (not full TM restore, which would restore the malware too)
- `quicksave` before risky installs gives a pre-compromise restore point accessible from Recovery Mode

### Project Backups and Old Copies (5-50GB)

Scan project directories for old backups, copies, and exported artifacts. These are often the single largest user-created space hog and easy to miss:

```bash
# Scan all project directories for large items
du -sh ~/Work/*/ ~/Projects/*/ ~/Dev/*/ 2>/dev/null | sort -hr | head -20

# Look for backup/copy patterns
command find ~/Work ~/Projects ~/Dev -maxdepth 3 -type d \( -name "*.backup" -o -name "*.bak" -o -name "*-backup" -o -name "*-old" -o -name "*-copy" -o -name "dist" -o -name "build" \) 2>/dev/null | while read d; do du -sh "$d"; done | sort -hr | head -10
```

Common offenders: project `.backup` dirs with bundled ML models, exported `dist/` folders with compiled assets, old project copies made before major refactors. Ask before deleting — user may want to handle these manually.

### Xcode vs Command Line Tools (4-7GB)

Full Xcode is unnecessary if not doing iOS/macOS GUI development. CLT provides git, clang, make - everything Homebrew and dev workflows need.

```bash
# Check if Xcode is installed
du -sh /Applications/Xcode.app 2>/dev/null

# Remove Xcode, keep CLT - USER MUST RUN THESE:
# sudo rm -rf /Applications/Xcode.app
# rm -rf ~/Library/Developer/Xcode
# rm -rf ~/Library/Developer/CoreSimulator
# rm -rf ~/Library/Developer/XCTestDevices
# rm -rf ~/Library/Caches/com.apple.dt.Xcode
# sudo xcode-select -s /Library/Developer/CommandLineTools

# Verify CLT works after removal:
# xcode-select -p    # Should show /Library/Developer/CommandLineTools
# git --version      # Should work
# clang --version    # Should work
```

Reinstall from App Store if ever needed.

**Even if Xcode is already removed**, leftover developer data may remain:
```bash
# DerivedData - build artifacts, safe to delete (Xcode rebuilds as needed)
du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null
rm -rf ~/Library/Developer/Xcode/DerivedData

# Archives - old app builds (safe if already submitted/not needed)
du -sh ~/Library/Developer/Xcode/Archives 2>/dev/null
rm -rf ~/Library/Developer/Xcode/Archives

# iOS DeviceSupport - debug symbols (~4GB per iOS version connected)
du -sh ~/Library/Developer/Xcode/iOS\ DeviceSupport 2>/dev/null
# rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport

# Old simulators
xcrun simctl delete unavailable 2>/dev/null

# SwiftUI preview caches
xcrun simctl --set previews delete all 2>/dev/null

# Simulator and Xcode logs
rm -rf ~/Library/Logs/CoreSimulator
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

### iOS Simulator Runtimes (20-150GB — biggest potential dev hog)

Each simulator runtime is 2.5-15GB. Multiple Xcode upgrades accumulate old runtimes silently. This is the single most-reported surprise on developer forums.

```bash
# Check installed runtimes (each one is multi-GB)
du -sh /Library/Developer/CoreSimulator/Profiles/Runtimes/* 2>/dev/null
du -sh /Library/Developer/CoreSimulator/Images 2>/dev/null

# Check simulator devices
du -sh ~/Library/Developer/CoreSimulator/Devices 2>/dev/null

# Delete unavailable/old simulators
xcrun simctl delete unavailable

# Remove old runtimes via Xcode: Settings > Platforms > delete old versions
```

If zero results on runtimes, the machine is clean — this is a good sign, not a missed target.

### Build Artifacts (5-40GB if active)

```bash
# Rust projects - target/ directories
find ~/Projects ~/Dev -name "Cargo.toml" -type f 2>/dev/null | while read f; do
    dir=$(dirname "$f")
    if [ -d "$dir/target" ]; then
        echo "$(du -sh "$dir/target" 2>/dev/null | cut -f1) - $dir"
    fi
done

# Node projects - node_modules (only delete if project is inactive)
find ~/Projects ~/Dev -name "node_modules" -type d -maxdepth 3 2>/dev/null | while read dir; do
    echo "$(du -sh "$dir" 2>/dev/null | cut -f1) - $dir"
done

# Go caches
du -sh ~/go/pkg/mod 2>/dev/null
go clean -cache -n 2>/dev/null | wc -l  # Build cache (show count)
# go clean -cache      # Clears build cache (rebuilds on next compile)
# go clean -modcache   # Clears module cache (re-downloads on next build)

# Rust/Cargo global cache
du -sh ~/.cargo/registry ~/.cargo/git 2>/dev/null
# cargo cache --autoclean  # If cargo-cache installed
# Or manually: rm -rf ~/.cargo/registry/cache ~/.cargo/registry/src

# Python virtual environments in inactive projects
find ~/Projects ~/Dev -name ".venv" -type d -maxdepth 3 2>/dev/null | while read dir; do
    echo "$(du -sh "$dir" 2>/dev/null | cut -f1) - $dir"
done
```

### Large Files + Downloads + Trash (2-10GB)

```bash
# Old installers and archives in Downloads (>30 days old)
find ~/Downloads -type f \( -name "*.dmg" -o -name "*.pkg" -o -name "*.zip" -o -name "*.tar.gz" -o -name "*.iso" \) -mtime +30 -exec du -sh {} \;

# Screen recordings
du -sh ~/Library/Group\ Containers/group.com.apple.screencapture/ScreenRecordings/ 2>/dev/null
ls -lhS ~/Temp/ 2>/dev/null | head -10

# Trash
du -sh ~/.Trash 2>/dev/null
rm -rf ~/.Trash/*
```

---

## Tier 2: Medium Wins (1-5GB each)

### Package Manager Caches (3-10GB)

Already covered in Blitz Mode. If skipped, these are the individual targets:

| Cache | Location | Typical Size |
|-------|----------|--------------|
| Python uv | `~/.cache/uv` | 2-10GB |
| npm npx | `~/.npm/_npx` | 1-5GB |
| pip | `~/.cache/pip` | 200MB-2GB |
| Bun | `~/.bun/install` | 100MB-1GB |
| pnpm store | `~/Library/pnpm` | 2-5GB (prune unreferenced) |
| Go modules | `~/go/pkg/mod` | 500MB-3GB |
| Go build cache | `go clean -cache` | 500MB-2GB |
| Cargo registry | `~/.cargo/registry` | 500MB-3GB |
| Rustup toolchains | `~/.rustup/toolchains` | 500MB-2GB (old versions) |
| Homebrew | `brew cleanup -s` | 200MB-1GB |
| Browser automation | `~/.cache/puppeteer`, `~/.cache/prisma` | 200MB-1GB |

### Chrome Variant Data (1-3GB)

Unused Chrome variants (Dev/Beta/Canary) accumulate profile data even when not actively used:

```bash
# Check which variants have data
du -sh ~/Library/Application\ Support/Google/Chrome\ Dev 2>/dev/null
du -sh ~/Library/Application\ Support/Google/Chrome\ Beta 2>/dev/null
du -sh ~/Library/Application\ Support/Google/Chrome\ Canary 2>/dev/null

# Google Updater cache (often 1GB+, always safe)
rm -rf ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache

# Remove data for unused variants
# rm -rf ~/Library/Application\ Support/Google/Chrome\ Dev
```

### Unused/Duplicate Applications (1-5GB)

```bash
du -sh /Applications/* 2>/dev/null | sort -hr | head -20
```

Common candidates:
- **Duplicate apps**: Same app from both App Store and direct download (e.g., CleanMyMac)
- **Archiver apps**: Multiple archive tools when one suffices
- **Screen recording**: Multiple overlapping tools
- **Browsers**: Multiple Chrome variants (~1.2GB each)
- **Abandoned editors**: Cursor, Zed, Windsurf if not actively used

### iOS Device Backups (1-50GB)

```bash
du -sh ~/Library/Application\ Support/MobileSync/Backup 2>/dev/null
# If using iCloud backup, local backups are redundant
# rm -rf ~/Library/Application\ Support/MobileSync/Backup/*
```

### Mail (5-20GB) — Often Not Actionable

```bash
du -sh ~/Library/Mail 2>/dev/null
```

**Reality check**: Mail size is mostly your synced email (IMAP/Gmail "All Mail"). Erasing Deleted Items and Junk Mail rarely makes a significant dent because the bulk is in `[Gmail].mbox/All Mail.mbox` — your actual email archive synced from the server.

**What actually helps:**
- Mailbox > Erase Deleted Items (All Accounts) — minor, clears local deleted cache
- Mailbox > Erase Junk Mail — minor
- **Remove unused email accounts** from Mail.app — biggest win, stops syncing entirely
- **Delete old emails from Gmail server** (in browser) — reduces what syncs locally
- **Switch to browser-only email** — removes Mail storage entirely

**What doesn't help**: Deleting local Mail files — Mail.app re-downloads everything from the server on next sync. Don't waste time here unless removing an account entirely.

To investigate what's using space inside Mail:
```bash
# Use command find (not fd) due to bracket paths like [Gmail].mbox
command find ~/Library/Mail/V10 -maxdepth 3 -type d -name "*.mbox" | while read d; do du -sh "$d"; done | sort -hr | head -10
```

### AI Model Files (500MB-2GB)

AI tools often download large model files:

```bash
# Check for AI/ML model caches
du -sh ~/Library/Application\ Support/superwhisper 2>/dev/null
du -sh ~/.ollama/models 2>/dev/null
du -sh ~/Library/Application\ Support/LM\ Studio 2>/dev/null
du -sh ~/.cache/huggingface 2>/dev/null
du -sh ~/.keras 2>/dev/null
```

Delete model files only for tools you no longer use.

### Photos Optimization

If Photos library is large, enable "Optimize Mac Storage" in:
System Settings > Apple ID > iCloud > Photos

This keeps only recent/viewed photos locally, others stay in iCloud. Can free 10-50GB depending on library size.

---

## Tier 3: Sweep (0.2-1.5GB each)

### Electron App Caches (0.5-1.5GB)

Already covered in Blitz Mode. These rebuild when the app opens:
- Slack Service Worker (~500MB)
- VS Code CachedData + CachedExtensionVSIXs (~400MB)
- Discord logs + Cache + Code Cache (~200-500MB)

### Abandoned Dev Tool Directories (0.2-1GB)

Use discovery, don't hardcode names:

```bash
# Find large hidden dirs in home
du -sh ~/.[^.]* 2>/dev/null | sort -hr | head -20

# Also check .local/share
du -sh ~/.local/share/*/ 2>/dev/null | sort -hr | head -10
```

Common candidates: `.opencode`, `.gemini`, `.codex`, `.windsurf`, `.cursor`, `.zed`, `.nvm.bak`, `.claude-mem`, `.chrome-debug-profile`, `.m2` (Maven), `.gradle`

Delete only after confirming the tool is no longer used.

### System/User Caches (0.5-2GB)

```bash
# User caches (safe)
rm -rf ~/Library/Caches/Homebrew
rm -rf ~/Library/Caches/Google
rm -rf ~/Library/Caches/Steam
rm -rf ~/Library/Caches/node-gyp
rm -rf ~/Library/Caches/colima

# CrashReporter logs (safe, just old crash dumps)
du -sh ~/Library/Logs/DiagnosticReports 2>/dev/null
rm -rf ~/Library/Logs/DiagnosticReports

# Log files
du -sh ~/Library/Logs 2>/dev/null
# rm -rf ~/Library/Logs/*
```

### Old Application Versions (0.5-1GB)

```bash
# Claude Code - keep only latest
cd ~/.local/share/claude/versions 2>/dev/null
ls -lt | head -2  # Check current version
ls -1 | grep -v "$(ls -t | head -1)" | xargs rm -f

# Neovim Mason - audit large LSP packages
du -sh ~/.local/share/nvim/mason/packages/* 2>/dev/null | sort -hr | head -10
# Common large ones: clangd (~350MB), ltex-ls (~300MB), codelldb (~135MB)

# Check if a package auto-reinstalls (LazyVim extras / ensure_installed):
# grep -r "package_name" ~/.config/nvim/
# If listed in config, Mason will re-download it on next Neovim open.
# This makes deletion safe but temporary — remove from config too if unwanted.

# Check last-used timestamps to find stale packages:
# stat -f "%Sm - %N" ~/.local/share/nvim/mason/packages/*/bin/* 2>/dev/null | sort

# Remove unused: rm -rf ~/.local/share/nvim/mason/packages/<name>
```

### Application Support Deep Dive

```bash
for d in ~/Library/Application\ Support/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15
```

Known safe to clean:
- `Google/GoogleUpdater/crx_cache` - 1GB+, always safe
- `Steam/appcache` - cache only

Leave alone:
- `com.apple.wallpaper` - macOS managed
- `CloudDocs` - iCloud sync
- `MobileSync` - covered in iOS backups section

### Docker on External Storage

If Docker runs via Colima with `COLIMA_HOME` on an external SSD, images are NOT on the main disk. `docker system prune` only frees external storage.

Check for stale old Colima instances on main SSD:

```bash
# Check for old instance
du -sh ~/.config/colima 2>/dev/null

# If migrated to external SSD, remove old one
# COLIMA_HOME=~/.config/colima colima stop 2>/dev/null
# COLIMA_HOME=~/.config/colima colima delete --force 2>/dev/null
# rm -rf ~/.config/colima ~/Library/Caches/colima
```

If Docker is on main SSD: `docker system prune -a -f` can free 2-10GB.

---

## System Level (Requires Manual Action)

### /private/var/folders (2-5GB)

**WARNING: Do NOT manually delete /private/var/folders.** This can render Macs unbootable.

Safe alternative: **Safe Mode boot** triggers macOS cleanup of these caches.
- Apple Silicon: Shut down > Hold power button > Select Safe Mode > Boot > Restart normally
- Clears caches older than 3 days and rebuilds system temp files safely

### CleanMyMac

Run after completing manual cleanup for system-level items that Claude can't access:
- System cache files
- Application logs
- Browser caches (system-level)
- iOS device backups
- Broken downloads
- Mail attachments and downloads

---

