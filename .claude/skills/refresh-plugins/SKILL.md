---
name: refresh-plugins
description: Use when plugins behave unexpectedly, hooks are stale, or after marketplace updates. Flushes the plugin cache and pulls latest marketplace content. Also useful as weekly maintenance.
version: 1.0.0
---

# Refresh Plugins - Cache Flush & Marketplace Sync

## Why This Exists

Claude Code has a confirmed bug (GitHub #14061, #17361) where the plugin cache is keyed by version string. If marketplace authors update files without bumping the version, the cache stays stale forever. `autoUpdate: true` on marketplaces triggers git pulls but does NOT rebuild the cache.

This skill performs a full refresh: pull latest marketplace content + flush cache.

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

### Step 2: Show what's stale

Before flushing, compare cache vs marketplace to show what changed:

```bash
echo "=== Staleness check ==="
if [ -f ~/.claude/plugins/installed_plugins.json ]; then
  jq -r 'to_entries[] | "\(.key): cached=\(.value.gitCommitSha // "unknown")"' ~/.claude/plugins/installed_plugins.json | head -20
fi
```

### Step 3: Flush cache

```bash
echo "=== Flushing cache ==="
CACHE_SIZE=$(du -sh ~/.claude/plugins/cache/ 2>/dev/null | cut -f1)
rm -rf ~/.claude/plugins/cache/
echo "Removed $CACHE_SIZE of cached plugins"
echo "Cache will rebuild on next session start"
```

### Step 4: Verify marketplace autoUpdate

```bash
echo "=== autoUpdate status ==="
jq 'to_entries[] | "\(.key): autoUpdate=\(.value.autoUpdate // false)"' ~/.claude/plugins/known_marketplaces.json
```

If any show `false`, offer to set them to `true`.

## When to Use

- Plugin hooks behaving unexpectedly (blocking operations they shouldn't)
- After manually updating a marketplace repo
- Weekly maintenance (pair with `/upgrade-claude`)
- After installing/uninstalling plugins
- When ECC or other plugin hooks cause errors

## After Running

Start a new Claude Code session for the rebuilt cache to take effect.
