# Orchestrate Complexity

## Problem
Large tasks exceed single-agent capacity. Long contexts cause forgetting. Sequential work wastes time when parallelism is possible.

## Rule
Delegate to subagents strategically. Each agent gets fresh context - use this to your advantage.

Policy: restrict custom agents to read-only unless editing is justified (only built-in Explore/Plan are inherently read-only — custom agents inherit ALL tools unless their frontmatter restricts them). Research/review agents report back; edits happen in the main session where they can be reviewed. Editing agents (e.g. debugger) are fine when the role demands it and the frontmatter scopes the tools. Subagents run in the BACKGROUND by default (v2.1.198+) and may nest their own subagents (depth 5).

### When to Recommend Subagents

| Situation | Recommend | Why |
|-----------|-----------|-----|
| 3+ independent areas to research | Yes | Parallel exploration, fresh contexts |
| Context >50% used | Yes | Avoid context rot |
| Domain expertise needed | Yes | security-reviewer, architect, debugger, paper-researcher |
| Context-heavy ops (testing, docs) | Yes | Isolate token-hungry work |
| Novel problem or persistent error | Yes | Research protocol — local/docs/online |
| Simple targeted lookup | No | Direct tools faster |
| Sequential dependencies | No | Agents can't see each other |

### Model + Effort Routing (Fable/Opus 4.8 era)

| Role | model | effort | Notes |
|------|-------|--------|-------|
| Main session | fable/opus/sonnet per switch-claude | high (xhigh for hardest) | 20x is the PLAN; model chosen within it |
| architect | opus | max | Deepest reasoning; advisory read-only |
| code-reviewer / security-reviewer | sonnet | medium / high | Fast-pass gates; CE/trailofbits fleets for depth |
| debugger | inherit | high | Fresh-context verifier beats self-critique |
| paper-researcher | sonnet | high | background:true, writes results to file |
| Deterministic file search | haiku | low | Explore now INHERITS main model (capped at Opus) — cheap scans need an explicit haiku override |

- Agents arrive pre-equipped: their frontmatter carries `skills`/`mcpServers`/`effort` — don't re-instruct these in dispatch prompts
- Session modes: `switch-claude` skill (pro/5x/20x + per-project overrides)
- Global subagent cost-cap: `CLAUDE_CODE_SUBAGENT_MODEL` env var

### Context Window Strategy

| Context Usage | Best For | Avoid |
|---------------|----------|-------|
| <50% | Multi-file refactors, cross-file debugging | — |
| 50-80% | Single-file edits, utility creation, simple fixes | Starting complex new work |
| >80% | Finishing current task only | Any new exploration |

### Parallelism Patterns

**Research phase (plan mode):**
```
Task("Find auth patterns", prompt, "Explore")
Task("Find test patterns", prompt, "Explore")
Task("Find API patterns", prompt, "Explore")
# All in single message = parallel execution
```

**Implementation phase:**
- Only parallelize truly independent work
- Sibling agents can't see each other's changes (nesting works to depth 5, but siblings stay isolated)
- Reconvene and verify after parallel execution

### Async Delegation (Fable-era default)

Subagents run in the background by default — use it: delegate independent subtasks and keep working while they run; intervene if a subagent goes off track or is missing context. Don't block on a single agent's return when other work exists. Long-lived agents that keep context across subtasks save time and cost via cache reads. Background agents should write substantial results to a file so nothing is lost on return. For high-stakes work, verify with a fresh-context subagent against the spec — separate verifiers outperform self-critique.

**Teams vs subagents vs background:** background subagents (default) for independent work; agent teams ONLY for adversarial/competing-hypothesis debugging where agents must challenge each other (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, fragile: no /resume for teammates); never teams for work subagents can do.

### Research Protocol

**When facing something novel or an error persists, research before planning or retrying.**

**Triggers:**
- Unfamiliar library, API, framework, or config
- Error persists after one informed fix attempt
- User asks for "best practice" or "elegant approach"
- Design decision with unclear trade-offs
- About to plan a feature using patterns not yet in the codebase

**Skip when:** Routine patterns already in codebase, obvious typos/syntax, already researched this session, user says "just do it."

**3 parallel Explore subagents** (single message, all at once):

| Agent | Focus | Sources |
|-------|-------|---------|
| Local | Past solutions + codebase patterns | historian, Grep, existing implementations |
| Docs | Library docs + version/migration notes | Context7, changelogs, READMEs |
| Online | Community solutions + best practices | StackOverflow, web search, HackerNews |

