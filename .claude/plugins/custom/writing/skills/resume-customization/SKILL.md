---
name: resume-customization
description: This skill should be used when the user provides a "job description", "LLM ATS analysis", "resume customization request", or asks to "customize my resume", "adapt resume for", "create tailored resume", or mentions updating Notion job tracking. Guides end-to-end resume customization workflow with 4-page enforcement, claude-mem research, and Notion integration.
version: 0.1.0
---

# Resume Customization Workflow

## Purpose

Transform the master resume (`/Users/v/Documents/cv/resume.tex`) into job-specific variants aligned with external ATS analysis while maintaining authenticity. This skill guides a proven iterative workflow that researches past successful transformations and enforces strict guardrails.

## When to Use

Use this skill when the user provides:
1. A job description (text, URL, or LinkedIn link)
2. LLM ATS analysis output (externally generated with scoring and keyword gaps)
3. Notion job tracking link (optional - if not provided, will invoke `automating:job-tracker` to find/create)

**Note:** This skill does NOT perform ATS scoring - user provides pre-scored analysis from external service.

## Integration with job-tracker

**If user does NOT provide Notion link:**
1. Invoke `automating:job-tracker` skill to:
   - Search for existing job in Notion database
   - If not found → create new entry with Status = "Considering"
   - Get Notion page ID for this job
2. Resume customization continues with confirmed Notion entry

**If user provides Notion link:**
- Skip to resume customization workflow directly

## Execution Model

**ALWAYS start in Plan Mode with Opus for strategic thinking:**

1. **Enter Plan Mode immediately** when user provides inputs
2. **Use Opus** for research and strategic decisions:
   - Analyzing JD requirements
   - Querying claude-mem for past patterns
   - Making positioning choices (consulting vs sales vs technical)
   - Deciding header/tagline transformations
   - Planning summary and skills reframes
   - Determining which experience bullets to modify
3. **Create comprehensive plan** with all content decisions
4. **Get user approval** on plan before implementation
5. **Exit Plan Mode and switch to Sonnet** for implementation:
   - LaTeX edits and formatting
   - PDF compilation
   - Notion MCP calls

**Why this matters:**
- **Opus**: Better strategic thinking for content positioning decisions
- **Sonnet**: Efficient for mechanical edits, LaTeX syntax, MCP integration
- **Planning first**: Ensures all decisions are thoughtful before touching code

## Workflow Overview

Follow this checklist using TodoWrite to track progress:

1. **Research Past Patterns** - Query claude-mem for similar transformations FIRST
2. **Parse Inputs** - Extract JD requirements, keywords from external ATS analysis
3. **Create Folder Structure** - Set up dated customization folder
4. **Transform Resume** - Apply systematic four-dimensional reframing
5. **Quality Check** - Grammar, Australian English, readability (elements-of-style)
6. **Compile & Verify** - Build PDF, ensure <4 pages
7. **Propose Notion Update** - Show changes and get user approval
8. **Update Notion Tracking** - Execute approved MCP calls to update database

## Step-by-Step Implementation

### Step 1: Research Past Transformations (MANDATORY FIRST STEP)

**Before making any resume changes, research similar past work:**

Query claude-mem for relevant patterns:

