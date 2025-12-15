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

## Complements
- `superpowers:brainstorming` skill - Use AFTER exploration to refine ideas
- `superpowers:systematic-debugging` skill - For bug investigation
- `superpowers:root-cause-tracing` skill - For tracing issues backward
- Plan mode hook - Exploration should happen IN plan mode
