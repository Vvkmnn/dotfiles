---
name: research-topics
description: >
  Use for any research task — "research X", "find best practices", "literature review on",
  "find papers on", "verify citations", "what's the best way to implement", "what does the
  research say about". Two modes, auto-routed: TECHNICAL (libraries, tools, implementation,
  community experience) and ACADEMIC (papers, citations, gaps). Both fan out to the read-only
  `researcher` agent. For a formal multi-source cited REPORT deliverable, use the bundled
  deep-research skill instead.
version: 3.0.0
---

# Research

One entry point for research. Route by signal, announce the mode, then follow that mode's protocol.

| Signal words | Mode |
|---|---|
| library, framework, tool, implementation, best practice, codebase, "how do others do X" | **Technical** |
| papers, literature, citations, journals, research gaps, related work, academic, "what does the research say" | **Academic** |
| Ambiguous ("research X") | Pick by topic domain; state the choice in one line |

Skip research entirely when: pattern already in codebase (Grep/Read directly), user says "just do it", already researched this session, or a simple syntax/API question (Context7 directly).

**Dispatch:** one `researcher` agent per independent question, all in one message (they run in parallel, read-only, without prompts even in plan mode). One agent for a narrow question; 3–5 for architecture-level or hard-to-reverse decisions. If you ARE the researcher agent, do the research yourself — don't dispatch.

**Prompt each agent with:** the question, what's already known, scope, what to skip, and the return contract (findings + source per claim + confidence + gaps, no pasted pages).

---

## Mode A: Technical

Cover the angles that apply: official docs/changelogs (Context7 for library docs), real implementations (GitHub via firecrawl `research_search_github` or `gh` in the main session), community experience (reddit, hackernews, stackoverflow, X, YouTube transcripts), and our own codebase (main session: Grep/Read).

**Synthesis — never dump raw results:** consensus (2+ independent sources) vs single-source insights, conflicts with both sides sourced, genuine unknowns, then a recommendation with confidence. For high-stakes decisions, verify the synthesis with one fresh-context agent (verified / unverified / contradicted per claim).

---

## Mode B: Academic

Full research lifecycle via OpenCLI's academic adapters (`opencli arxiv|pubmed|semanticscholar|openalex|dblp|google-scholar`), Firecrawl `research_*` when credits exist, and the FRED MCP for economic data, run by `researcher` agents. The paper_search MCP is gone (dead endpoint since 2026-07).

### Phase 1: Ideation

- **5W1H**: What (problem) / Why (impact) / Who (stakeholders) / When (time scope) / Where (domains) / How (methodology). Pairs with `superpowers:brainstorming`.
- **Gap analysis, 5 types**: literature, methodology, application, interdisciplinary, temporal.
- **Research questions**: SMART — Specific, Measurable, Achievable, Relevant, Time-bound.

### Phase 2: Literature Review

Search strategy:
1. **Broad** — `opencli semanticscholar search`, `opencli google-scholar search`
2. **Source-specific** — `opencli arxiv search`, `opencli pubmed search`
3. **Metadata** — `opencli openalex`, `opencli dblp` for DOI and citation data
4. **Economics** — FRED tools for time series
5. **Full text** — `opencli arxiv read <id>`; WebFetch the PDF

Workflow: define scope → build queries → multi-source search → deduplicate → screen by abstract → download key papers → read → extract themes → identify gaps → synthesize.

Output structure: **Themes** / **Timeline** / **Key contributors** / **Methodology comparison** / **Gaps** (5-type) / **Recommendations**.

### Phase 3: Citation Verification

**Never hallucinate citations** — AI-generated citations run ~40% error rate. Verify every one programmatically:

| Check | Tool |
|-------|------|
| Paper exists | `opencli google-scholar search`, `opencli semanticscholar search` |
| DOI/metadata | `opencli openalex`, `opencli dblp` |
| Claim appears in paper | `opencli arxiv read`, WebFetch the PDF |
| Citation count | `opencli semanticscholar search` |

Confirm: paper exists, title matches, first author correct, year ±1 (preprints), venue matches, claim accurate. Unverifiable → mark `[VERIFY: author2024_title]`, never generate BibTeX from memory, tell the user the count of unverified citations.

### Domain Notes

- **Econ/Finance**: FRED for indicators; SSRN + NBER via search_papers
- **CS/AI**: arXiv primary; dblp for proceedings; Semantic for citation graphs
- **Biomedical**: PubMed/PMC, bioRxiv/medRxiv, `search_europepmc`
- **Business**: Google Scholar, SSRN, Crossref

### Anti-Patterns

- Web search for a paper OpenCLI's academic adapters index — CLI first
- Citations from memory — always verify
- Unverified claims as facts — anchor to papers
- Broad unfocused queries — start specific
- Skipping deduplication

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 3.0.0 | 2026-09-26 | Both modes dispatch the merged read-only `researcher` agent (replaces paper-researcher + dead compound-engineering research agents); dropped historian and GitHub-MCP refs |
| 2.0.0 | 2026-07-06 | Merged research-agents (1.0.0) + study-claude (0.1.0) into two-mode skill; fixed stale tool names (search_semantic, search_europepmc) |
