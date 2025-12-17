# Claude Code Plugins - Future Additions

## Quality of Life

1. Have Neovim autoreload in buffer automatically whenever claude edits a file. If I have changes try to save them quickly and reload the file silently so neither of us is disrutped (if possible)

## Installed Plugins

### learning-output-style

- Interactive learning mode requesting user code contributions
- Hook: SessionStart - Encourages meaningful code contributions

### explanatory-output-style

- Educational insights about implementation choices
- Hook: SessionStart - Injects educational context

---

## Plugins to Add Later

### Official Anthropic Plugins (claude-code-plugins marketplace)

#### feature-dev

**What:** 7-phase feature development workflow with architect/reviewer agents
**Commands:** `/feature-dev`
**Agents:** code-explorer, code-architect, code-reviewer
**When to use:** Large features requiring architecture planning
**Install:** `/plugin install feature-dev@claude-code-plugins`

#### security-guidance

**What:** Hook monitoring 9 security patterns (XSS, SQL injection, etc.)
**Hook:** PreToolUse - Monitors for dangerous patterns
**When to use:** Production code, security-critical projects
**Install:** `/plugin install security-guidance@claude-code-plugins`

#### code-review

**What:** 4 parallel agents review PRs with confidence scoring (≥80 threshold)
**Commands:** `/code-review`
**When to use:** All non-trivial pull requests
**Install:** `/plugin install code-review@claude-code-plugins`

#### commit-commands

**What:** Git workflow automation
**Commands:** `/commit`, `/commit-push-pr`, `/clean_gone`
**When to use:** Daily git operations
**Install:** `/plugin install commit-commands@claude-code-plugins`

#### pr-review-toolkit

**What:** 6 specialized PR review agents (comments, tests, errors, types, quality)
**Commands:** `/pr-review-toolkit:review-pr`
**When to use:** More detailed PR reviews than code-review
**Install:** `/plugin install pr-review-toolkit@claude-code-plugins`

#### agent-sdk-dev

**What:** Agent SDK project scaffolding with TS/Python verifiers
**Commands:** `/new-sdk-app`
**When to use:** Building custom Claude agents
**Install:** `/plugin install agent-sdk-dev@claude-code-plugins`

#### frontend-design

**What:** Production-grade UI avoiding generic AI aesthetics
**Auto-invoked:** For frontend work
**When to use:** Building user interfaces
**Install:** `/plugin install frontend-design@claude-code-plugins`

#### plugin-dev

**What:** Toolkit for building your own plugins (7 expert skills)
**Commands:** `/plugin-dev:create-plugin`
**When to use:** Creating custom Claude Code plugins
**Install:** `/plugin install plugin-dev@claude-code-plugins`

#### hookify

**What:** Create custom hooks to prevent unwanted behaviors
**Commands:** `/hookify`, `/hookify:list`, `/hookify:configure`, `/hookify:help`
**When to use:** Customizing Claude Code behavior
**Install:** `/plugin install hookify@claude-code-plugins`

---

### Third-Party Plugins

#### wshobson/agents

**What:** Multi-agent orchestration with 63 plugins, 85 agents, 47 skills
**Marketplace:** `wshobson/agents`
**Note:** Heavy framework - only install specific plugins you need, not the whole suite
**When to use:** Complex multi-domain projects across many languages
**Install:** `/plugin marketplace add wshobson/agents` then browse plugins

#### episodic-memory (superpowers-marketplace)

**What:** Semantic search for Claude Code conversations - remember past discussions, decisions, and patterns
**Plugin:** Already installed, just disabled
**Setup required:**

1. Enable in settings: `"episodic-memory@superpowers-marketplace": true`
2. Run `npm install` in plugin directory to get native deps (better-sqlite3, sqlite-vec)
3. Run initial sync: `episodic-memory sync`
4. Optionally add SessionEnd hook for immediate indexing (plugin has SessionStart hook)
   **When to use:** Long-running projects, recurring patterns, architectural decisions
   **MCP Tools:** `episodic_memory_search`, `episodic_memory_show`
   **Agent:** `episodic-memory:search-conversations` (uses Haiku model)
   **Skill:** `episodic-memory:remembering-conversations`

#### beads (4k stars)

**What:** Memory upgrade for coding agents - persistent context
**When to use:** Long-running projects, session continuity
**Source:** https://github.com/quemsah/beads

