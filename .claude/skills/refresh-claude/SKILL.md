---
name: refresh-claude
author: Vvkmnn
description: Use when plugins behave unexpectedly, hooks are stale, or after marketplace updates. Flushes the plugin cache and pulls latest marketplace content. Also useful as weekly maintenance.
version: 1.1.0
---

# Refresh Plugins - Cache Flush & Marketplace Sync

## Why This Exists

Claude Code has confirmed bugs where plugin auto-update is broken end-to-end for third-party marketplaces:

1. **autoUpdate not set by default** (GitHub #10265, #26744) — third-party marketplaces don't get `autoUpdate: true` unless manually enabled via `/plugin` TUI.
2. **Cache keyed by version** (GitHub #14061, #17361) — if marketplace authors update files without bumping the version, the cache stays stale forever.
3. **Pointer not updated** (GitHub #17361) — even with a version bump and autoUpdate enabled, the updater downloads new versions to cache but never updates `installed_plugins.json` to point at them. Plugins keep running old code.

**Confirmed workaround:** deleting the stale cache directory forces a clean re-download with correct version pointers on next restart.

## Workflow

### Step 1: Pull all marketplace repos

```bash
echo "=== Pulling marketplaces ==="
for dir in ~/.claude/plugins/marketplaces/*/; do
  name=$(basename "$dir")
  if [ -d "$dir/.git" ]; then
    echo -n "$name: "
    git -C "$dir" pull --ff-only 2>&1 | tail -1
  else
    echo "$name: (not a git repo, skipping)"
  fi
done
```

### Step 2: Detect stale plugins

Compare installed version (in `installed_plugins.json`) vs latest available (in marketplace cache).
Show which plugins have newer versions downloaded but not activated.

```bash
echo "=== Staleness check ==="
for cache_dir in ~/.claude/plugins/cache/*/; do
  marketplace=$(basename "$cache_dir")
  for plugin_dir in "$cache_dir"*/; do
    plugin=$(basename "$plugin_dir")
    versions=$(ls "$plugin_dir" 2>/dev/null | sort -V)
    count=$(echo "$versions" | wc -w)
    if [ "$count" -gt 1 ]; then
      latest=$(echo "$versions" | tail -1)
      installed=$(grep -A5 "\"$plugin@$marketplace\"" ~/.claude/plugins/installed_plugins.json 2>/dev/null | grep '"version"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
      if [ -n "$installed" ] && [ "$installed" != "$latest" ]; then
        echo "STALE: $plugin@$marketplace — installed=$installed, available=$latest"
      fi
    fi
  done
done
```

### Step 3: Flush cache (targeted or full)

**Targeted** (preferred — only flushes stale marketplaces):

```bash
echo "=== Which marketplace to flush? ==="
ls ~/.claude/plugins/cache/
```

Ask the user which marketplace to flush, or offer to flush all. Then:

```bash
# Targeted: flush one marketplace
MARKETPLACE="claude-emporium"  # or whatever the user picks
CACHE_SIZE=$(du -sh ~/.claude/plugins/cache/$MARKETPLACE/ 2>/dev/null | cut -f1)
rm -rf ~/.claude/plugins/cache/$MARKETPLACE/
echo "Removed $CACHE_SIZE of $MARKETPLACE cached plugins"
```

**Full flush** (nuclear option):

```bash
CACHE_SIZE=$(du -sh ~/.claude/plugins/cache/ 2>/dev/null | cut -f1)
rm -rf ~/.claude/plugins/cache/
echo "Removed $CACHE_SIZE of cached plugins"
```

### Step 4: Verify marketplace autoUpdate

```bash
echo "=== autoUpdate status ==="
jq 'to_entries[] | "\(.key): autoUpdate=\(.value.autoUpdate // false)"' ~/.claude/plugins/known_marketplaces.json
```

If any show `false`, warn the user and offer to enable via `/plugin` TUI.

## When to Use

- Plugin hooks throwing `Cannot find module` or other require errors
- Plugin hooks behaving unexpectedly or running old code
- After marketplace authors push updates (version bumps)
- Weekly maintenance (pair with `/upgrade-claude`)
- When you see "N plugins failed to install" on startup
- After enabling `autoUpdate` on a marketplace for the first time

## After Running

Start a new Claude Code session for the rebuilt cache to take effect.
Verify with: `ls ~/.claude/plugins/cache/<marketplace>/<plugin>/` — should show only the latest version.
