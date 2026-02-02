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
| Simple targeted lookup | No | Direct tools faster |
| Sequential dependencies | No | Agents can't see each other |

### Model Selection

| Task Type | Model | Why |
|-----------|-------|-----|
| File search, pattern matching | haiku | Deterministic, can't fail |
| Code analysis, exploration | sonnet | Good balance |
| Architecture, complex reasoning | opus | Worth the cost |

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

**Naming patterns:** `*-architect` for architecture, `*-pro` for language expertise (python-pro, typescript-pro, rust-pro, golang-pro, bash-pro).

**PR Review Toolkit** (use together for comprehensive review):
- `code-reviewer` - Quality, conventions, bugs
- `silent-failure-hunter` - Error handling gaps
- `pr-test-analyzer` - Test coverage
- `type-design-analyzer` - Type invariants

### Red Flags

- Launching agents for simple lookups (use Grep)
- Sequential agents that depend on each other
- Forgetting to specify model (defaults to sonnet)
- Vague prompts that cause redundant exploration
- More than 3 parallel agents (diminishing returns)

## Complements
- `explore.md` - When to ask before launching
- `minimize.md` - Keep agent prompts focused
- `verify.md` - Verify agent outputs