#### repomix (20k stars)

**What:** Packs entire repo into single AI-friendly file
**When to use:** Sharing codebase context, documentation
**Source:** https://github.com/quemsah/repomix

#### mgrep (2k stars)

**What:** Semantic search across code, images, PDFs
**When to use:** Complex codebases, multi-format search
**Source:** https://github.com/quemsah/mgrep

---

### From awesome-claude-code (CLI Tools)

Source: https://github.com/hesreallyhim/awesome-claude-code

These are standalone CLI tools (not plugins) that enhance Claude Code workflows.

#### TDD Guard

**What:** Mechanical TDD enforcement via hooks - blocks writes without failing tests
**Type:** CLI + Hooks (requires per-project test reporter setup)
**Install:**

```bash
npm install -g tdd-guard
# or: brew install tdd-guard
```

**Per-project setup:**

```bash
cd ~/Projects/your-project
tdd-guard init  # Configure test framework (vitest, jest, pytest, etc.)
```

**Hooks added:** PreToolUse (validates Write/Edit), SessionStart, UserPromptSubmit
**When to use:** Projects requiring strict TDD discipline beyond process guidance
**Note:** Already have tdd-workflows plugin (commands) + superpowers TDD skill (methodology). TDD Guard adds mechanical blocking.
**Source:** https://github.com/nizos/tdd-guard

#### ccusage

**What:** CLI for analyzing Claude Code usage patterns and costs
**Type:** Standalone CLI
**Install:**

```bash
npm install -g ccusage
```

**Usage:**

```bash
ccusage blocks today           # Today's usage
ccusage cost --model opus      # Cost breakdown by model
ccusage history --last 7d      # Last 7 days
```

**When to use:** Track Opus usage, monitor costs, analyze patterns
**Source:** https://github.com/ryoppippi/ccusage

#### cchistory

**What:** Search past Claude Code sessions like shell history (ctrl-r style)
**Type:** Standalone CLI (Go)
**Install:**

```bash
go install github.com/eckardt/cchistory@latest
```

**Usage:**

```bash
cchistory search "authentication bug"  # Search sessions
cchistory list --last 10               # Recent sessions
```

**When to use:** Find past conversations, recall how you solved something before
**Note:** Complements claude-mem (which stores observations, not full transcripts)
**Source:** https://github.com/eckardt/cchistory

#### Claude Squad

**What:** Multi-agent orchestration - run multiple Claude agents in parallel tmux sessions
**Type:** Standalone CLI (Go)
**Install:**

```bash
go install github.com/smtg-ai/claude-squad/cmd/cs@latest
```

**Usage:**

```bash
cs spawn "implement auth" "write tests" "update docs"
```

**When to use:** Parallel workstreams, complex features with independent subtasks
**Source:** https://github.com/smtg-ai/claude-squad

#### Context Engineering Kit

**What:** Hand-crafted context engineering techniques with minimal token footprint
**Type:** Skill/Documentation (add to CLAUDE.md or as skill)
**Install:**

```bash
curl -O https://raw.githubusercontent.com/NeoLabHQ/context-engineering-kit/main/CONTEXT_ENGINEERING.md
# Move to ~/.claude/skills/ or include in project CLAUDE.md
```

**When to use:** Complex prompts, optimizing context for large codebases
**Source:** https://github.com/NeoLabHQ/context-engineering-kit

#### cc-tools

**What:** High-performance Go implementation of hooks and utilities
**Type:** CLI toolkit (Go)
**Install:**

```bash
go install github.com/Veraticus/cc-tools@latest
```

**When to use:** Replace JS/Python hooks with faster Go implementations
**Source:** https://github.com/Veraticus/cc-tools

---

## TypeScript/Python Stack Recommendations

### High Priority

1. **commit-commands** - Daily git workflow
2. **security-guidance** - Always-on security monitoring
3. **code-review** - PR automation

### Medium Priority

4. **feature-dev** - Large feature planning
5. **frontend-design** - If doing UI work

### Low Priority / As Needed

6. **agent-sdk-dev** - Custom agent development
7. **plugin-dev** - Custom plugin development
8. **wshobson/agents** - Only if multi-language orchestration needed

---

## Infrastructure Patterns to Implement

### From diet103/claude-code-infrastructure-showcase

Reference: https://github.com/diet103/claude-code-infrastructure-showcase

