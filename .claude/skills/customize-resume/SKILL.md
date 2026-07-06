---
name: customize-resume
author: Vvkmnn
description: This skill should be used when the user provides a "job posting URL", "job description", "resume customization request", or asks to "customize my resume", "adapt resume for", "create tailored resume", or mentions updating Notion job tracking. Guides end-to-end resume customization workflow with automated ATS analysis via Careersy Wingman Ultra GPT, 4-page enforcement, claude-historian research, referral strategy, role mismatch detection, and Notion MCP integration.
version: 2.0.0
---

# Resume Customization Workflow

## Purpose

Transform the master resume (`/Users/v/Documents/cv/resume.tex`) into job-specific variants using **automated ATS analysis via Careersy Wingman Ultra GPT**. This skill scrapes job descriptions, gets AI-powered ATS scoring and rewrite suggestions, researches past transformations via claude-historian, and enforces strict guardrails.

---

## ⚠️ MANDATORY CAREERSY WORKFLOW - NEVER SKIP

**The Careersy workflow has 3 NON-NEGOTIABLE steps. Missing ANY step = incomplete job.**

| Phase | When | What | Why |
|-------|------|------|-----|
| **1. INITIAL SCORE** | Before planning | Upload master resume + JD → Get baseline score | Know where you stand |
| **2. /REWRITE** | After initial score | Request `/rewrite` → Get specific transformation recommendations | Careersy guides the changes |
| **3. RE-SCORE** | After implementing changes | Upload updated PDF → Get new score vs original | Verify improvements, capture for Notion |

### After Implementation: AUTOMATIC Next Steps

**When you finish implementing resume changes and compiling the PDF, you MUST immediately:**