1. **Identify role type** from JD (consulting, sales, product, technical, professional services)
2. **Search for similar transformations:**
   - `"resume customization [role-type] positioning transformation"`
   - `"[company-name] resume"` (if we've customized for this company before)
   - `"header title tagline [role-type]"` for header transformation patterns
   - `"experience bullets reframe [role-type]"` for bullet transformation patterns

3. **Review findings** and present to user:
   - What transformations worked for similar roles?
   - What header/tagline patterns were successful?
   - What skills section reorganizations were applied?
   - What experience bullet reframes were used?

4. **Get user confirmation** before proceeding

**Example:**
```
Found 3 similar consulting transformations in claude-mem:
- Quantium: "AI Engineering Lead" → "AI Delivery Lead", added "Consulting & Delivery" skills
- Macquarie: "Technical Lead" → "AI Strategy & Transformation Leader", advisory tagline
- Notion: "Technical Lead" → "Technical Consulting Leader", PS/GTM tagline

Use these patterns as starting point? [yes/no/modify]
```

### Step 2: Parse Inputs and Set Up TodoWrite

Create todos for the complete workflow:

```
- Research past transformations in claude-mem
- Parse job description for key requirements and keywords
- Identify target positioning (consulting, sales, product, technical)
- Find or create Notion database entry
- Create customization folder and copy master resume
- Transform header and tagline
- Rewrite summary section
- Reorganize skills section
- Reframe experience bullets (per role)
- Check Australian English spelling and grammar
- Review readability and apply elements-of-style principles
- Compile PDF and verify page count
- Propose Notion update (show user first)
- Update Notion tracking after approval
```

### Step 3: Create Folder and Initialize Files

**Query claude-mem for similar work:**

Search for: `"resume customization [role-type] positioning transformation"`

**Common transformation patterns found:**

| From → To | Header Change | Tagline Shift | Example |
|-----------|---------------|---------------|---------|
| Technical → Consulting | "AI Engineering Lead" → "AI Delivery Lead" | "ML - Cloud - Orchestration" → "End-to-End Delivery - C-Suite Advisory" | Quantium, Macquarie |
| Technical → Sales | "Principal AI Engineer" → "AI Solutions Leader" | Technical stacks → "Land-and-Expand - Value-Based - Executive Engagement" | Microsoft Partner, AI Workforce |
| Technical → Professional Services | "Technical Lead" → "Technical Consulting Leader" | "Data Science - ML" → "Professional Services - Customer Adoption - GTM" | Notion PS Consultant |
| Technical → Revenue/Monetization | "Technical Lead" → "Ads Strategy & Programmatic Monetization Leader" | "ML - Data Science - Cloud" → "Revenue Analytics - Yield Optimization - Market Strategy" | Netflix Manager |
| Technical → Staff Technical | "Technical Lead" → "Staff AI Engineer & Technical Lead" (JD title first) | "ML - Data Science - Cloud" → "LLM Orchestration - Retrieval & Ranking - Production AI" | Heidi Staff AI Engineer |

### Step 3: Create Folder and Initialize Files

**Folder naming:** `[company]-[job-title]/` (lowercase, hyphens)

**File naming:** `[company]-[job-title]-[YYYY-MM-DD]_vm_resume.tex`

```bash
cd /Users/v/Documents/cv/customized
mkdir -p [company]-[job-title]
cp ../resume.tex [company]-[job-title]/[company]-[job-title]-[date]_vm_resume.tex
```

**CRITICAL: Fix asset path immediately**

In the copied file, change line ~66:
```latex
% FROM:
\includegraphics[height=2.3cm]{assets/vLogoWhite.png}
% TO:
\includegraphics[height=2.3cm]{../../assets/vLogoWhite.png}
```

### Step 4: Four-Dimensional Transformation

**CRITICAL PRINCIPLE: Blend, Don't Create**

- **Prefer editing existing content** over creating new sections
- **Avoid adding new LaTeX sections, headers, or structural elements**
- **Work within the current resume structure** - reword, reorder, reorganize
- **Only create new elements when absolutely necessary** for JD alignment
- **If creating anything new** (new skills subsection, new interest, custom row):
  1. Explain in detail WHY it's necessary
  2. Show what you're adding and where
  3. Get user approval BEFORE adding it
  4. Ensure it flows naturally with existing content

**Examples:**

✅ **Good (blend and edit):**
- Change "AI Engineering Lead" → "AI Delivery Lead" (edit existing title)
- Reorder skills subsections (move existing categories up/down)
- Rewrite experience bullets (edit existing content)
- Reorganize interests (edit existing list)

❌ **Bad (create new):**
- Add new "Partner & GTM" section to resume (new structure)
- Insert new "Certifications" section (new element)
- Add new row to skills table without explaining why
- Create custom "Key Achievements" section (new header)

**If you must create something new, ask first:**
```
"The JD heavily emphasizes [X] but our resume has no dedicated section for it.
I recommend adding a new [Y] subsection under [Z] with these items: [list].
This would improve ATS matching for [keywords].
Approve this addition? [yes/no/modify]"
```

Apply transformations in this order:

#### Dimension 1: Header & Title (Lines ~71-72)

**Pattern:** Shift professional identity to match JD positioning

**IMPORTANT: Always propose header changes and get user approval FIRST.** Header/tagline changes are high-impact positioning decisions. Show user what you're proposing and why before making the change.

```latex
% Technical positioning:
{\fontsize{15pt}{12pt}\selectfont Technical Lead \& Principal AI Engineer}

% Consulting positioning:
{\fontsize{15pt}{12pt}\selectfont Lead AI \& Data Transformation Consultant}

% Sales positioning:
{\fontsize{15pt}{12pt}\selectfont AI Solutions Leader \& Digital Transformation Specialist}

% Professional Services positioning:
{\fontsize{15pt}{12pt}\selectfont Technical Consulting Leader}

% Revenue/Monetization positioning:
{\fontsize{15pt}{12pt}\selectfont Ads Strategy \& Programmatic Monetization Leader}

% Staff Technical positioning (maintains technical depth, adds seniority):
{\fontsize{15pt}{12pt}\selectfont Staff AI Engineer \& Technical Lead}
% Note: Put JD exact title FIRST when it's close enough to existing
```

#### Dimension 2: Tagline (Line ~72)

**Pattern:** Replace technology keywords with business outcome keywords OR add domain-specific technical terms

**IMPORTANT: Always propose tagline changes and get user approval FIRST.** Show user what you're proposing and why before making the change.

```latex
% Technical tagline:
{\fontsize{11pt}{9pt}\selectfont\mbox{Machine Learning - Data Science - Cloud Architecture}}

% Consulting tagline:
{\fontsize{11pt}{9pt}\selectfont\mbox{End-to-End Delivery - C-Suite Advisory - Strategic Execution}}

% Sales tagline:
{\fontsize{11pt}{9pt}\selectfont\mbox{Land-and-Expand - Value-Based Solutions - Executive Engagement}}

% Professional Services tagline:
{\fontsize{11pt}{9pt}\selectfont\mbox{Professional Services - Workflow Design - Customer Adoption - GTM Enablement}}

% Revenue/Monetization tagline:
{\fontsize{11pt}{9pt}\selectfont\mbox{Revenue Analytics - Yield Optimization - Market Strategy - CTV/Streaming}}

% Staff Technical tagline (stays technical but adds domain-specific terms):
{\fontsize{11pt}{9pt}\selectfont\mbox{LLM Orchestration - Retrieval \& Ranking - Production AI - Clinical Systems}}
% Note: For Staff technical roles, maintain technical depth but mirror JD-specific domains
```

#### Dimension 3: Summary Section (Lines ~95-100)

**Pattern:** Rewrite all 5 bullets to emphasize JD-aligned language

**Consulting transformation example:**
- Bullet 1: Lead with "end-to-end transformation engagements" instead of "advising executives"
- Bullet 2: Emphasize "C-suite partnership translating ambiguity" instead of "shaping strategy"
- Bullet 3: Add "ownership of timelines/deliverables/outcomes" and "autonomous operation with minimal direction"
- Bullet 4: Highlight "team building and mentorship" with "commercial growth metrics"
- Bullet 5: Combine "business fluency in AI/ML" with "hands-on delivery credibility"

**Sales transformation example:**
- Bullet 1: Open with "driving revenue growth through AI solution sales"
- Bullet 2: Emphasize "building value-based business cases for C-level buyers"
- Bullet 3: Add "orchestrating virtual account teams" and "land-and-expand motions"
- Bullet 4: Quantify "quota attainment" or "pipeline growth"
- Bullet 5: Highlight "technical credibility" enabling "executive-level ROI narratives"

**Staff Technical transformation example (Heidi):**
- Bullet 1: Add domain-specific technical depth (e.g., "retrieval-augmented generation, hybrid search, LLM orchestration") with scale constraints ("serving real users under strict latency and reliability constraints")
- Bullet 2: Emphasize decision ownership and architectural authority ("sets technical direction," "owns architectural decisions from design through production," "coaches engineers")
- Bullet 3: Add Staff-level technical artifacts ("design docs," "code reviews," "reusable components")
- Bullet 4: Include evaluation rigor with specific metrics ("gold-standard evaluation with synthetic + human feedback," "nDCG," "MAP," specific improvements like "+26% model response quality")
- Bullet 5: Domain-specific safety/compliance if relevant ("safety-critical AI," "hallucination controls," "PHI handling," "HIPAA," "privacy-by-design in regulated verticals")

#### Dimension 4: Skills Section (Lines ~105-140)

**Pattern:** Reorganize subsections to lead with JD-relevant categories

**Consulting transformation:**
```latex
\section{Skills \& Capabilities}
\subsection{Consulting \& Delivery}  % NEW - was "Strategy & Governance"
\textbf{Transformation}: End-to-End Delivery, Program Governance, Value Realization, Change Management
\textbf{Advisory}: Executive Communication, Strategic Roadmapping, Business Case Development
\textbf{Leadership}: Cross-functional Teams, Stakeholder Management, Client Relationship Building

\subsection{AI/ML \& Data Engineering}  % Moved down from top
[Technical skills remain intact]
```

**Sales transformation:**
```latex
\section{Skills \& Capabilities}
\subsection{Solution Sales \& GTM}  % NEW
\textbf{Sales}: Land-and-Expand, Value-Based Selling, Executive Engagement, ROI Analysis
\textbf{Partner \& Channel}: Co-sell Motions, Partner Enablement, Channel Strategy
\textbf{Customer Success}: Adoption Planning, Change Management, Executive Sponsorship

\subsection{AI/ML \& Technical Depth}  % Maintains credibility
[Technical skills remain intact]
```

**Skills Table Formatting:**

The master resume uses a `tabularx` table for skills. If the table appears broken/ugly with wrapped category headers:

```latex
% Fix column widths in tabularx specification:
\begin{tabularx}{\textwidth}{@{}p{5cm} p{2.5cm} X@{}}
```

**Column width breakdown:**
- First column `p{5cm}`: Category headers (e.g., "Revenue & Yield Analytics", "Programmatic & Market Strategy")
- Second column `p{2.5cm}`: Subcategory labels in italics (e.g., "Monetization", "Platforms", "Strategy")
- Third column `X`: Flexible width for skill items

**Common issue:** Default `p{3.8cm}` is too narrow for business-focused category names and causes text wrapping.

#### Dimension 5: Experience Bullets (Per Role)

**Pattern:** Reframe responsibilities and bullets role-by-role

**Consulting reframe (Casper Studios example):**
```latex
% OLD:
\subsubsection{AI Engineering Lead}
Led full-lifecycle generative-AI initiatives from research to proof-of-concept to production...

% NEW:
\subsubsection{AI Delivery Lead}
Led consultative AI transformation engagements with C-level executives, translating ambiguous business requirements into actionable technical solutions...
```

**Sales reframe (Casper Studios example):**
```latex
\subsubsection{AI Solutions Architect}
Drove land-and-expand motions across enterprise accounts, building value-based business cases for C-suite stakeholders and orchestrating virtual teams across engineering, partners, and governance...
```

**Key verb transformations:**
- Technical: "architected, deployed, designed, built, engineered"
- Consulting: "advised, enabled, partnered, guided, facilitated, navigated, delivered"
- Sales: "drove, positioned, orchestrated, closed, expanded, demonstrated"
- Professional Services: "implemented, onboarded, enabled, supported, trained"

### Step 5: Writing Quality, Grammar & Australian English Check

**After completing transformations, review for quality and correctness:**

#### 5a: Australian English Spelling

**Convert US English → Australian English:**
- organize → organise
- optimize → optimise
- realize → realise
- analyze → analyse
- center → centre
- color → colour
- favor → favour
- labor → labour
- program → programme (when noun, not software)
- traveled → travelled
- modeling → modelling

**Common tech terms (keep as-is):**
- "optimize" in technical contexts (codebase optimization)
- "program" for software programs
- "analyze" when referring to data analysis tools

#### 5b: Grammar & Spelling Check

**Review all modified sections for:**
- Spelling errors (typos, wrong words)
- Grammar mistakes (subject-verb agreement, tense consistency)
- Punctuation errors (missing commas, incorrect apostrophes)
- Capitalization (proper nouns, titles)

**Use elements-of-style skill if needed:**
```
If encountering unclear or wordy writing, invoke:
elements-of-style:writing-clearly-and-concisely
```

#### 5c: Readability Principles

**Ensure all bullets are:**
- **Clear** - No ambiguous phrasing, reader understands immediately
- **Concise** - No unnecessary words (see Strunk's Rule 13: "Omit needless words")
- **Active voice** - "Led transformation" not "Transformation was led"
- **Specific** - Use concrete details and metrics, avoid vague claims
- **Parallel structure** - Similar grammatical construction within sections

**Examples:**

❌ **Weak:**
```
Was responsible for the implementation of AI solutions that resulted in improvements
```

✅ **Strong:**
```
Implemented AI solutions that improved operational efficiency by 40%
```

❌ **Wordy:**
```
Played a key role in the successful delivery of enterprise-wide transformation initiatives
```

✅ **Concise:**
```
Led enterprise-wide transformation initiatives across 3 business units
```

**Check for common resume writing mistakes:**
- Personal pronouns (I, me, my) - Remove all
- Passive voice - Convert to active
- Vague quantifiers ("many", "several") - Replace with specific numbers
- Buzzwords without substance ("synergy", "leverage", "utilize") - Use concrete language

#### 5d: Final Quality Gate

Before proceeding to PDF compilation:
- [ ] All sections use Australian English spelling
- [ ] No grammar or spelling errors
- [ ] All bullets use active voice
- [ ] All claims are specific with metrics where possible
- [ ] Writing is clear, concise, and readable
- [ ] Parallel structure maintained within sections

### Step 6: Compile PDF and Verify Constraints

**Build command:**
```bash
cd /Users/v/Documents/cv/customized/[company]-[job-title]
pdflatex [company]-[job-title]-[date]_vm_resume.tex
```

**Critical verifications:**
1. PDF compiles without errors
2. Page count ≤ 4 pages (HARD REQUIREMENT)
3. Logo renders correctly (asset path fix worked)
4. No overfull hbox warnings causing text overflow

**CRITICAL GUARDRAIL: NEVER delete entire sections to fit page limit.**
- Do NOT remove Projects, Certifications, Education, or any complete section
- Work within the structure, surgical reductions only

**If approaching/exceeding 4 pages:**

**Step 1: Reorder Experience by JD Relevance**
- Move the MOST RELEVANT job immediately after Skills section
- Example: For advertising roles, move Kinesso above other experience
- Reorder remaining jobs by decreasing relevance to JD
- This maximizes recruiter impact without losing content

**Step 2: Apply Surgical Reductions (in priority order):**
1. Remove 1-2 bullets from OLDER roles (4+ years ago)
2. Condense skills subsections (merge related items)
3. Tighten bullet point wording (remove filler words)
4. Reduce section spacing (`\medskip` → `\smallskip`)
5. Font size reduction to `10.5pt` (LAST RESORT)

**Never sacrifice:**
- Most recent 2-3 roles (keep all bullets intact)
- Quantified metrics and achievements
- JD-aligned keywords and terminology
- Entire sections (Projects, Certifications, etc.)

### Step 7: Propose Notion Update (MANDATORY USER APPROVAL)

**CRITICAL: Always show proposed changes and get user approval before ANY Notion MCP calls.**

#### Step 7a: Research Missing Properties

Research and suggest logical values for:

**Company Size** (based on company research):
- **Startup**: Early-stage, high-growth (Leonardo.Ai)
- **SMB**: Small-to-medium (Canva, Zip, Prophet, OpenAI)
- **Enterprise**: Large corporations (Microsoft, Amazon, CommBank, PwC, Macquarie, Accenture)

**Work Style** (from JD or company website):
- Remote / Hybrid / Office

**Location** (from JD):
- Extract city/state or "Remote"

#### Step 7b: Prepare Detailed Changes Documentation

Document 8-10 specific bullets covering:
- **Exact title/tagline changes** (quote the new text)
- **Summary rewrites** (what themes were emphasized, e.g., "end-to-end delivery," "C-suite advisory")
- **New metrics added** (specific numbers, e.g., "$77K to $4.1M ARR")
- **New skills categories** (exact names, e.g., "Consulting & Delivery")
- **Experience modifications** (which company, what was added/changed)

#### Step 7c: Show Proposed Update and Ask for Approval

**Template:**

```
Before updating Notion, here's what I'll do:

**Properties:**
- Company: [Company Name]
- Role: [Job Title]
- Status: Review
- Customized Resume: true
- Job Posting: [URL]
- Location: [City, State or Remote]
- Company Size: [Startup/SMB/Enterprise] (based on [research source])
- Work Style: [Remote/Hybrid/Office] (based on [JD or website])

**Page Body:**

## Resume
Path: /Users/v/Documents/cv/customized/[company]-[role]/[company]-[role]-[date]_vm_resume.pdf
(You'll upload the PDF embed yourself)

## Changes
- Header: Changed title from "[old]" to "[exact new title]"
- Header: Changed tagline from "[old]" to "[exact new tagline]"
- Summary: Rewrote bullet 1 to emphasize [specific theme]
- Summary: Added commercial metrics ($X → $Y ARR)
- Skills: Added "[Exact Category Name]" as first section ([subcategories])
- Skills: Moved [category] from position X to Y
- [Company Name]: Changed role title from "[old]" to "[new]"
- [Company Name]: Added bullet emphasizing [specific concept]
- [Company Name]: Changed company description to "[exact new description]"
- [Additional specific changes...]

## Job Description
[Full JD text from user]

## Notes
(empty - you'll add your own notes)

**Confirm these changes before I update Notion?** [yes/no/modify]
```

### Step 8: Update Notion Tracking (After User Approval)

**Only execute after user confirms "yes"**

Use code-mode Notion integration:

```typescript
const DATABASE_ID = "2c8b6eb0-ddc0-81f0-884e-e0de405d82ae";

await mcp__code-mode__call_tool_chain({
  code: `
    const result = await notion.notion_API_post_page({
      parent: {
        type: "database_id",
        database_id: "${DATABASE_ID}"
      },
      properties: {
        "Job": { title: [{ text: { content: "[Company] - [Job Title]" } }] },
        "Company": { rich_text: [{ text: { content: "[Company]" } }] },
        "Role": { rich_text: [{ text: { content: "[Job Title]" } }] },
        "Status": { select: { name: "Considering" } },
        "Resume Customized?": { checkbox: true },
        "Job Posting": { url: "[URL]" },
        "Location": { rich_text: [{ text: { content: "[Location]" } }] },
        "Company Size": { select: { name: "[Startup/SMB/Enterprise]" } },
        "Work Style": { select: { name: "[Remote/Hybrid/Office]" } }
      },
      children: [
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ text: { content: "Resume" } }] } },
        { object: "block", type: "paragraph", paragraph: { rich_text: [{ text: { content: "Path: /Users/v/Documents/cv/customized/[path]" } }] } },
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ text: { content: "Changes" } }] } },
        // ... 8-10 bulleted_list_item entries with approved changes
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ text: { content: "Job Description" } }] } },
        { object: "block", type: "paragraph", paragraph: { rich_text: [{ text: { content: "[Full JD]" } }] } },
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ text: { content: "Notes" } }] } }
      ]
    });
    return result;
  `
});
```