**Model selection by usage plan:**
- **Generous** (`opus`): sonnet for all 3
- **Optimized** (`opusplan`): sonnet for all 3 (haiku misses issues — only use haiku for deterministic file search, never analysis)

**Quick research** (one direct tool call, no subagents) when the question is narrow and one source suffices. Escalate to 3-subagent protocol when quick research yields nothing or user wants thoroughness.

**Priority:** Favour online best-in-class solutions over local workarounds. The goal is usually the most elegant, well-established approach — not the quickest hack.

**After results:**
1. Synthesize — don't dump raw results
2. Present 2-3 approaches with effort/risk/source
3. Recommend the best-in-class solution with reasoning
4. Proceed if clearly superior, ask if trade-offs exist

### Prompting Agents Effectively

**Include in every agent prompt:**
1. Specific scope (directories, file patterns)
2. What you already know (avoid redundant exploration)
3. **Return contract** — output format + line cap (e.g. "≤15 lines, file:line refs, never paste file contents"). Read reports, not transcripts
4. Any constraints or non-goals

**Example:**
```
Search src/auth/ for authentication patterns.
I already know: JWT is used, tokens stored in localStorage.
Find: middleware patterns, error handling, session management.
Return: file:line references for each pattern found.
Don't explore: tests, mocks, or deprecated code.
```

### Agent Discovery

**Default:** `Explore` for codebase questions, `Plan` for architecture design.

**Decision Triggers:**

| When I notice... | Reach for... |
|------------------|--------------|
| Bug with unclear cause | `debugger` agent (ours, fresh-context) or `debugging-toolkit:debugger` |
| Test coverage gaps, TDD needed | `tdd-workflows:tdd-orchestrator` |
| Novel library/tool/approach | `research-topics` skill (technical mode) |
| Academic papers/literature/citations | `research-topics` skill (academic mode) → dispatches `paper-researcher` agent |
| Pre-commit quality pass | `code-reviewer` agent (fast gate); CE reviewer fleet for depth |
| Pre-push / security-sensitive changes | `security-reviewer` agent (OWASP gate); trailofbits skills for adversarial depth |
| PR needs review | `code-review` skill or `compound-engineering:ce-code-review` |
| Feature architecture needed | `architect` agent or `compound-engineering:ce-plan` |
| Code quality after implementation | `compound-engineering:ce-simplify-code` skill |

**Naming patterns:** `*-architect` for architecture, `*-pro` for language expertise (python-pro, typescript-pro, rust-pro, golang-pro, bash-pro).

### Language Skills (invoke via Skill tool)

Language plugins provide skills — not just agents. **Check matching skills before writing language-specific code**, especially for patterns, testing, and error handling.

| When writing... | Invoke skill | Key skills |
|-----------------|-------------|------------|
| Python code | `python-development:*` | `python-code-style`, `python-testing-patterns`, `python-error-handling`, `python-anti-patterns`, `uv-package-manager` |
| TypeScript/JS code | `javascript-typescript:*` | `typescript-advanced-types`, `modern-javascript-patterns`, `javascript-testing-patterns`, `nodejs-backend-patterns` |
| Shell scripts | `shell-scripting:*` | `bash-defensive-patterns`, `bats-testing-patterns`, `shellcheck-configuration` |

**When to invoke language skills vs write directly:**
- Complex patterns (async, generics, decorators) — invoke skill first
- Testing strategy for new code — invoke `*-testing-patterns`
- Performance-sensitive code — invoke `python-performance-optimization` or equivalent
- Simple edits, bug fixes, known patterns — write directly

**Disabled but available per-project:** See `~/.claude/docs/CONFIG.md` (Plugins section) for full reference. Enable in project `.claude/settings.json`.

### Agent Teams (Experimental)

Multiple Claude Code instances coordinating via shared task list + mailbox. Enable per-session: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude`. Use when agents must discuss/challenge each other (parallel code review, competing hypotheses). High token cost — prefer subagents for focused tasks.

### Red Flags

- Launching agents for simple lookups (use Grep)
- Sequential agents that depend on each other
- Routing cheap scans through an inherited expensive model (Explore inherits main model now — use a haiku override for deterministic search)
- Vague prompts that cause redundant exploration
- More than 3 parallel agents (diminishing returns)
- Using agent teams for tasks subagents can handle (token waste)
- Subagents making edits without clear justification (default to read-only)

## Complements
- `explore.md` - When to ask before launching
- `minimize.md` - Keep agent prompts focused
- `verify.md` - Verify agent outputs
- `/switch-claude` skill - Toggle generous/optimized modes