This repo demonstrates a production-tested Claude Code infrastructure built over 6 months managing 300k LOC. Key insight: "Skills don't auto-activate - the hook system solves this."

---

### 1. Skill Auto-Activation System (HIGH PRIORITY)

**Problem:** Skills exist but Claude doesn't know when to use them
**Solution:** UserPromptSubmit hook + skill-rules.json

**Components:**

- `~/.claude/skill-rules.json` - Defines activation triggers
- `~/.claude/hooks/skill-activation.ts` - Evaluates prompts against rules

**skill-rules.json structure:**

```json
{
  "skills": [
    {
      "name": "backend-dev-guidelines",
      "description": "Backend development patterns",
      "enforcement": "suggest",
      "priority": "high",
      "keywords": ["backend", "api", "route", "controller"],
      "intentPatterns": ["create.*endpoint", "implement.*api"],
      "pathPatterns": ["backend/**/*.ts", "**/routes/**/*.ts"]
    }
  ]
}
```

**Hook behavior:**

1. Reads user prompt
2. Matches against keywords (substring) and intentPatterns (regex)
3. Checks active files against pathPatterns
4. Groups matches by priority (critical > high > medium > low)
5. Outputs formatted suggestion: "Use Skill tool BEFORE responding"

**Why it matters:** Without this, skills sit unused. With it, automatic quality awareness.

---

### 2. Dev-Docs Three-File Pattern (MEDIUM PRIORITY)

**Problem:** Claude loses context during long/multi-session work
**Solution:** Structured documentation that survives context resets

**For each complex task, create:**

**1. `[task]-plan.md`** - Strategic roadmap

```markdown
# Project Plan: [Task Name]

## Executive Summary

[2-3 sentences]

## Current State

- Existing architecture
- Known limitations

## Proposed Future State

- Vision after implementation
- Success criteria

## Implementation Phases

### Phase 1: Foundation

- Task 1.1: [Description]
  - Acceptance criteria: [specific]
  - Effort: S/M/L/XL
  - Dependencies: [list]

## Risk Assessment

- Critical risks and mitigation

## Timeline

- Estimated duration per phase
```

**2. `[task]-context.md`** - Quick-resume reference (UPDATE FREQUENTLY)

```markdown
# Project Context: [Task Name]

## SESSION PROGRESS

**Last Updated: YYYY-MM-DD HH:MM**

### Completed

- [x] Task with file locations

### Currently Working On

- [ ] Current focus
- [ ] Blockers

## Key Files & Their Purposes

- `/path/to/file.ts` - What it does

## Important Decisions Made

- Decision: Why? Tradeoffs?

## How to Resume

1. [Exact file locations]
2. [Next steps]
3. [Test commands]
```

**3. `[task]-tasks.md`** - Checkbox tracker

```markdown
# Tasks: [Task Name]

## Phase 1: Foundation

- [ ] Task 1.1 - Description
- [ ] Task 1.2 - Status: In Progress
```

**Slash commands to create:**

- `/dev-docs [task-name]` - Initialize all three files
- `/dev-docs-update` - Refresh before context reset

**Key insight:** "Focus on information difficult to reconstruct from code"

---

### 3. Specialized Agents (MEDIUM PRIORITY)

**Problem:** Generic agent requests return generic results
**Solution:** Task-specific agents with clear roles and return expectations

**Agent types to create:**

**Quality Control:**

- `code-architecture-reviewer.md` - 8-step review framework
- `build-error-resolver.md` - Systematic TypeScript error fixing
- `refactor-planner.md` - Comprehensive refactoring plans

**Testing & Debugging:**

- `auth-route-tester.md` - Tests backend routes with auth
- `frontend-error-fixer.md` - Diagnoses UI errors

**Planning:**

- `strategic-plan-architect.md` - Detailed implementation plans
- `plan-reviewer.md` - Reviews plans before implementation

**Agent file structure:**

```markdown
# Agent: [Name]

## Purpose

[One sentence]

## Workflow

1. [Step 1]
2. [Step 2]
   ...

## Tools Allowed

- Glob, Grep, Read (exploration)
- Edit, Write (if fixes needed)
- Task (for sub-agents)

## Output Format

Return structured report:

- Findings
- Recommendations
- Files modified (if any)

## Constraints

- Do NOT [specific anti-patterns]
- ALWAYS [required behaviors]
```

