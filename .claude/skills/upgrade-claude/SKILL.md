---
name: upgrade-claude
description: Use after Claude Code binary updates, weekly maintenance, or when optimizing setup. Comprehensive self-improvement system reviewing settings, hooks, plugins, rules, CLAUDE.md against changelog and community best practices.
version: 1.0.0
---

# Upgrade Claude - Post-Update Optimization

## Purpose

After every Claude Code upgrade or weekly, this skill:
1. Checks what's new in CHANGELOG since last upgrade
2. Runs health checks (`/doctor`, validation)
3. Reviews setup against community best practices
4. Analyzes usage patterns from claude-historian
5. Suggests specific improvements with diffs
6. Never auto-edits - always gets approval

## Immediate Post-Upgrade Checklist

Run these first:
```bash
claude --version                    # Verify new version active
claude doctor                       # Check installation health
cat ~/.claude/.last-update-check    # When was last review?
```

## Components Reviewed

| Component | What to Check | Target |
|-----------|---------------|--------|
| `settings.json` | New settings, deprecated options, optimal values | Valid JSON, no deprecated |
| `hooks/` | 8 hook types, <500ms startup, syntax validity | All syntax valid |
| `plugins/` | Updates available, unused to remove, new useful | <10 MCPs active |
| `rules/` | Coverage gaps, outdated refs, token efficiency | <50 lines each |
| `CLAUDE.md` | Structure, instruction count, link validity | <300 lines, ~150 instructions |
| `skills/` | Stale patterns, missing common workflows | Current patterns |
| `commands/` | Missing commands for repetitive tasks | Cover common ops |
| `.claudeignore` | Context exclusions configured | Appropriate exclusions |

## Intelligence Sources

| Source | What It Provides | Access |
|--------|------------------|--------|
| CHANGELOG | New features, deprecations, breaking changes | WebFetch raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md |
| claude-historian | Past decisions, pain points, what worked | mcp__claude-historian-mcp__search_conversations |
| Anthropic best practices | Official recommendations | WebFetch anthropic.com/engineering/claude-code-best-practices |
| HumanLayer | CLAUDE.md patterns, anti-patterns | WebFetch humanlayer.dev/blog/writing-a-good-claude-md |
| GitHub 2500 repos | Lessons from agent configs | WebFetch github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/ |
| Community configs | Power user setups, new patterns | Explore agents (GitHub search) |
| awesome-claude-code | Curated tools and integrations | github.com/hesreallyhim/awesome-claude-code |
| awesome-claude-skills | Curated community skills collection | github.com/ComposioHQ/awesome-claude-skills |
| claude-code-best-practice | Curated best practices and examples | github.com/shanraisshan/claude-code-best-practice |
| skills.sh | Community skills ecosystem | Browse skills.sh, `npx skills add <repo> --list` |
| /stats | Context efficiency | Run in session |
| /doctor | Installation health | Run in session |

## Workflow

### Phase 1: Version & Health Check

```bash
# Version info
CURRENT_VERSION=$(claude --version | head -1)
LAST_CHECK=$(cat ~/.claude/.last-update-check 2>/dev/null || echo "Never")
echo "Current: $CURRENT_VERSION"
echo "Last check: $LAST_CHECK"

# Health check
claude doctor
```

### Phase 2: Fetch & Parse CHANGELOG

```
WebFetch: https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md
Prompt: "Extract all changes since [LAST_VERSION]. For each version list:
- New settings added
- New hook types or events
- New CLI flags or commands
- Deprecations and breaking changes
- New features worth adopting"
```

**Key v2.1.x features to verify:**

| Feature | Check | Why It Matters |
|---------|-------|----------------|
| Plan mode | `permissions.defaultMode` in settings | Structured approach to complex tasks |
| MCP auto-enable | `auto:N` threshold syntax | Reduces permission prompts |
| Skill hot-reload | Edit skill, verify instant reload | No restart needed |
| LSP integration | go-to-definition working | Better code navigation |
| Context reporting | `/stats` shows percentage | Monitor efficiency |
| Plans directory | `plansDirectory` setting | Custom location for plans |
| Wildcard permissions | `Bash(*-h*)` syntax | Flexible tool access |
| /teleport | Move session to claude.ai | Continue work in browser |

