---
name: research-agents
description: >
  Use for TECHNICAL research — "research this library/tool/approach", "find best
  practices for", "use research agents", "what's the best way to implement", or any
  codebase/implementation task requiring knowledge synthesis before coding. Also
  triggers on orchestrate.md research protocol: unfamiliar library, persistent error,
  design decision with unclear trade-offs. Dispatches parallel specialized agents
  covering: best-in-class online solutions, latest docs/research via MCPs, local
  codebase patterns, optimizations, and common pitfalls/code smells. For ACADEMIC
  research (papers, literature, citations), use study-claude instead.
---

# Research Agents

Parallel research using specialized plugin agents instead of generic Explore.
Each agent has a built-in methodology (deprecation checking, version-pinned docs,
ast-grep analysis, git archaeology) that Explore lacks.

## The Five Concerns

When the user says "research X", they mean find:

1. **Best-in-class solutions** — what does the industry do?
2. **Latest docs/research** — what do the official docs and MCPs say?
3. **Our local setup** — what patterns exist in this codebase already?
4. **Optimizations** — performance, simplicity, elegance opportunities
5. **Common pitfalls** — errors, code smells, anti-patterns to avoid

## Agent Mapping

Each concern maps to a specialized agent:

| Concern | Agent | Why Not Explore |
|---------|-------|-----------------|
| Best-in-class online | `compound-engineering:research:best-practices-researcher` | 3-phase: local skills, deprecation check, Context7/web. Source attribution |
| Latest docs/research | `compound-engineering:research:framework-docs-researcher` | Context7 first, reads package source code, structured 7-section output |
| Our local codebase | `compound-engineering:research:repo-research-analyst` | ARCHITECTURE.md, ast-grep, systematic doc-first exploration |
| Optimizations | `compound-engineering:review:performance-oracle` | Algorithmic complexity, memory, scalability, N+1 detection |
| Common pitfalls | `debugging-toolkit:debugger` | Error investigation, root-cause analysis, known failure patterns |

**Additional agents for specific needs:**

| Need | Agent |
|------|-------|
| Why code exists this way | `compound-engineering:research:git-history-analyzer` |
| Pattern consistency | `compound-engineering:review:pattern-recognition-specialist` |
| Over-engineering check | `compound-engineering:review:code-simplicity-reviewer` |

## Modes

| Mode | When | Dispatch |
|------|------|----------|
| **Quick** | Narrow question, one source suffices | 1 agent (best-practices-researcher) |
| **Focused** | Default — "research X" | 3 agents: best-in-class + docs + codebase |
| **Deep** | Architecture decisions, new technology | 5 agents: all five concerns in parallel |

**Default to Focused.** Escalate to Deep when the user says "thorough", "deep dive",
or when the decision is architectural / hard to reverse.

## Dispatch

All agents in ONE message for true parallelism. Every agent gets model `sonnet`.

### Prompt Template

```
Research [topic] for [context].

Specific questions:
1. [question 1]
2. [question 2]

Already known: [what we know, what's been tried]
Scope: [directories, languages, frameworks relevant]
Do NOT: [what to skip — tests, mocks, deprecated code, etc.]

Return:
- Findings with sources (file:line refs or URLs)
- Confidence per finding (high/medium/low)
- Gaps — what you couldn't determine
```

### Focused Example (3 agents)

```python
# All in single message = parallel
Agent("best practices for [X]",
      prompt_with_template,
      "compound-engineering:research:best-practices-researcher",
      model="sonnet")

Agent("docs and research for [X]",
      prompt_with_template,
      "compound-engineering:research:framework-docs-researcher",
      model="sonnet")

Agent("codebase patterns for [X]",
      prompt_with_template,
      "compound-engineering:research:repo-research-analyst",
      model="sonnet")
```

### Deep Example (5 agents)

Add to Focused:
```python
Agent("optimization opportunities for [X]",
      prompt_with_template,
      "compound-engineering:review:performance-oracle",
      model="sonnet")

Agent("pitfalls and smells for [X]",
      prompt_with_template,
      "debugging-toolkit:debugger",
      model="sonnet")
```

## MCP Sources

Agents have access to all MCPs. Guide them to the right ones:

| Need | MCP | Tool |
|------|-----|------|
| Library docs | Context7 | `resolve-library-id` then `query-docs` |
| Academic papers | arxiv | `search_papers`, `read_paper` |
| Community solutions | StackOverflow, HackerNews, Reddit | search tools |
| GitHub examples | github | `search_code`, `search_repositories` |
| Video content | YouTube / yt_dlp | `getTranscripts`, `searchVideos` |
| General web | brave_search | `brave_web_search` |
| Past decisions | claude-historian | `search_conversations`, `search_plans` |

## Model Routing

| Role | Model | Rationale |
|------|-------|-----------|
| All research agents | **sonnet** | Synthesis requires judgment. Haiku has capability cliff on analysis |
| File search helpers | **haiku** | Deterministic, verifiable |
| Architecture decisions | **opus** | High-stakes, hard to detect when wrong |

**Never Haiku for research.** Haiku misses non-obvious connections and produces
confidently wrong synthesis. The cost savings aren't worth unreliable findings.

## Synthesis

After agents return, synthesize — don't dump raw results:

1. **Cross-reference** — finding from 2+ agents = high confidence
2. **Flag conflicts** — agents disagree = present both sides with sources
3. **Surface gaps** — all agents couldn't answer = genuine unknown
4. **Recommend** — best approach with confidence level and sources

### Output Structure

```
## Key Findings (consensus across agents)
- [finding] — [source1], [source2]

## Insights (single-source, notable)
- [finding] — [source]

## Conflicts (agents disagree)
- [position A] vs [position B] — [sources]

## Recommended Approach
[synthesized recommendation]
```

## When to Verify Research

For high-stakes decisions (architecture, security, breaking changes):
- Dispatch a separate Explore agent with the synthesized conclusions
- It verifies claims independently without seeing the original agents' reasoning
- Returns verified/unverified/contradicted per claim

For routine research: cross-referencing across agents is sufficient.

## Skip When

- Pattern already in codebase — Grep/Read directly
- User says "just do it" — execute, don't research
- Already researched this session — check historian first
- Simple syntax/API question — Context7 directly, no agents needed

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-18 | Initial. Based on 3 research rounds: 80+ agent audit, 6 swarm patterns (17+ sources), LLM-as-judge literature (Anthropic evals, ICLR/ACL 2025), model routing analysis |
