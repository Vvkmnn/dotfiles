# Health Phase — Full Validation Runbook

Extracted from upgrade-claude v1.1.0 (archived), refreshed to the 2.1.20x era.

## Component Inventory

```bash
echo "=== Component Inventory ==="
echo "Settings keys: $(jq 'keys | length' ~/.claude/settings.json)"
echo "Hooks: $(ls ~/.claude/hooks/*.js 2>/dev/null | wc -l | tr -d ' ')"
echo "Rules: $(ls ~/.claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "Skills (owner): $(ls -d ~/.claude/skills/*/ 2>/dev/null | grep -v .archive | wc -l | tr -d ' ')"
echo "Agents: $(ls ~/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "Commands: $(ls ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "CLAUDE.md lines: $(wc -l < ~/.claude/CLAUDE.md | tr -d ' ')"
echo "Plugins enabled: $(jq '.enabledPlugins | to_entries | map(select(.value == true)) | length' ~/.claude/settings.json)"
```

## Validation

```bash
jq . ~/.claude/settings.json > /dev/null 2>&1 && echo "OK settings.json" || echo "INVALID settings.json"
for hook in ~/.claude/hooks/*.js; do node --check "$hook" && echo "OK $(basename $hook)"; done
bash -n ~/.claude/statusline.sh && echo "OK statusline.sh"

# Rule references in CLAUDE.md all exist
grep -oE '[a-z-]+\.md' ~/.claude/CLAUDE.md | sort -u | while read f; do
  test -f ~/.claude/rules/$f && echo "OK $f" || echo "MISSING rules/$f"
done

# Agent frontmatter summary
for agent in ~/.claude/agents/*.md; do
  echo "$(basename $agent): model=$(grep -m1 '^model:' $agent | cut -d' ' -f2) effort=$(grep -m1 '^effort:' $agent | cut -d' ' -f2) memory=$(grep -m1 '^memory:' $agent | cut -d' ' -f2)"
done

# Agent REGISTRATION check (2026-07-06 lesson: invalid YAML silently deregisters —
# raw XML in frontmatter broke 3 agents once). Compare files vs live agent types:
# every agents/*.md name should appear in the session's available subagent types;
# a file present but not registered = frontmatter parse failure. Verify YAML with:
for agent in ~/.claude/agents/*.md; do
  python3 -c "import yaml,sys; yaml.safe_load(open('$agent').read().split('---')[1])" 2>/dev/null \
    && echo "OK $(basename $agent)" || echo "FRONTMATTER BROKEN: $agent"
done
```

## Budget Sweep

```bash
echo "=== Budgets (owner surfaces only — vendored skills exempt) ==="
wc -l ~/.claude/CLAUDE.md                                   # ≤160 (recalibrated 2026-07-06)
wc -l ~/.claude/rules/*.md | sort -rn | head -12            # each ≤200 (recalibrated 2026-07-06)
find ~/.claude/skills -maxdepth 2 -name SKILL.md -not -path "*.archive*" \
  | grep -vE "docx|pdf|pptx|xlsx|mcp-builder|webapp-testing|vercel|web-design|impeccable|claude-praetorian" \
  | xargs wc -l | sort -rn | head -10                       # each OWNER ≤425
wc -l ~/.claude/agents/*.md                                 # each ≤90
```

## Drift Gates

```bash
# Stale model names (update the pattern when a new generation ships)
grep -rnE "opus[- ]?4[.-][0-6]|sonnet[- ]?4[.-][0-5]|haiku[- ]?3" \
  ~/.claude/CLAUDE.md ~/.claude/rules ~/.claude/agents ~/.claude/commands 2>/dev/null | grep -v .archive

# Dead skill references
for name in $(grep -ohE '`[a-z-]+`' ~/.claude/CLAUDE.md ~/.claude/rules/*.md | tr -d '\`' | sort -u); do
  if [ -d ~/.claude/skills ] && ls ~/.claude/skills | grep -qx "$name"; then :; fi
done  # manual review pass — flag names that look like skills but have no directory

# Doc freshness — git is the timestamp authority (no > Updated: markers; they drift)
for f in .claude/README.md .claude/CLAUDE.md .claude/docs/*.md; do
  echo "$(git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log -1 --format=%cs -- "$f" 2>/dev/null || echo uncommitted) $f"
done

# CHANGELOG last entry age (entry dates are content, not markers)
grep -m1 -oE "20[0-9]{2}-[0-9]{2}-[0-9]{2}" ~/.claude/docs/CHANGELOG.md
```

## Feature-Era Checklist (2.1.20x)

When auditing against CHANGELOG, verify these are configured deliberately (not by omission):

| Feature | Where | Since |
|---------|-------|-------|
| Background subagents (default) | agent `background:` only forces it | 2.1.198 |
| Explore inherits main model (capped Opus) | haiku override for cheap scans | 2.1.198 |
| `effort` frontmatter (skills + subagents, NOT commands) | low/medium/high/xhigh | 2.1.15x+ |
| `/effort` + `CLAUDE_CODE_EFFORT_LEVEL` + `$CLAUDE_EFFORT` in hooks | session/env | 2.1.15x+ |
| Fable 5 (`fable` alias, 1M default, thinking always-on) | model config | 2.1.170 |
| `/fast` mode | Opus 4.8 sessions only | 2.1.15x |
| subagentStatusLine | settings.json | 2.1.1xx |
| Statusline stdin: effort.level, thinking.enabled, cost.total_cost_usd, context_window.* | statusline.sh | 2.1.1xx+ |
| Agent teams | CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 (June 15 breaking change: auto-spawn) | experimental |
| Native memory (/memory, MEMORY.md) + /rewind + file-history | replaces custom memory/checkpoint layers | 2.1.1xx |
