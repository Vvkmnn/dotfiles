# Explore Before Acting

## Problem
Acting without understanding leads to solutions that don't fit and changes that break things.

## Rule
Before writing plans OR modifying code, explore and investigate first.

### Exploration Phase (Before Planning)

**Use Your Tools:**
- **code-mode** (`mcp__code-mode__search_tools` or `list_tools`) - Check available integrations FIRST (Notion, GitHub, Google Drive; see `~/.utcp_config.json`)
- **claude-mem** - Past decisions on similar problems
- **Explore agent** (`Task` with `subagent_type=Explore`) - Open-ended codebase questions
- **Glob/Grep** - File pattern and content search

**Minimum Exploration by Task:**
| Task | Before Planning |
|------|-----------------|
| New feature | Find 2+ similar features, read implementation |
| Bug fix | Read failing code path end-to-end |
| Refactor | Map all callers and dependents |
| API change | Find all consumers |

### Debugging Strategy

**Gather context before investigating:**
- **What changed?** Recent edits, commits, deploys, dependency updates
- **When?** Started after what action? Gradual or sudden?
- **How often?** Always, intermittent, specific trigger
- **Scope?** Everywhere, specific environment, one machine

**Investigation priority (most to least likely):**

1. **Recent changes** (if "wasn't working before")
   - Files modified in related area (check timestamps, git log)
   - Recent commits, merges, or deployments
   - System settings are unlikely if they've been stable

2. **Direct dependencies** (if specific feature broken)
   - Code/config directly related to symptom
   - Services or files that feature depends on
   - Error logs, stack traces

3. **System state** (only if above ruled out)
   - Environment variables, permissions
   - Resource constraints
   - Long-standing system configs

**When to stop investigating:**
- Checking 3+ unrelated systems without evidence linking them
- User says "I don't think X is the issue" → stop checking X
- Same approach attempted 3+ times → escalate, don't repeat

### Subagent Usage

**ALWAYS ask before launching subagents.** Subagents (Task tool with any subagent_type) consume significant usage.

Before launching any subagent:
1. State what you want to explore/plan
2. Ask: "Should I launch a [type] agent for this, or should I explore directly?"
3. Wait for approval

**Default to direct exploration** using Glob, Grep, Read tools. Only use subagents when:
- User explicitly requests it
- Task genuinely requires autonomous multi-step exploration
- Direct tools have proven insufficient

### Investigation Phase (Before Modifying)

**Before touching ANY file:**
1. **Read the whole file** (or relevant section), not just target line
2. **Check recent history**: `git log -3 --oneline -- path/to/file`
3. **Look for comments** explaining WHY, not just what
4. **Find related tests** that document expected behavior
5. **Search claude-mem** for past work on this file

**Questions to Answer:**
- Why was this written this way?
- What would break if I change it?
- Are there edge cases I'm not seeing?
- Is there a test covering this?

### Red Flags - STOP and Dig Deeper

**Code Investigation:**
- Code that looks "wrong" but survived many commits
- Magic numbers without explanation
- Try/catch that swallows errors silently
- Proposing new files without checking if similar ones exist

**Data Retrieval:**
- WebSearch for info available in MCP servers (Notion, GitHub, etc.)
- WebFetch when structured API access exists (check code-mode tools first)
- Re-reading files when claude-mem already has the answer
- Manual extraction when MCP provides structured access
- Searching for MCP config in `~/.claude.json` - code-mode servers are in `~/.utcp_config.json`

## Complements
- `superpowers:brainstorming` skill - Use AFTER exploration to refine ideas
- `superpowers:systematic-debugging` skill - For bug investigation
- `superpowers:root-cause-tracing` skill - For tracing issues backward
- Plan mode hook - Exploration should happen IN plan mode
