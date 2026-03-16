# Orchestrate Complexity

## Problem
Large tasks exceed single-agent capacity. Long contexts cause forgetting. Sequential work wastes time when parallelism is possible.

## Rule
Delegate to subagents strategically. Each agent gets fresh context - use this to your advantage.

### When to Recommend Subagents

| Situation | Recommend | Why |
|-----------|-----------|-----|
| 3+ independent areas to research | Yes | Parallel exploration, fresh contexts |
| Context >50% used | Yes | Avoid context rot |
| Domain expertise needed | Yes | security-auditor, backend-architect, etc. |
| Context-heavy ops (testing, docs) | Yes | Isolate token-hungry work |
| Novel problem or persistent error | Yes | Research protocol — local/docs/online |
| Simple targeted lookup | No | Direct tools faster |
| Sequential dependencies | No | Agents can't see each other |

### Model Selection

| Task Type | Model | Why |
|-----------|-------|-----|
| File search, pattern matching | haiku | Deterministic, can't fail |
| Code analysis, exploration | haiku or sonnet | Haiku is 90% of Sonnet at 1/3 cost |
| Architecture, complex reasoning | opus | Opus 4.6, worth the cost |

**Session model:** Check `/switch-claude` skill for current mode (generous vs optimized).
- `opusplan` = Opus for plan mode, Sonnet for execution (best ROI)
- `opus` = full Opus everywhere (generous mode)
- Effort levels: `/model` + arrow keys (low/medium/high)
- Subagent routing: `CLAUDE_CODE_SUBAGENT_MODEL` env var

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
- Agents can't see each other's changes
- Reconvene and verify after parallel execution

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
- **Optimized** (`opusplan`): haiku for Local + Docs, sonnet for Online

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
3. What format you want the answer in
4. Any constraints or non-goals

**Example:**
```
Search src/auth/ for authentication patterns.
I already know: JWT is used, tokens stored in localStorage.
Find: middleware patterns, error handling, session management.
Return: file:line references for each pattern found.
Don't explore: tests, mocks, or deprecated code.
```

### Context Isolation Benefits

- **Fresh perspective** - no accumulated confusion
- **Parallel execution** - multiple agents at once
- **Token efficiency** - main context stays clean
- **Failure isolation** - one agent failing doesn't corrupt others

### Agent Discovery

**Default:** `Explore` for codebase questions, `Plan` for architecture design.

**Decision Triggers:**

| When I notice... | Reach for... |
|------------------|--------------|
| Security concern (auth, validation, secrets) | `security-scanning:security-auditor` |
| Bug with unclear cause | `debugging-toolkit:debugger` |
| Test coverage gaps, TDD needed | `tdd-workflows:tdd-orchestrator` |
| API/service design decisions | `backend-development:backend-architect` |
| Database schema work | `database-design:database-architect` |
| CI/CD pipeline work | `cicd-automation:deployment-engineer` |
| Legacy code modernization | `code-refactoring:legacy-modernizer` |
| PR needs review | `pr-review-toolkit:code-reviewer` |
| Novel library/API or persistent error | Research protocol (3 Explore agents) |

**Naming patterns:** `*-architect` for architecture, `*-pro` for language expertise (python-pro, typescript-pro, rust-pro, golang-pro, bash-pro).

**PR Review Toolkit** (use together for comprehensive review):
- `code-reviewer` - Quality, conventions, bugs
- `silent-failure-hunter` - Error handling gaps
- `pr-test-analyzer` - Test coverage
- `type-design-analyzer` - Type invariants

### Agent Teams (Experimental)

Multiple Claude Code instances coordinating via shared task list + mailbox.
Enable per-session, NOT globally (high token cost):

```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

| Need | Use |
|------|-----|
| Focused task, result only | Subagent |
| Agents must discuss/challenge | Agent Team |
| Sequential dependencies | Neither (single session) |

**Best for:** parallel code review, competing debug hypotheses, cross-layer features.
**Controls:** `Shift+Up/Down` cycle teammates, `Shift+Tab` delegate mode, `Ctrl+T` task list.
**Limitation:** Split panes not in Ghostty — use in-process mode or regular tmux.

### Red Flags

- Launching agents for simple lookups (use Grep)
- Sequential agents that depend on each other
- Forgetting to specify model (defaults to sonnet)
- Vague prompts that cause redundant exploration
- More than 3 parallel agents (diminishing returns)
- Using agent teams for tasks subagents can handle (token waste)

## Complements
- `explore.md` - When to ask before launching
- `minimize.md` - Keep agent prompts focused
- `verify.md` - Verify agent outputs
- `/switch-claude` skill - Toggle generous/optimized modes
