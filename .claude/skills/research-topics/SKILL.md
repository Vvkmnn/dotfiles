---
name: research-topics
description: >
  Use for any research task — "research X", "find best practices", "literature review on",
  "find papers on", "verify citations", "what's the best way to implement", "what does the
  research say about". Two modes, auto-routed: TECHNICAL (libraries, tools, implementation —
  parallel specialized agents) and ACADEMIC (papers, citations, gaps — paper_search + FRED MCPs,
  paper-researcher agent). Say which mode you chose when the signal is ambiguous. For a formal
  multi-source cited research REPORT deliverable, use the bundled deep-research skill instead.
version: 2.0.0
---

# Research

One entry point for research. Route by signal, announce the mode, then follow that mode's protocol.

| Signal words | Mode |
|---|---|
| library, framework, tool, implementation, best practice, codebase, "how do others do X" | **Technical** |
| papers, literature, citations, journals, research gaps, related work, academic, "what does the research say" | **Academic** |
| Ambiguous ("research X") | Pick by topic domain; state the choice in one line |

Skip research entirely when: pattern already in codebase (Grep/Read directly), user says "just do it", already researched this session (check historian first), or a simple syntax/API question (Context7 directly).

---

## Mode A: Technical

Parallel research using specialized plugin agents instead of generic Explore. Each has built-in methodology (deprecation checking, version-pinned docs, ast-grep, git archaeology).

### The Five Concerns → Agents

| Concern | Agent |
|---------|-------|
| Best-in-class online | `compound-engineering:research:best-practices-researcher` |
| Latest docs/research | `compound-engineering:research:framework-docs-researcher` |
| Our local codebase | `compound-engineering:research:repo-research-analyst` |
| Optimizations | `compound-engineering:review:performance-oracle` |
| Common pitfalls | `debugging-toolkit:debugger` |

Extras: `git-history-analyzer` (why code exists), `pattern-recognition-specialist` (consistency), `code-simplicity-reviewer` (over-engineering check).

### Dispatch Modes

| Mode | When | Agents |
|------|------|--------|
| **Quick** | Narrow question, one source | 1 (best-practices-researcher) |
| **Focused** (default) | "research X" | 3: best-in-class + docs + codebase |
| **Deep** | Architecture decisions, "thorough", hard-to-reverse | All 5 concerns |

All agents dispatched in ONE message (true parallelism), model `sonnet` — never haiku for research (capability cliff on synthesis); opus for architecture-stakes decisions.

### Prompt Template

```
Research [topic] for [context].
Specific questions: 1. [...] 2. [...]
Already known: [what we know, what's been tried]
Scope: [directories, languages, frameworks]
Do NOT: [tests, mocks, deprecated code, ...]
Return: findings with sources (file:line or URL), confidence per finding, gaps.
```

### MCP Source Guide

| Need | MCP / Tool |
|------|-----------|
| Library docs | Context7 `resolve-library-id` → `query-docs` |
| Community solutions | stackoverflow, hackernews, reddit search tools |
| GitHub examples | github `search_code`, `search_repositories` |
| Video content | youtube/yt_dlp transcripts |
| General web | brave_search |
| Past decisions | claude-historian `search_conversations`, `search_plans` |

### Synthesis (never dump raw results)

1. **Cross-reference** — finding from 2+ agents = high confidence
2. **Flag conflicts** — agents disagree = present both sides with sources
3. **Surface gaps** — nobody could answer = genuine unknown
4. **Recommend** — best approach, confidence level, sources

Output: `## Key Findings (consensus)` / `## Insights (single-source)` / `## Conflicts` / `## Recommended Approach`.

High-stakes decisions (architecture, security, breaking changes): dispatch one fresh Explore agent to verify the synthesized conclusions independently — verified/unverified/contradicted per claim.

---

## Mode B: Academic

Full research lifecycle via paper_search MCP (22+ academic sources) and FRED MCP (economic data). For autonomous multi-source runs, dispatch the `paper-researcher` agent (background-capable).

### Phase 1: Ideation

- **5W1H**: What (problem) / Why (impact) / Who (stakeholders) / When (time scope) / Where (domains) / How (methodology). Pairs with `superpowers:brainstorming`.
- **Gap analysis, 5 types**: literature, methodology, application, interdisciplinary, temporal.
- **Research questions**: SMART — Specific, Measurable, Achievable, Relevant, Time-bound.

### Phase 2: Literature Review

Search strategy:
1. **Broad** — `search_papers` (cross-source, deduplicating)
2. **Source-specific** — `search_arxiv`, `search_pubmed`, `search_google_scholar`, `search_semantic`
3. **Metadata** — `search_crossref`, `search_openalex` for DOI/citation data
4. **Economics** — FRED tools for time series
5. **Full text** — `download_arxiv` + `read_arxiv_paper`

Workflow: define scope → build queries → multi-source search → deduplicate → screen by abstract → download key papers → read → extract themes → identify gaps → synthesize.

Output structure: **Themes** / **Timeline** / **Key contributors** / **Methodology comparison** / **Gaps** (5-type) / **Recommendations**.

### Phase 3: Citation Verification

**Never hallucinate citations** — AI-generated citations run ~40% error rate. Verify every one programmatically:

| Check | Tool |
|-------|------|
| Paper exists | `search_google_scholar`, `search_semantic` |
| DOI/metadata | `search_crossref` |
| Claim appears in paper | `download_arxiv` + `read_arxiv_paper` |
| Citation count | `search_semantic` |

Confirm: paper exists, title matches, first author correct, year ±1 (preprints), venue matches, claim accurate. Unverifiable → mark `[VERIFY: author2024_title]`, never generate BibTeX from memory, tell the user the count of unverified citations.

### Domain Notes

- **Econ/Finance**: FRED for indicators; SSRN + NBER via search_papers
- **CS/AI**: arXiv primary; dblp for proceedings; Semantic for citation graphs
- **Biomedical**: PubMed/PMC, bioRxiv/medRxiv, `search_europepmc`
- **Business**: Google Scholar, SSRN, Crossref

### Anti-Patterns

- Web search when paper_search exists — MCP first
- Citations from memory — always verify
- Unverified claims as facts — anchor to papers
- Broad unfocused queries — start specific
- Skipping deduplication

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2026-07-06 | Merged research-agents (1.0.0) + study-claude (0.1.0) into two-mode skill; fixed stale tool names (search_semantic, search_europepmc) |
