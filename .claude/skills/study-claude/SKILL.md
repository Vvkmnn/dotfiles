---
name: study-claude
description: Use when the user asks to "research X", "literature review on", "verify citations", "find research gaps", "gap analysis", "review related work", "identify research opportunities", "what does the research say about", "find papers on", or any academic/scientific research task. Covers the full research lifecycle from ideation through literature review to citation verification. Works across all domains — economics, marketing, finance, CS, AI, sciences, medicine.
version: 0.1.0
---

# Study Claude — Research Lifecycle

Full research workflow using paper_search MCP (22+ academic sources) and FRED MCP (economic data). Three phases: ideation, literature review, citation verification.

## When to Use

- Starting a research project or exploring a new domain
- Conducting systematic literature review
- Verifying citations in academic writing (critical — AI citations have ~40% error rate)
- Identifying research gaps and opportunities
- Formulating research questions
- Analyzing trends across a field

## Phase 1: Ideation

### 5W1H Framework

Brainstorm research ideas systematically:
- **What**: Problem or phenomenon to study
- **Why**: Importance and impact
- **Who**: Target audience and stakeholders
- **When**: Time scope and temporal context
- **Where**: Application domains and settings
- **How**: Preliminary methodology ideas

Integrates with `superpowers:brainstorming` for interactive exploration.

### Gap Analysis (5 Types)

Identify research opportunities through systematic gap identification:

1. **Literature gaps** — Topics or questions not yet sufficiently studied
2. **Methodology gaps** — Limitations in existing methods, improvement opportunities
3. **Application gaps** — Theory-to-practice transfer opportunities
4. **Interdisciplinary gaps** — Opportunities at the intersection of fields
5. **Temporal gaps** — New needs arising from changes over time (technology shifts, policy changes, market evolution)

### Research Question Formulation

Apply SMART principles:
- **S**pecific — Clearly defined scope
- **M**easurable — Observable outcomes or metrics
- **A**chievable — Feasible given available resources and data
- **R**elevant — Addresses an identified gap
- **T**ime-bound — Defined temporal scope

## Phase 2: Literature Review

### Search Strategy

Use paper_search MCP tools for multi-source concurrent search:

1. **Broad search** — `search_papers` for cross-source discovery with deduplication
2. **Source-specific** — `search_arxiv`, `search_pubmed`, `search_google_scholar`, `search_semantic_scholar` for targeted queries
3. **Metadata** — `search_crossref`, `search_openalex` for DOI resolution and citation data
4. **Economics** — FRED MCP tools for economic time series when researching financial, economic, or policy topics
5. **Download + read** — `download_arxiv`, `read_arxiv_paper` for full-text access

### Review Workflow

```
Define scope → Build search queries → Multi-source search → Deduplicate →
Screen by abstract → Download key papers → Read full text → Extract themes →
Identify gaps → Synthesize findings → Structured output
```

### Structured Output

Produce a literature review with:
- **Themes** — Major research threads and how they relate
- **Timeline** — Evolution of the field over time
- **Key contributors** — Most cited authors and groups
- **Methodology comparison** — Approaches used, their strengths and weaknesses
- **Gaps** — What's missing (use 5-type gap analysis from Phase 1)
- **Recommendations** — Promising directions for new research

## Phase 3: Citation Verification

### Core Principle

**Never hallucinate citations.** AI-generated citations have approximately 40% error rate. Every citation must be verified programmatically before inclusion.

### Verification Workflow

```
Need a citation → Search via paper_search MCP → Verify paper exists →
Confirm metadata matches → (If citing a claim) Verify claim in paper →
Add to references
```

### What to Verify

For each citation, confirm:
- **Paper exists** — Found in Google Scholar, Semantic Scholar, or Crossref
- **Title matches** — Minor differences allowed (capitalization)
- **Authors match** — At least first author correct
- **Year correct** — ±1 year allowed for preprints
- **Venue correct** — Conference or journal name matches
- **Claim accurate** — If citing a specific finding, verify it appears in the paper

### Verification Tools

| Check | MCP Tool |
|-------|----------|
| Paper exists | `search_google_scholar`, `search_semantic_scholar` |
| DOI/metadata | `search_crossref` |
| Full text claim | `download_arxiv` + `read_arxiv_paper` |
| Citation count | `search_semantic_scholar` (includes citation metrics) |

### When You Cannot Verify

If a citation cannot be programmatically verified:
- Mark as `[CITATION NEEDED]` or `[VERIFY: author2024_title]`
- Never generate BibTeX from memory
- Tell the user: "I marked N citations as unverified — please confirm these exist"

## Domain-Specific Notes

### Economics & Finance
- Use FRED MCP for economic indicators (GDP, CPI, unemployment, interest rates)
- Search SSRN via paper_search for working papers
- NBER working papers available via search_papers

### Computer Science & AI
- arXiv is primary — use `search_arxiv` for latest preprints
- dblp via paper_search for conference proceedings
- Semantic Scholar for citation graph analysis

### Biomedical & Life Sciences
- PubMed and PubMed Central via paper_search
- bioRxiv/medRxiv for preprints
- Europe PMC for European research

### Marketing & Business
- Google Scholar via paper_search for business journals
- SSRN for working papers
- Crossref for DOI-based journal article lookup

## Anti-Patterns

- Searching the web when paper_search MCP tools exist — use MCP first
- Generating citations from memory — always verify programmatically
- Presenting unverified claims as facts — anchor to specific papers
- Broad unfocused searches — start specific, broaden only if needed
- Skipping deduplication — same paper appears in multiple sources