### Phase 3: Inventory & Validate

**Count components:**
```bash
echo "=== Component Inventory ==="
echo "Settings keys: $(jq 'keys | length' ~/.claude/settings.json)"
echo "Hooks: $(ls ~/.claude/hooks/*.js 2>/dev/null | wc -l | tr -d ' ')"
echo "Rules: $(ls ~/.claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "Skills: $(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')"
echo "Commands: $(ls ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "CLAUDE.md lines: $(wc -l < ~/.claude/CLAUDE.md | tr -d ' ')"
echo "Plugins enabled: $(jq '.enabledPlugins | to_entries | map(select(.value == true)) | length' ~/.claude/settings.json)"
```

**Validate configurations:**
```bash
echo "=== Validation ==="
# Settings JSON
jq . ~/.claude/settings.json > /dev/null 2>&1 && echo "✓ settings.json valid" || echo "✗ settings.json INVALID"

# Hook syntax
for hook in ~/.claude/hooks/*.js 2>/dev/null; do
  node --check "$hook" 2>&1 && echo "✓ $(basename $hook)" || echo "✗ $(basename $hook) SYNTAX ERROR"
done

# Rule references in CLAUDE.md
echo "--- Rule references ---"
grep -oE '[a-z-]+\.md' ~/.claude/CLAUDE.md 2>/dev/null | sort -u | while read f; do
  test -f ~/.claude/rules/$f && echo "✓ $f" || echo "✗ Missing: $f"
done
```

**Check skills ecosystem (skills.sh):**
```bash
echo "=== Skills Ecosystem (skills.sh) ==="
echo "Symlinked skills (from npx skills):"
ls -la ~/.claude/skills/ | grep "^l" | awk '{print "  " $NF}' | xargs -I{} basename {}

echo ""
echo "Available Anthropic skills:"
npx skills add anthropics/skills --list 2>&1 | grep -E "^\s+\w+-" | head -8 || echo "  (run manually to check)"

echo ""
echo "Browse skills.sh for new skills periodically"
echo "Install: npx skills add <repo> --skill <name> --global --agent claude-code"
```

