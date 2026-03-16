---
name: switch-claude
author: Vvkmnn
description: Switch Claude Code between pro (maximum conservation), 5x (max ROI), and 20x (full power) usage modes. Always researches latest best practices before applying changes.
disable-model-invocation: true
---

# Claude Usage Mode Switcher

Switch between pro, 5x, and 20x plan modes. Argument is `$ARGUMENTS`.

## Step 1: Research First (ALWAYS)

Before doing anything else, run these searches in parallel:

1. `WebSearch`: "Claude Code token optimization cost reduction best practices 2026"
2. `WebSearch`: "Claude Code opusplan effort level subagent model configuration 2026"

Note any NEW strategies not covered in the reference sections below.

## Step 2: Detect Current Mode

```bash
jq '{model: .model, effortLevel: .effortLevel, thinking: .alwaysThinkingEnabled, subagentModel: (.env.CLAUDE_CODE_SUBAGENT_MODEL // "not set")}' ~/.claude/settings.json
```

- `model: "opus"` + effortLevel: "high" + thinking: true + no subagent override = **20x mode**
- `model: "opusplan"` + effortLevel: "medium" + thinking: false + subagent haiku = **5x mode**
- `model: "opusplan"` + effortLevel: "low" + thinking: false + subagent haiku = **pro mode**
- Anything else = **Custom**

Report current mode to user.

## Step 3: Apply

### If `$ARGUMENTS` is empty or unrecognized

Show current mode and:

```
Usage: /switch-claude pro   — Pro plan (opusplan + low effort + haiku subagents)
       /switch-claude 5x    — Max 5x (opusplan + medium effort + haiku subagents)
       /switch-claude 20x   — Max 20x (opus + high effort + sonnet subagents)
```

### If `$ARGUMENTS` contains "pro"

Apply maximum conservation settings for Pro plan ($20/mo, ~44k tokens per 5-hour window):

```bash
jq '.model = "opusplan" | .effortLevel = "low" | .alwaysThinkingEnabled = false' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
jq '.env = (.env // {}) | .env.CLAUDE_CODE_SUBAGENT_MODEL = "claude-haiku-4-5-20250929"' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
```

Validate: `jq . ~/.claude/settings.json > /dev/null && echo "OK"`

Show diff and print:

```
Switched to pro mode (maximum conservation):
  model:          → opusplan (Opus plans, Sonnet executes)
  effortLevel:    → low (minimal thinking, fastest responses)
  thinking:       → off (conserve tokens)
  subagent model: → haiku (1/3 cost, 90% capability)

Tips for Pro plan:
  - /clear between EVERY task (biggest single token saver)
  - /compact at 50% context (don't wait for auto-compact)
  - One task per session, batch edits into single prompts
  - Use @file references instead of reading whole files
  - Start sessions after 5-hour window resets for max quota
  - /model + arrows to bump effort for hard problems only
  - Shared limit with claude.ai — budget both tools
  - No subagents unless truly needed (each uses separate context)
  - No agent teams (too expensive for Pro)

Restart session for model change to take effect.
```

Include any new strategies found in Step 1.

### If `$ARGUMENTS` contains "5x"

Apply max ROI settings:

```bash
jq '.model = "opusplan" | .effortLevel = "medium" | .alwaysThinkingEnabled = false' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
jq '.env = (.env // {}) | .env.CLAUDE_CODE_SUBAGENT_MODEL = "claude-haiku-4-5-20250929"' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
```

Validate: `jq . ~/.claude/settings.json > /dev/null && echo "OK"`

Show diff and print:

```
Switched to 5x mode (max ROI):
  model:          → opusplan (Opus plans, Sonnet executes)
  effortLevel:    → medium (76% fewer output tokens)
  thinking:       → off (conserve tokens)
  subagent model: → haiku (1/3 cost, 90% capability)

Tips for 5x:
  - /clear between unrelated tasks
  - Subagents for all exploration
  - One task per session preferred
  - /compact with focus when context grows
  - Avoid agent teams (high token cost)
  - /model + arrows to bump effort for hard problems

Restart session for model change to take effect.
```

Include any new strategies found in Step 1.

### If `$ARGUMENTS` contains "20x"

Restore full-power settings:

```bash
jq '.model = "opus" | .effortLevel = "high" | .alwaysThinkingEnabled = true' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
jq 'if .env then .env |= del(.CLAUDE_CODE_SUBAGENT_MODEL) | if .env == {} then del(.env) else . end else . end' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
```

Validate and show:

```
Switched to 20x mode (full power):
  model:          → opus (full Opus 4.6 everywhere)
  effortLevel:    → high (maximum reasoning)
  thinking:       → on (extended thinking always enabled)
  subagent model: → sonnet (default, higher quality)

Available on 20x:
  - Full Opus 4.6 for planning AND execution
  - High effort (maximum extended thinking)
  - Sonnet subagents
  - Agent teams: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude

Restart session for model change to take effect.
```

Include any new strategies found in Step 1.

---

## Reference: Model Aliases

| Alias | Resolves To | Best For |
|-------|------------|----------|
| `opus` | Opus 4.6 | Complex reasoning, architecture, debugging |
| `sonnet` | Sonnet 4.5 | Daily coding, implementation, 90% of tasks |
| `haiku` | Haiku 4.5 | Fast exploration, summaries, read-only research |
| `opusplan` | Opus (plan) + Sonnet (execution) | Best ROI hybrid |
| `sonnet[1m]` | Sonnet with 1M context | Long sessions |

## Reference: Effort Levels (Opus 4.6)

| Level | Behavior | Token Impact |
|-------|----------|--------------|
| `low` | Minimal thinking, fast | Cheapest |
| `medium` | Matches Sonnet benchmarks | 76% fewer tokens vs high |
| `high` (default) | Full extended thinking | Maximum quality |

Adjust mid-session: `/model` then arrow keys.

## Reference: Cost

| Model | Input/MTok | Output/MTok | Relative |
|-------|-----------|-------------|----------|
| Haiku 4.5 | $1 | $5 | 1x |
| Sonnet 4.5 | $3 | $15 | 3x |
| Opus 4.6 | $5 | $25 | 5x |

Prompt caching: 90% discount (automatic).

## Reference: Agent Teams

Enable per-session only (high token cost):
```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```
Controls: `Shift+Up/Down` cycle teammates, `Shift+Tab` delegate mode, `Ctrl+T` task list.
Ghostty: use in-process mode (split panes not supported).

## Reference: Memory

```
"Remember that I prefer functional style"                → user (global)
"Remember for this project: deploy target is us-east-1"  → project
"Remember locally: mock server on :3001"                 → local
```

## Reference: Context Conservation

1. `/clear` between every task (biggest saver)
2. `/compact Focus on [topic]` at 50% context
3. One task per session (pro/5x mode)
4. Use `@file` references over full reads
5. Batch edits into single prompts
6. Subagents for exploration (separate context, but costs tokens)
7. Stay out of last 20% context
8. `/stats` to monitor
9. Time sessions around 5-hour window resets (pro)

## Reference: Key Shortcuts

| Shortcut | Action |
|----------|--------|
| `Escape` | Stop Claude mid-action |
| `Escape` x2 | Rewind menu |
| `Ctrl+G` | Open plan in editor |
| `/model` | Switch model + effort slider |
| `/stats` | Context usage |
| `/clear` | Reset context |
| `/compact` | Compress context |