1. **Find the existing Careersy conversation** (don't start fresh - context is valuable)
2. **Prep the re-score prompt** using JavaScript DOM manipulation:
   ```
   Here's the updated resume with all the [Role] @ [Company] changes we discussed.
   Please re-score it against the role and let me know the new score vs the original [X]/100.
   ```
3. **Tell user to upload the PDF** with exact path
4. **Wait for Careersy response** and capture the score breakdown
5. **Only then proceed to Notion** with the updated score

**DO NOT:**
- ❌ Say "done" after PDF compilation without re-scoring
- ❌ Wait for user to remind you about re-scoring
- ❌ Skip to Notion without the updated Careersy score
- ❌ Start a fresh Careersy session (lose conversation context)

---

## Market Timing Context

**Holiday slowdown (mid-Dec to Jan):**
- Hiring managers often on extended holiday
- Decisions delayed until new year
- Current window requires fast action

**Recommended approach (from Eli's coaching):**
1. Identify 10-20 suitable positions
2. Prioritize 3-4 for full customization
3. Leverage existing contacts immediately
4. Don't wait for "perfect timing"

---

## When to Use

Use this skill when the user provides:
1. A job posting URL (LinkedIn, company careers page, etc.)
2. Notion job tracking link (optional - if not provided, will invoke `automating:job-tracker` to find/create)

**Note:** This skill performs **automated ATS scoring** via Careersy Wingman Ultra GPT using Claude in Chrome.

**Prerequisites:**
- Launch Claude Code with `claude --chrome`
- Be logged into ChatGPT in your Chrome browser

### Browser Automation Limitations (Sequential Only)

**Claude in Chrome does NOT support parallel browser sessions.** All Claude Code instances share a single Chrome tab group ([Issue #15173](https://github.com/anthropics/claude-code/issues/15173), [Issue #20100](https://github.com/anthropics/claude-code/issues/20100)).

**What this means:**
- Running multiple Claude Code instances with `--chrome` causes tab conflicts
- Browser actions from one session can interfere with another
- There is no `--chrome-instance` or `--tab-group` flag (yet)

**Workarounds considered but not recommended:**
| Approach | Issue |
|----------|-------|
| Separate Chrome profiles (`--user-data-dir`) | Requires Chrome DevTools MCP, re-login to ChatGPT, complex setup |
| TabzChrome extension | Doesn't isolate browser windows, same limitation |
| ChatGPT macOS MCP (`chatgpt-mcp`) | Works but sends to active chat window, can't target specific GPTs |

**Recommended approach:** Run resume customizations **sequentially** (one job at a time). If you need to work on multiple jobs:
1. Complete Careersy analysis for Job A
2. Then start Careersy analysis for Job B
3. Or: Use manual paste workflow (Claude prepares prompt, you paste into Careersy)

**Future fix:** Anthropic has open feature requests for session-scoped tab groups. Not yet implemented as of Feb 2026.

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

**ALWAYS start in Plan Mode with Opus for strategic thinking.**

**CRITICAL: Get Careersy analysis BEFORE writing the plan file.**

### In Plan Mode:

1. **Scrape JD first** - Browser automation to extract job description
2. **Run Careersy analysis** - Fresh session, upload resume + JD, get ATS score
3. **Get Careersy `/rewrite` suggestions** - Specific recommendations for this JD
4. **ONLY THEN write the plan** - Based on Careersy's recommendations, not your own analysis
5. **Get user approval** on plan

### After Plan Approval:

Exit plan mode and implement **in this exact order:**

1. Create folder, copy master resume, fix asset path
2. Apply Careersy's recommended transformations
3. Compile PDF, verify ≤4 pages
4. **⚠️ MANDATORY: Re-score with Careersy** (upload updated PDF to SAME conversation)
5. **⚠️ MANDATORY: Capture updated score** (Original → Updated with delta)
6. Update Notion (with the updated Careersy score)

**CRITICAL: Steps 4-5 are NOT optional.** After compiling the PDF, you MUST immediately proceed to re-scoring. Do NOT say "done" or wait for user to remind you.

**Why Careersy first:**
- Your plan must be based on Careersy's ATS analysis and rewrite suggestions
- Do NOT write your own JD analysis - let Careersy guide the transformation
- Careersy provides expert keyword matching and positioning recommendations
- Skipping Careersy = guessing instead of using expert analysis

## Workflow Overview

Follow this checklist using TodoWrite to track progress:

1. **Scrape JD** - Navigate to job URL via Chrome and extract job description text
2. **Get ATS Analysis** - Send JD + resume to Careersy Wingman Ultra via ChatGPT
3. **Get Rewrite Suggestions** - Follow-up message for targeted recommendations
4. **Research Past Patterns** - Query claude-historian for similar transformations
5. **Create Folder Structure** - Set up dated customization folder
6. **Transform Resume** - Apply Careersy's suggestions + four-dimensional reframing
7. **Quality Check** - Grammar, Australian English, readability (elements-of-style)
8. **Compile & Verify** - Build PDF, ensure <4 pages
9. **Propose Notion Update** - Show changes including ChatGPT analysis
10. **Update Notion Tracking** - Execute approved MCP calls
11. **Update Skill with Learnings** - Capture new patterns, vocabulary, and workflow improvements


## Step-by-Step Implementation

The full claude-in-chrome automation runbook (Steps 0-10: JD extraction, Careersy upload, scoring, rewrite loop, folder init, PDF build) lives in `references/browser-runbook.md` — read it when executing, not when deciding. Notion/job-tracker sync: `references/notion-sync.md`.

## Resume
Path: /Users/v/Documents/cv/customized/[company]-[role]/[company]-[role]-[date]_vm_resume.pdf
(You'll upload the PDF embed yourself)

## ChatGPT Analysis (Careersy Wingman Ultra)

### ATS Score
[Score from Step 0c - e.g., "78% match"]

### Keyword Analysis
**Matches:** [keywords from resume that match JD]
**Gaps:** [keywords from JD missing from resume]

### Recommendations Applied
[Summary of which Careersy suggestions were implemented]

### Full Conversation Log
[Paste full CAREERSY_ANALYSIS.full_conversation text here]

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
[Full JD text - scraped from URL]

## Notes
(empty - you'll add your own notes)

**Confirm these changes before I update Notion?** [yes/no/modify]
```

### Step 8: Update Notion Tracking (After User Approval)

**Only execute after user confirms "yes"**

**IMPORTANT: Two-Step Pattern Required**

The Notion API requires creating the page first, then adding content blocks separately. The `children` parameter in `post_page` does not work reliably.

**Step 1: Create page with properties**

```typescript
const DATABASE_ID = "2c8b6eb0-ddc0-81f0-884e-e0de405d82ae";

await mcp__code-mode__call_tool_chain({
  code: `
    const result = await notion.notion_API_post_page({
      parent: {
        database_id: "${DATABASE_ID}"
      },
      properties: {
        "Job": { title: [{ text: { content: "[Company] - [Job Title]" } }] },
        "Company": { rich_text: [{ text: { content: "[Company]" } }] },
        "Role": { rich_text: [{ text: { content: "[Job Title]" } }] },
        "Status": { select: { name: "Review" } },
        "Reviewed (Eli)?": { checkbox: false },
        "Resume Customized?": { checkbox: true },
        "Added Date": { date: { start: "YYYY-MM-DD" } },
        "Job Posting": { url: "[URL]" },
        "Location": { rich_text: [{ text: { content: "[Location]" } }] },
        "Company Size": { select: { name: "[Startup/SMB/Enterprise]" } },
        "Work Style": { select: { name: "[Remote/Hybrid/Office]" } }
      }
    });
    console.log("Page ID:", result.id);
    return result;
  `
});
```

**Step 2: Add content blocks using page ID**

```typescript
await mcp__code-mode__call_tool_chain({
  code: `
    const PAGE_ID = "[page-id-from-step-1]";

    await notion.notion_API_patch_block_children({
      block_id: PAGE_ID,
      children: [
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Careersy ATS Analysis" } }] } },
        { object: "block", type: "paragraph", paragraph: { rich_text: [{ type: "text", text: { content: "Original: XX/100 → Updated: YY/100 (+Z points)" } }] } },
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Changes" } }] } },
        // ... bulleted_list_item entries with approved changes
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Resume" } }] } },
        { object: "block", type: "paragraph", paragraph: { rich_text: [{ type: "text", text: { content: "Path: ~/Documents/cv/customized/[company]-[role]/vm_resume.pdf" }, annotations: { code: true } }] } },
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Notes" } }] } },
        { object: "block", type: "paragraph", paragraph: { rich_text: [{ type: "text", text: { content: "(Add your notes here)" } }] } },
        { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Job Description" } }] } },
        { object: "block", type: "paragraph", paragraph: { rich_text: [{ type: "text", text: { content: "[Full JD text]" } }] } }
      ]
    });
  `
});
```

**Step 3: Open in Safari for review**

```bash
open -a Safari "https://www.notion.so/[page-url]"
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

1. **⚠️ FORGETTING TO RE-SCORE AFTER IMPLEMENTATION** - This is the #1 mistake. After compiling the PDF, you MUST immediately proceed to re-score with Careersy. Do NOT say "done" or wait for user to remind you. The workflow is: implement → compile → re-score → Notion.
2. **Saying "done" after PDF compilation** - PDF compilation is NOT the end. Re-scoring is mandatory before Notion.
3. **Starting a fresh Careersy session for re-scoring** - Keep the SAME conversation. The context is valuable.
4. **Creating new sections instead of editing** - Don't add new LaTeX sections/headers without asking user first. Blend into existing structure.
5. **Forgetting asset path fix** - Logo won't render, PDF compile fails
6. **Exceeding 4 pages** - Immediate ATS score reduction
7. **Losing technical credibility** - Don't remove all technical skills for sales/consulting roles
8. **Breaking LaTeX syntax** - Always test compile immediately after edits
9. **Not updating Notion** - Tracking gets out of sync
10. **Adding elements without explanation** - If you need to add a new subsection, interest, or row, explain WHY in detail first and get approval

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


## Skill Learnings

After each run, evaluate skill evolution via `improve-claude evolve` (quality gates + versioning live there — this section previously duplicated that skill).

## Reference

**Master resume location:** `/Users/v/Documents/cv/resume.tex`

**Customized resumes location:** `/Users/v/Documents/cv/customized/[company]-[role]/`

**Notion database:** https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c

**Notion database_id (for API):** `2c8b6eb0-ddc0-81f0-884e-e0de405d82ae`

**README workflow:** `/Users/v/Documents/cv/customized/README.md`

**Claude-mem queries:** Search for similar past transformations before starting new customization