**Periodically review:**
- Browse [skills.sh](https://skills.sh) for trending community skills
- Check `anthropics/skills` for official updates
- Check `vercel-labs/agent-skills` for framework-specific guidance
- Remove unused symlinked skills if context is a concern

### Phase 4: Fetch Best Practices

**4.1 Official guidance:**
```
WebFetch: https://www.anthropic.com/engineering/claude-code-best-practices
Prompt: "Extract: Three-phase workflow (explore/plan/code), CLAUDE.md recommendations, permission escalation strategy, context hygiene tips."
```

**4.2 Community patterns (HumanLayer):**
```
WebFetch: https://www.humanlayer.dev/blog/writing-a-good-claude-md
Prompt: "Extract: Optimal line count, instruction limits (~150-200), anti-patterns to avoid, progressive disclosure pattern."
```

**4.3 GitHub 2500 repos analysis:**
```
WebFetch: https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/
Prompt: "Extract: What makes good agent configs, common failures, six core coverage areas, specificity vs vagueness."
```

**4.4 Historical context:**
```
mcp__claude-historian-mcp__search_conversations:
- "Claude Code workflow friction pain points"
- "successful patterns that worked well"
- "configuration decisions settings"
```

**4.5 Community configurations (use subagents for parallel research):**

Launch 2-3 Explore agents to check community setups for new patterns:

```
Agent 1: "Search GitHub for Claude Code configuration examples. Check:
- affaan-m/everything-claude-code (hackathon winner, 9 agents, modular rules)
- ChrisWiles/claude-code-showcase (hooks, MCP patterns)
- hesreallyhim/awesome-claude-code (curated list)
- ComposioHQ/awesome-claude-skills (community skills collection)
- shanraisshan/claude-code-best-practice (best practices, usage patterns)
- fcakyon/claude-codex-settings (multi-model strategies)
Find: new permission patterns, hook implementations, commands worth adopting."

Agent 2: "Search web for Claude Code best practices published recently. Check:
- Blog posts about Claude Code setups
- Community tutorials and guides
- New MCP servers worth considering
Find: workflow optimizations, context efficiency tricks, integration patterns."
```

**Key community repos to monitor:**

| Repo | What to Check |
|------|---------------|
| `affaan-m/everything-claude-code` | 9 agents, modular rules, token optimization |
| `ChrisWiles/claude-code-showcase` | PreToolUse blocking, MCP integration |
| `hesreallyhim/awesome-claude-code` | Curated commands, tools, integrations |
| `ComposioHQ/awesome-claude-skills` | Community-curated skills collection |
| `shanraisshan/claude-code-best-practice` | Best practices, examples, usage patterns |
| `fcakyon/claude-codex-settings` | Multi-model (Opus plan + Sonnet execute) |
| `jarrodwatts/claude-code-config` | Path-scoped instructions, custom agents |
| `brianlovin/claude-config` | Sync infrastructure, statusline |

**Patterns to look for:**
- Wildcard permission configurations
- Hook patterns (auto-format, branch protection, context injection)
- Context optimization techniques (lazy loading, MCP deferral)
- Multi-model strategies (Opus for planning, Sonnet for execution)
- Plan-based model optimization (`claude-usage` skill: pro/5x/20x modes)
- Custom commands for common workflows

### Phase 5: Analyze Against Best Practices

**Best practice targets (from research):**

| Area | Target | Check |
|------|--------|-------|
| CLAUDE.md length | <300 lines | `wc -l < ~/.claude/CLAUDE.md` |
| Instructions | ~150-200 max | Count actionable directives |
| Rules | Progressive disclosure | Separate files, not monolithic |
| Boundaries | Three-tier (always/ask/never) | Check structure |
| Examples | Real code > descriptions | Has concrete examples? |
| Commands | Specific with flags | Not just tool names |
| MCPs active | <10 per project | Prevents context shrinkage |
| Total tools | <80 | Manageability |

**Power user patterns to check:**

| Pattern | Have It? | Value |
|---------|----------|-------|
| SessionStart hook | Check hooks/ | Auto-load context |
| PostToolUse validation | Check hooks/ | Quality gates |
| /commit command | Check commands/ | Smart commits |
| Dotfiles sync | Check setup | Cross-machine consistency |
| HANDOFF.md pattern | Document it | Context transfer |
| Model switching | Opus→Sonnet at 50% | Cost optimization |
| claude-usage modes | `/claude-usage pro/5x/20x` | Plan-based model optimization |

### Phase 6: Gap Analysis

**For each component:**

| Component | Gap Questions |
|-----------|---------------|
| Settings | New CHANGELOG settings missing? Deprecated present? Suboptimal values? |
| Hooks | Missing useful hooks? (8 types: SessionStart, PreToolUse, PostToolUse, Notification, Stop, SubagentStop, PreCompact, UserPromptSubmit) |
| Plugins | Updates available? `claude plugins list --available` |
| Rules | Missing topics? (error handling, boundaries, verification) Outdated refs? |
| CLAUDE.md | >300 lines? Missing sections? (Commands, Stack, Boundaries) |
| Skills | Stale patterns? Missing for common tasks? |
| Model config | Using plan-appropriate mode? (`/claude-usage` skill: pro/5x/20x) |

### Phase 7: Generate Report

```markdown
# Claude Code Upgrade Report
Generated: [DATE]

## Version Summary
- Current: [VERSION]
- Previous check: [DATE]
- New features available: [COUNT]

## Health Check
- Installation: ✓/✗
- Settings JSON: ✓/✗
- Hook syntax: ✓/✗
- Rule references: ✓/✗

## Component Status
| Component | Count | Status | Issues |
|-----------|-------|--------|--------|
| Settings | [N] keys | ✓/✗ | [details] |
| Hooks | [N] | ✓/✗ | [details] |
| Rules | [N] | ✓/✗ | [details] |
| Skills | [N] | ✓/✗ | [details] |
| CLAUDE.md | [N] lines | ✓/✗ | [details] |

## Improvements Found

### HIGH PRIORITY
[Security issues, breaking changes, deprecated settings]

### MEDIUM PRIORITY
[New features worth adopting, best practice gaps]

### LOW PRIORITY
[Optimizations, style improvements]
```

### Phase 8: Propose & Apply Changes

**For each improvement:**
```markdown
## [Component]: [Title]
**Priority:** High/Medium/Low
**Source:** [CHANGELOG/HumanLayer/GitHub analysis/etc.]

**Current:**
[existing content or "NOT PRESENT"]

**Proposed:**
[new content]

**Why:** [specific benefit]
```

**Approval options:**
1. Make this change
2. Skip this change
3. Make all HIGH priority
4. Make all remaining
5. Stop and review

### Phase 9: Validate & Track

```bash
# Verify changes
jq . ~/.claude/settings.json > /dev/null
for hook in ~/.claude/hooks/*.js; do node --check "$hook"; done

# Update tracking
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" > ~/.claude/.last-update-check
```

**Log to claude-historian:**
- Version: [from] → [to]
- Changes applied: [list]
- Skipped: [list with reasons]
- Patterns discovered: [insights]

## Recovery

| Issue | Action |
|-------|--------|
| CHANGELOG fetch fails | Try github.com/anthropics/claude-code/releases |
| claude-historian unavailable | Skip historical context, continue |
| WebSearch rate limited | Use WebFetch for known URLs only |
| Invalid settings.json | Show error, fix before proceeding |
| Hook syntax error | Show error, offer to fix |

## Quick Reference: 8 Hook Types

| Hook | When | Use For |
|------|------|---------|
| SessionStart | Session begins | Load context, run doctor |
| UserPromptSubmit | Before processing | Validate prompts, inject context |
| PreToolUse | Before tool runs | Block dangerous commands |
| PostToolUse | After tool runs | Validation, cleanup, formatting |
| Notification | Waiting for input | TTS alerts |
| Stop | Session ending | Cleanup, backups |
| SubagentStop | Subagent finishes | Announcements |
| PreCompact | Before compaction | Create backups |

## Quick Reference: Essential Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Escape | Stop Claude (not Ctrl+C) |
| Escape x 2 | View previous messages |
| Shift+Enter | New line (after /terminal-setup) |
| Ctrl+V | Paste images |

## Success Criteria

- [ ] Version verified with `claude --version`
- [ ] Health check passed with `claude doctor`
- [ ] CHANGELOG reviewed for new features
- [ ] All components inventoried and validated
- [ ] Best practices compared (HumanLayer, GitHub blog)
- [ ] Community configs researched (awesome-claude-code, power user repos)
- [ ] Historical patterns checked (claude-historian)
- [ ] Gaps identified and prioritized
- [ ] User approved/rejected each change
- [ ] Changes applied and verified
- [ ] Tracking file updated
- [ ] Improvements logged to claude-historian

### Phase 2.5: Plugin Cache & ECC Audit

**2.5.1 Check plugin cache staleness:**
```bash
echo "=== Plugin Cache Staleness ==="
if [ -d ~/.claude/plugins/cache ]; then
  for cache_dir in ~/.claude/plugins/cache/*/; do
    marketplace=$(basename "$cache_dir")
    mkt_dir="$HOME/.claude/plugins/marketplaces/$marketplace"
    if [ -d "$mkt_dir/.git" ]; then
      mkt_sha=$(git -C "$mkt_dir" rev-parse HEAD 2>/dev/null | cut -c1-12)
      echo "$marketplace: marketplace HEAD=$mkt_sha"
    fi
  done
else
  echo "No cache directory (will rebuild on next session)"
fi
```

**2.5.2 Check marketplace autoUpdate:**
```bash
echo "=== Marketplace autoUpdate ==="
jq 'to_entries[] | "\(.key): autoUpdate=\(.value.autoUpdate // false)"' ~/.claude/plugins/known_marketplaces.json
# All should show true. If any false, set to true.
```

**2.5.3 ECC plugin hook audit:**

ECC (everything-claude-code) hooks can block operations like plan file creation. Check:

```bash
echo "=== ECC Hook Audit ==="
ECC_HOOKS=$(find ~/.claude/plugins/cache/everything-claude-code -name "hooks.json" 2>/dev/null | head -1)
if [ -n "$ECC_HOOKS" ]; then
  echo "ECC hooks at: $ECC_HOOKS"
  # Check for blocking hooks (exit code 2)
  grep -c "exit(2)" "$ECC_HOOKS" 2>/dev/null && echo "Has blocking hooks"
  # Verify plan file exception exists
  grep -q "plans" "$ECC_HOOKS" 2>/dev/null && echo "✓ Plan file exception present" || echo "✗ MISSING plan file exception — cache may be stale"
else
  echo "ECC hooks not found in cache"
fi
```

**2.5.4 If stale, run `/refresh-plugins`:**

If cache is stale or ECC hooks are missing exceptions, recommend running the refresh-plugins skill.

**2.5.5 ECC as inspiration source:**

ECC (everything-claude-code, github.com/affaan-m/everything-claude-code) is disabled due to hook issues (#248) but remains one of the largest Claude Code config repos (47k+ stars). Use it as reference material each upgrade cycle.

```
WebFetch: https://github.com/affaan-m/everything-claude-code
Prompt: "List all skills/, agents/, commands/, and rules/ with brief descriptions. Note anything new since last check."
```

Compare against:
- claude-historian: what problems have we hit that ECC might solve?
- Our current skills/, agents/, rules/: gaps ECC covers that we don't?
- Community issues/PRs: what are other users adopting or requesting?

**Key ECC components worth monitoring:**

| Component | Why | Our equivalent |
|-----------|-----|----------------|
| continuous-learning-v2 | Session learning, instincts | ~/Projects/claude-homunculus-mcp (research) |
| security-reviewer agent | Pre-commit security | security-scanning plugin |
| tdd-guide agent | TDD workflow | tdd-workflows plugin |
| build-error-resolver | Build failure recovery | recover.md rule |
| iterative-retrieval skill | Search refinement | explore.md rule |

**To adopt a component:** Read the raw file from GitHub, adapt it as standalone into `~/.claude/skills/`, `~/.claude/agents/`, or `~/.claude/rules/`. Don't re-enable the plugin.

**2.5.6 Compound Engineering (EveryInc) as inspiration source:**

compound-engineering (github.com/EveryInc/compound-engineering-plugin) is enabled via every-marketplace. 29 agents, 22 commands, 19 skills. Well-structured monolith with useful TS-relevant components.

```
WebFetch: https://github.com/EveryInc/compound-engineering-plugin
Prompt: "List all agents/, commands/, skills/ with descriptions. Note anything new since last check."
```

**Key components worth monitoring:**

| Component | Why | Our equivalent |
|-----------|-----|----------------|
| kieran-typescript-reviewer | Opinionated TS review | pr-review-toolkit (general) |
| pattern-recognition-specialist | Pattern/anti-pattern detection | None |
| performance-oracle | Performance analysis | None |
| git-history-analyzer | Code evolution analysis | None |
| bug-reproduction-validator | Systematic bug repro | debugging-toolkit (general) |
| orchestrating-swarms skill | Multi-agent orchestration guide | orchestrate.md rule |
| context7 MCP | Framework docs lookup (100+ frameworks) | None |
| /deepen-plan | Parallel research to enhance plans | plan mode (manual) |

**Each upgrade cycle:** Check if compound-engineering has added new agents or skills relevant to our TS/Rust work. If the plugin's context cost becomes noticeable, disable it and cherry-pick the best components as standalone files.

**2.5.7 Community power users as inspiration:**

Search X/Twitter and GitHub for Claude Code power user configurations each upgrade cycle. Key accounts:

| Who | Why | Search for |
|-----|-----|------------|
| @garrytan | YC president, shared plan mode prompt (578K views). Focus: structured review stages, engineering preferences, per-issue option presentation | `from:garrytan claude code` |
| @anthropaboryan | Anthropic engineer, shares internal patterns | `from:anthropaboryan claude` |
| Trail of Bits | Security-focused config (trailofbits/claude-code-config) | WebFetch repo for settings.json |
| carlrannaberg/claudekit | Checkpointing, UserPromptSubmit hooks | WebFetch repo for hook patterns |

**Pattern:** Search X for `claude code setup` or `claude code CLAUDE.md` sorted by engagement. High-bookmark posts indicate community-validated patterns worth evaluating.