## ATS Optimization Guardrails

**Do:**
- Use JD keywords naturally in summary and experience bullets
- Maintain consistent section headers (ATS-friendly)
- Keep technical certifications and frameworks visible
- Use standard LaTeX formatting (no complex tables in main content)
- Preserve quantified metrics and achievements

**Don't:**
- Keyword-stuff or use unnatural phrasing
- Lie or exaggerate accomplishments
- Remove technical depth entirely (maintains credibility)
- Create skills you don't have
- Exceed 4 pages (automatic ATS penalty)

**Authenticity check:**

Every transformation must be:
1. **Truthful** - No fabricated experience or skills
2. **Verifiable** - All metrics and achievements are real
3. **Natural** - Language flows authentically
4. **Strategic** - Reframes existing work, doesn't invent new work

## Common Pitfalls

1. **Creating new sections instead of editing** - Don't add new LaTeX sections/headers without asking user first. Blend into existing structure.
2. **Forgetting asset path fix** - Logo won't render, PDF compile fails
3. **Exceeding 4 pages** - Immediate ATS score reduction
4. **Losing technical credibility** - Don't remove all technical skills for sales/consulting roles
5. **Breaking LaTeX syntax** - Always test compile immediately after edits
6. **Not updating Notion** - Tracking gets out of sync
7. **Adding elements without explanation** - If you need to add a new subsection, interest, or row, explain WHY in detail first and get approval

