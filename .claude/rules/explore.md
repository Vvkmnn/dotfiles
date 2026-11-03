# Explore Before Acting

## Problem
Acting without understanding leads to solutions that don't fit and changes that break things.

## Rule
Before writing plans OR modifying code, explore and investigate first.

### Exploration Phase (Before Planning)

**Golden paths (one route per need; a failed route is a stop that names the fix, never a detour):**
| Need | Route |
|------|-------|
| This codebase | Glob/Grep/Read; `sg --lang <l> -p 'pattern($ARG)'` when text-grep false-positives hurt; `dora symbol/refs/deps` if `.dora/` exists; Explore agent for open-ended questions |
| Past sessions and decisions | claude-historian |
| A fact, a page, docs | native WebSearch (standard; extended for niche or fresh) and WebFetch; Context7 for library docs; Firecrawl only for pages that defeat WebFetch or for bulk extraction (credits) |
| X, Reddit, YouTube, Bilibili, V2EX, GitHub | `agent-reach <channel> <action>` (read-only, Eve's logins, 2 calls per platform and 4 total per 10 s); Reddit *search* via the reddit MCP until upstream clears its 403; YouTube *comments* via the youtube MCP |
| Hacker News, Stack Overflow, Zhihu, Linux.do, LinkedIn jobs, arXiv, PubMed, Semantic Scholar, OpenAlex, 1,280 more | `opencli <site> <command>` (read verbs run without a prompt; write verbs ask) |
| Economic series | fred MCP |
| A site that needs clicking or a login | Claude in Chrome in the `Claude` profile; `agent-browser` headless from Bash as the fallback |

**Symptom → Skill Lookup (invoke BEFORE investigating):**
| Symptom | Invoke First |
|---------|-------------|
| Plugin errors, stale hooks, cache issues | `improve-claude refresh` |
| Claude Code binary updated | `improve-claude health audit` |
| Confused about ~/.claude structure | `improve-claude cleanup` |
| Disk space issues | `save-space` |
| Dotfiles changed | `update-dotfiles` |
| Neovim config issues | `configure-neovim` |

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

**Ask before launching subagents** - they consume significant usage. However, **proactively recommend** when subagents would add clear value.

**Default to direct exploration** using Glob, Grep, Read tools. Only use subagents when:
- User explicitly requests it
- Task genuinely requires autonomous multi-step exploration
- Direct tools have proven insufficient

See `orchestrate.md` for when to recommend, model selection, and prompting guidelines.

### Investigation Phase (Before Modifying)

**Before touching ANY file:**
1. **Read the whole file** (or relevant section), not just target line
2. **Check recent history**: `git log -3 --oneline -- path/to/file`
3. **Look for comments** explaining WHY, not just what
4. **Find related tests** that document expected behavior
5. **Search claude-historian** for past work on this file

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
- A browser or WebFetch for a site Agent-Reach or OpenCLI already reads (Reddit blocks WebFetch; `agent-reach reddit read <url>`)
- A new MCP for a site OpenCLI has an adapter for
- Re-reading files when claude-historian already has the answer
- MCP config lives in `~/.claude/mcp/config.json` (proxy) and `~/.claude.json` `mcpServers`; see docs/CONFIG.md

## Complements
- `superpowers:brainstorming` skill - Use AFTER exploration to refine ideas
- `superpowers:systematic-debugging` skill - For bug investigation
- `superpowers:root-cause-tracing` skill - For tracing issues backward
- Plan mode hook - Exploration should happen IN plan mode