**Invocation:** `Task tool with subagent_type`

**Key insight:** "Give agents very specific roles and clear instructions on what to return. I learned this after creating agents that would go off and do who-knows-what and come back with 'I fixed it!' without telling me what they fixed."

---

### 4. Stop Hooks - TSC Check (LOW PRIORITY)

**Problem:** Ending session with TypeScript errors
**Solution:** Validate compilation on Stop event

**Components:**

- `tsc-check.sh` - Runs TypeScript compiler on affected repos
- `trigger-build-resolver.sh` - Auto-launches error resolver if fails

**Caution:** Can block sessions. Test carefully in isolation before enabling.

**Implementation:**

1. PostToolUse hook tracks edited files
2. Stop hook identifies affected repos from tracked files
3. Runs TSC with repo-specific config
4. If errors: launches build-error-resolver agent
5. Agent fixes errors, re-runs TSC

**Dependencies:** Requires PostToolUse file tracking (below)

---

### 5. PostToolUse File Tracking (LOW PRIORITY)

**Problem:** Don't know which files changed during session
**Solution:** Track Edit/Write operations

**Hook behavior:**

1. Monitors Edit, MultiEdit, Write tool calls
2. Extracts file paths
3. Maps files to repositories (frontend, backend, etc.)
4. Saves to cache:
   - `edited-files.log` (timestamps, paths, repos)
   - `affected-repos.txt` (unique repo list)
   - `commands.txt` (deduplicated build commands)

**Why it matters:**

- Enables repo-aware TSC checks
- Provides context for dev-docs
- Helps identify what was changed in session

---

## Notes

- Plugins are progressive - they only load fully when invoked
- Don't install everything - be selective based on workflow
- Official Anthropic plugins are better maintained than third-party
- Check plugin READMEs before installing for compatibility

---

## UTCP Code-Mode Disabled Templates

The following MCP templates are disabled but saved for future reference.
These were removed from `~/.utcp_config.json` because code-mode doesn't accept custom keys.

### brightdata
- **Status:** disabled
- **Requires:** API_TOKEN from brightdata.com (free tier: 5000 req/month, includes Twitter/X scraping)
- **Package:** `@brightdata/mcp`

### apify
- **Status:** disabled
- **Requires:** APIFY_TOKEN from apify.com (free tier available, all-in-one: Twitter, Reddit, YouTube, Instagram, TikTok, Amazon)
- **Package:** `@apify/actors-mcp-server`

### whatsapp
- **Status:** disabled
- **Requires:** QR code setup - clone github.com/lharries/whatsapp-mcp, run Go bridge, scan QR once
- **Package:** `whatsapp-mcp-ts`

### ghidra
- **Status:** disabled
- **Requires:** Ghidra installation + GhidraMCP plugin from github.com/LaurieWired/GhidraMCP
- **Package:** `ghidra_mcp` (Python)

### trendradar
- **Status:** disabled
- **Requires:** Docker: docker-compose up -d (monitors 35 platforms: Douyin, Zhihu, Bilibili, etc.)
- **Transport:** HTTP on http://localhost:3333/mcp

### convex
- **Status:** disabled
- **Requires:** Convex project deployment - run npx convex mcp start in project directory
- **Package:** `convex mcp start`

### cua
- **Status:** disabled
- **Requires:** Docker/VM + Python 3.12+ + ANTHROPIC_API_KEY (full desktop automation)
- **Package:** `cua_mcp_server` (Python)

### skillseeker
- **Status:** disabled
- **Requires:** pip install skill-seekers && ./setup_mcp.sh (converts docs/repos/PDFs to Claude skills)
- **Package:** `skill_seekers.mcp` (Python)

### xhs
- **Status:** disabled
- **Requires:** pip install xhs-downloader (Xiaohongshu/RedNote - Chinese social media)
- **Package:** `XHS-Downloader --server MCP` (Python)

### linear
- **Status:** disabled
- **Requires:** LINEAR_API_KEY from linear.app/settings/api - issue tracking integration
- **Package:** `@linear/mcp-server`

### jira
- **Status:** disabled
- **Requires:** JIRA_HOST (e.g., your-domain.atlassian.net), JIRA_EMAIL, JIRA_API_TOKEN from id.atlassian.com/manage-profile/security/api-tokens
- **Package:** `jira-mcp`