## Success Metrics

**Completion criteria:**
- ✅ Claude-mem research completed and findings presented to user
- ✅ Four-dimensional transformation applied (header, summary, skills, experience)
- ✅ Australian English spelling throughout (organise, optimise, realise, centre, etc.)
- ✅ Grammar and spelling checked (no errors)
- ✅ Writing quality verified (clear, concise, active voice, specific)
- ✅ Elements-of-style principles applied where needed
- ✅ PDF compiled successfully
- ✅ Page count ≤ 4 pages (HARD REQUIREMENT)
- ✅ All quantified metrics and achievements preserved
- ✅ JD-aligned keywords naturally integrated
- ✅ User approved Notion update before MCP execution
- ✅ Notion tracking updated: "Resume Customized?" = true, Status = "Considering"
- ✅ Resume path documented in Notion page body

**Quality indicators:**
- Positioning matches JD requirements exactly (as confirmed by external ATS analysis)
- Language flows naturally (no keyword stuffing)
- All text uses Australian English spelling
- Writing is clear, concise, and readable (Strunk's principles)
- Technical credibility maintained
- All transformations truthful and verifiable

## Reference

**Master resume location:** `/Users/v/Documents/cv/resume.tex`

**Customized resumes location:** `/Users/v/Documents/cv/customized/[company]-[role]/`

**Notion database:** https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c

**README workflow:** `/Users/v/Documents/cv/customized/README.md`

**Claude-mem queries:** Search for similar past transformations before starting new customization
