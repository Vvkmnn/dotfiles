---
name: customize-resume
author: Vvkmnn
description: This skill should be used when the user provides a "job posting URL", "job description", "resume customization request", or asks to "customize my resume", "adapt resume for", "create tailored resume", or mentions updating Notion job tracking. Guides end-to-end resume customization workflow with automated ATS analysis via Careersy Wingman Ultra GPT, 4-page enforcement, claude-historian research, referral strategy, role mismatch detection, and Notion integration via code-mode.
version: 1.0.0
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

### Step 0: Automated ATS Analysis via Careersy Wingman Ultra

**Configuration:**
```
CAREERSY_GPT_URL = "https://chatgpt.com/g/g-68593fdaef408191a400e5f06cfcfbd6-careersy-wingman-ultra"
MASTER_RESUME_PATH = "/Users/v/Documents/cv/resume.tex"
```

**Prerequisites Check:**
1. Verify Claude Code launched with `--chrome` flag
2. If not, inform user: "This workflow requires browser access. Please restart with `claude --chrome`"

#### Step 0a: Scrape Job Description

```
# Get browser tab context
mcp__claude-in-chrome__tabs_context_mcp(createIfEmpty=true)

# Create new tab for job posting
mcp__claude-in-chrome__tabs_create_mcp()

# Navigate to job posting URL
mcp__claude-in-chrome__navigate(url=JOB_POSTING_URL, tabId=TAB_ID)

# Wait for page load
mcp__claude-in-chrome__computer(action="wait", duration=3, tabId=TAB_ID)

# Extract job description text
mcp__claude-in-chrome__get_page_text(tabId=TAB_ID)

# Store JD text for later use
JD_TEXT = [extracted text]
```

**If scraping fails (e.g., login wall):**
- Take screenshot for user reference
- Ask user to manually paste JD text
- Continue with manual JD

#### Step 0b: Navigate to Careersy GPT (Fresh Session)

**IMPORTANT:** Always start a **fresh Careersy session** for each new job. Do NOT reuse a conversation from a previous job - the context would be polluted with different JD/resume analysis.

```
# Navigate to Careersy Wingman Ultra BASE URL (not an existing conversation)
# This starts a fresh chat session
mcp__claude-in-chrome__navigate(url=CAREERSY_GPT_URL, tabId=TAB_ID)

# Wait for GPT to load
mcp__claude-in-chrome__computer(action="wait", duration=5, tabId=TAB_ID)

# Take screenshot to verify GPT loaded
mcp__claude-in-chrome__computer(action="screenshot", tabId=TAB_ID)
```

**If ChatGPT not logged in:**
- Inform user: "Please log into ChatGPT in the browser window, then tell me to continue"
- Wait for user confirmation
- Retry navigation

#### Step 0c: Upload Resume PDF (Manual Selection Required)

**IMPORTANT:** Native macOS file dialogs cannot be automated reliably. Ask the user to select the file.

```
# Click the "+" button to open file upload menu
mcp__claude-in-chrome__computer(action="left_click", coordinate=[PLUS_BUTTON_COORDS], tabId=TAB_ID)

# Click "Add photos & files"
mcp__claude-in-chrome__computer(action="left_click", coordinate=[ADD_FILES_COORDS], tabId=TAB_ID)

# ASK USER TO SELECT FILE
# The native macOS file dialog will open - automation cannot control it
# Tell user: "Please select resume.pdf from /Users/v/Documents/cv/ and click Open"
# Wait for user confirmation that file is uploaded
```

**User prompt:**
```
"The file picker is open. Please navigate to /Users/v/Documents/cv/ and select resume.pdf, then click Open. Tell me when done."
```

#### Step 0d: Send JD for Scoring (Message 1)

After resume is uploaded, paste the JD and request scoring:

```
# Click chat input field
mcp__claude-in-chrome__find(query="chat input field or message box", tabId=TAB_ID)
mcp__claude-in-chrome__computer(action="left_click", ref=INPUT_REF, tabId=TAB_ID)

# Type the scoring prompt with JD only (resume already uploaded)
SCORING_PROMPT = """Score and match my resume against this JD:

=== JOB DESCRIPTION ===
[JD_TEXT - full job description scraped from posting]

=== JOB URL ===
[JOB_URL]
"""

mcp__claude-in-chrome__computer(action="type", text=SCORING_PROMPT, tabId=TAB_ID)

# Submit message (press Enter or click send)
mcp__claude-in-chrome__computer(action="key", text="Return", tabId=TAB_ID)

# Wait for response (ChatGPT can take 30-60s)
mcp__claude-in-chrome__computer(action="wait", duration=45, tabId=TAB_ID)

# Read the response
mcp__claude-in-chrome__get_page_text(tabId=TAB_ID)

# Extract from response:
# - ATS score/match percentage
# - Keyword matches
# - Gaps identified
# - Initial recommendations
```

#### Step 0e: Ask for Targeted Rewrites (Message 2)

```
# Type follow-up question in same conversation
REWRITE_PROMPT = """Based on this analysis, suggest specific targeted rewrites for:
1. Header/tagline positioning
2. Summary bullets (which ones to change and how)
3. Experience bullet modifications (specific company, specific changes)
4. Skills section reorganization"""

mcp__claude-in-chrome__computer(action="type", text=REWRITE_PROMPT, tabId=TAB_ID)
mcp__claude-in-chrome__computer(action="key", text="Return", tabId=TAB_ID)

# Wait for response
mcp__claude-in-chrome__computer(action="wait", duration=45, tabId=TAB_ID)

# Read the rewrite suggestions
mcp__claude-in-chrome__get_page_text(tabId=TAB_ID)
```

#### Step 0f: Capture Full Analysis

Store both ChatGPT responses for:
1. Guiding the transformation (Step 4)
2. Including in Notion notes (Step 8)

```
CAREERSY_ANALYSIS = {
  "ats_score": [extracted score],
  "keyword_matches": [list],
  "gaps": [list],
  "positioning_recommendation": [text],
  "header_suggestion": [text],
  "summary_rewrites": [list of specific changes],
  "experience_rewrites": [list by company],
  "skills_reorganization": [text],
  "full_conversation": [raw text for Notion]
}
```

**Fallback if ChatGPT automation fails:**
- Take screenshot of error
- Inform user of failure
- Offer: "Would you like to manually run Careersy and paste the analysis?"
- If yes, accept manual paste and continue
- If no, skip ATS analysis and proceed with claude-historian patterns only

---

### Implementation Notes (From Testing - 2026-02-02)

#### ChatGPT Input Challenges

**Problem:** ChatGPT uses a `contenteditable` div, not a standard textarea. The `type` action with multi-line text causes premature submission (newlines trigger Enter).

**Solution:** Use JavaScript DOM manipulation instead:
```javascript
mcp__claude-in-chrome__javascript_tool({
  action: "javascript_exec",
  text: `
    const textarea = document.querySelector('#prompt-textarea') || document.querySelector('[contenteditable="true"]');
    textarea.innerText = YOUR_TEXT_HERE;
    textarea.dispatchEvent(new Event('input', { bubbles: true }));
  `,
  tabId: TAB_ID
})
```

#### Recommended Order of Operations

**Critical:** Set JD text FIRST, then ask user to upload resume PDF. This ensures:
1. User sees the prompt context when attaching file
2. Both JD and resume submit together in one message
3. Avoids the "resume without JD" scoring error

**Workflow:**
1. Navigate to Careersy GPT
2. Use JavaScript to set scoring prompt + full JD in input
3. Ask user to click "+" button and attach resume.pdf
4. Wait for user confirmation
5. Click send button

#### Careersy Commands

After initial scoring, use Careersy's built-in `/rewrite` command (not a custom prompt):
```
/rewrite
```

This triggers Careersy's structured rewrite output with:
- Profile Summary (role-specific)
- Top Experience Bullets (ATS / Hiring Manager / Short versions)
- What We Fixed summary

#### Browser Extension Handling

**Disconnection:** Extension may disconnect during long waits. Handle with:
```
mcp__claude-in-chrome__tabs_context_mcp({ createIfEmpty: false })
```
Then retry the action.

**Rating popup:** ChatGPT may show a rating popup mid-response. Click the X to dismiss before continuing.

#### Capturing Full Analysis

Use `get_page_text` to capture complete Careersy analysis (more reliable than screenshots):
```
mcp__claude-in-chrome__get_page_text({ tabId: TAB_ID })
```

Captures: ATS score breakdown, keyword analysis, specific rewrite suggestions, full conversation for Notion.

#### Re-Scoring After Resume Updates (Tested 2026-02-02)

After making resume changes based on Careersy recommendations, re-score to verify improvements:

**Workflow:**
1. **Keep Careersy conversation open** - Don't navigate away from the existing chat
2. **Click "+" button** → "Add photos & files" to open file picker
3. **User selects updated PDF** from `customized/[company]-[role]/` folder
4. **Type re-scoring prompt:**
   ```
   Here's the updated resume with all the changes we discussed. Please re-score it against the [Role] @ [Company] role and let me know the new score vs the original [X]/100.
   ```
5. **Submit and wait** for Careersy response
6. **Capture score breakdown** - Original vs Updated for each category

**Expected Output:**
- RE-SCORE SUMMARY: Original → Updated score with delta
- Score breakdown by category (Hard Skills, Domain Fit, Execution, Leadership, Communication)
- "What Specifically Improved" analysis
- Remaining gaps and optional improvements
- Market positioning (e.g., "Top 2-3% for this role")

**Example (OpenAI AI Deployment Engineer - 2026-02-02):**
- Original: 92/100 → Updated: 96/100 (+4 points)
- Hard Skills: 38→39, Domain Fit: 19→20, Execution: 19→20, Leadership: 9→10
- Careersy verdict: "You've already done the hard part. Now it's about conversion, not credibility."

**Example (PHD Senior Digital Director - 2026-02-02):**
- Original: 61/100 → Round 1: 82/100 → Final: 90-92/100 (expected)
- Key insight: "This person is brilliant… but are they a digital agency leader or a principal technologist?"
- Required 2 rounds of `/rewrite` to reach 90+ target

#### Iterative 90+ Scoring Workflow (MANDATORY)

**Target: 90+ ATS score before applying.** If initial score is below 90, iterate:

1. **Score < 90?** → Request `/rewrite` from Careersy
2. **Apply Careersy's change sets** to resume (usually 3-5 specific bullet rewrites)
3. **Recompile PDF** with `xelatex -jobname=vm_resume`
4. **Re-score** by uploading updated PDF to same Careersy conversation
5. **Repeat** steps 1-4 until 90+ achieved

**Typical progression:**
- Round 1: Initial → 75-85 (major positioning changes)
- Round 2: 85 → 90+ (vocabulary refinements, MFA/training callouts, strategic oversight)

**When to stop iterating:**
- Score reaches 90+ → proceed to application
- Careersy says "diminishing returns" or "top 2-3% positioning"
- 3+ rounds with <2 point improvement per round

**Example (Enterprise Data Leadership role - 2026-02-02):**
- Original: 82/100 (Hard Skills: 90%, Leadership: 85%, Domain Fit: 70%)
- Key insight: "This person is elite technically. Do they understand our business, or will they try to turn us into a Silicon Valley lab?"
- Gap: Industry-specific domain experience not present
- Fix: Reframe as "Enterprise Data Leader" not "AI Engineer" - governance, self-service analytics, ethical AI

#### Streamlined Re-Score Workflow (Plan Already Exists)

When the plan has already been created and user has Careersy conversation from initial scoring:

1. **Reuse existing Careersy conversation** - Don't start fresh, the context is valuable
2. **Prepare input but let user upload** - Type the re-score request, then tell user to attach the PDF
3. **Tell user when ready:**
   ```
   Ready for your upload.

   Your next steps:
   1. Click the + button (bottom-left of input field) to attach a file
   2. Navigate to: Documents/cv/customized/[company]-[role]/
   3. Select: [company]-[role]-[date]_vm_resume.pdf
   4. Click the send arrow (bottom-right)

   Let me know when Careersy returns the new score and I'll analyse the results.
   ```
4. **Wait for user** to confirm application submitted
5. **Only then update Notion** with Applied status and Applied Date

#### Browser Tab Management

**Session Scope:**
- **New job = Fresh Careersy session** - Always navigate to base GPT URL, not an existing conversation
- **Within same job = Keep session open** - For re-scoring after resume updates, stay in the same chat

**During a single job workflow, preserve:**
- **Careersy chat tab** - Contains conversation history for re-scoring
- **Job posting tab** - Reference for JD details

**If tab gets reset during a job:**
1. Click "See more" in ChatGPT sidebar
2. Find the conversation by name (e.g., "Resume Match AI Engineer")
3. Click to restore

**Starting a new job:**
- Navigate to `CAREERSY_GPT_URL` (base URL) to start fresh
- Do NOT restore a previous job's conversation

---

### Step 1: Research Past Transformations

**Before making any resume changes, research similar past work:**

Query claude-historian for relevant patterns:

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
Found 3 similar consulting transformations in claude-historian:
- Quantium: "AI Engineering Lead" → "AI Delivery Lead", added "Consulting & Delivery" skills
- Macquarie: "Technical Lead" → "AI Strategy & Transformation Leader", advisory tagline
- Notion: "Technical Lead" → "Technical Consulting Leader", PS/GTM tagline

Use these patterns as starting point? [yes/no/modify]
```

### Step 1b: Identify Application Strategy

**Determine application method:**

1. **Referral** (preferred): User has contact at company
   - Extract specific Job ID from posting (for ATS connection)
   - Prepare referral message (see guidelines below)
   - Include resume in initial outreach for warm contacts
   - Track referrer in Notion

2. **Direct**: No internal contact
   - Standard application through careers portal
   - Job ID still important for tracking

**Referral Message Guidelines (from Eli's coaching - Dec 2025):**

| Do | Don't |
|----|-------|
| ✅ Reference specific Job ID for ATS connection | ❌ Mention visa status upfront |
| ✅ Mention enjoying interactions but actively job hunting | ❌ Say "almost legal" or similar |
| ✅ Use "time zones not ideal" narrative if needed | ❌ Lead with immigration situation |
| ✅ Include resume immediately for warm contacts | ❌ Wait to send resume later |
| ✅ Be transparent about job hunting | ❌ Be vague about intentions |

**Example referral message structure:**
```
Hi [Name],

Great seeing you at [event/meeting]. I'm actively exploring new opportunities
and noticed [Company] has a [Role] opening (Job ID: [XXX]).

Given [reason - e.g., "the time zones with my current role aren't ideal"],
I'm looking for something based in [location]. Would you be open to referring
me? I've attached my resume.

[Your name]
```

---

### Step 2: Parse Inputs and Set Up TodoWrite

Create todos for the complete workflow:

```
- Research past transformations in claude-historian
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

**Query claude-historian for similar work:**

Search for: `"resume customization [role-type] positioning transformation"`

**Common transformation patterns found:**

| From → To | Header Change | Tagline Shift | Example |
|-----------|---------------|---------------|---------|
| Technical → Consulting | "AI Engineering Lead" → "AI Delivery Lead" | "ML - Cloud - Orchestration" → "End-to-End Delivery - C-Suite Advisory" | Quantium, Macquarie |
| Technical → Sales | "Principal AI Engineer" → "AI Solutions Leader" | Technical stacks → "Land-and-Expand - Value-Based - Executive Engagement" | Microsoft Partner, AI Workforce |
| Technical → Professional Services | "Technical Lead" → "Technical Consulting Leader" | "Data Science - ML" → "Professional Services - Customer Adoption - GTM" | Notion PS Consultant |
| Technical → Revenue/Monetization | "Technical Lead" → "Ads Strategy & Programmatic Monetization Leader" | "ML - Data Science - Cloud" → "Revenue Analytics - Yield Optimization - Market Strategy" | Netflix Manager |
| Technical → Staff Technical | "Technical Lead" → "Staff AI Engineer & Technical Lead" (JD title first) | "ML - Data Science - Cloud" → "LLM Orchestration - Retrieval & Ranking - Production AI" | Heidi Staff AI Engineer |
| Technical → Enterprise Data Leadership | "Technical Lead & Principal AI Engineer" → "Head of Data & AI" | "ML - Data Science - Cloud - Agent Orchestration" → "Enterprise Data Platforms - AI Governance - Self-Service Analytics - Ethical AI" | Real Estate/Infrastructure Enterprise |
| Technical → Deployment Strategist | "Principal AI Engineer" → "Deployment Strategist · Field Product Leader" | "ML - Data Science - Cloud" → "Value Scoping - MVP Definition - Executive Discovery - AI & Data Platforms" | Databricks DS |
| Technical → AI Deployment Strategy | "Technical Lead & Principal AI Engineer" → "AI Deployment & Strategy Leader" | "ML - Data Science - Cloud - Agent Orchestration" → "Executive Discovery - Proofs-of-Value - AI Roadmaps - Production Deployment" | Mistral AI Deployment Strategist |
| Technical → Digital Agency Director | "Technical Lead & Principal AI Engineer" → "Senior Digital & Media Transformation Director" | "ML - Data Science - Cloud - Agent Orchestration" → "Digital Maturity - AdTech & MarTech - Data Strategy - Enterprise Clients" | PHD (OMG) Senior Digital Director |

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

### Step 3b: Role Level Assessment

**Check for qualification mismatch before transforming:**

Compare user's current/recent titles with JD level:

| User Titles | JD Level | Assessment |
|-------------|----------|------------|
| Principal AI Engineer, AI Engineering Lead | Senior Data Scientist | ⚠️ Potential overqualification - may be seen as "will leave for better role" |
| Technical Lead | Staff Engineer | ✅ Appropriate match |
| Director-level experience | Individual Contributor | ⚠️ May be seen as flight risk or salary mismatch |
| Senior titles | Mid-level role | ⚠️ Recruiter may assume salary expectations too high |

**If mismatch detected:**

1. Flag to user with specific concern:
   ```
   "Your titles (Principal AI Engineer, AI Engineering Lead) suggest seniority
   beyond this Senior Data Scientist role. Recruiters may:
   - Assume salary expectations don't match
   - Worry you'll leave for a more senior role
   - Question why you're 'stepping down'"
   ```

2. Suggest adjacent roles at same company:
   - Solutions Architect (bridges technical + client-facing)
   - Technical Consulting Lead
   - Sales/Success Engineering
   - Manager-level positions
   - Staff+ technical roles

3. Ask: "Proceed with customization, or explore alternatives at [Company]?"

**Why this matters (from Eli's coaching):**
- Recruiters scan for level fit quickly
- Overqualification can lead to automatic rejection
- Sometimes the "perfect fit" role is adjacent to what user found

---

### Step 4: Four-Dimensional Transformation

#### Using Careersy Analysis (from Step 0)

Before applying transformations, review the `CAREERSY_ANALYSIS`:

1. **Header/Title**: Apply Careersy's positioning recommendation
   - If suggests "consulting positioning" → use consulting header pattern
   - If suggests "technical depth" → maintain technical header

2. **Summary**: Implement Careersy's specific rewrite suggestions
   - Replace bullets exactly as suggested where it makes sense
   - Preserve authenticity - don't claim skills we don't have

3. **Skills**: Follow Careersy's reorganization advice
   - Move categories as suggested
   - Add keywords identified as gaps (if authentic)

4. **Experience**: Apply company-specific changes
   - Modify bullets per Careersy's suggestions
   - Emphasize keywords from gap analysis

---

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
xelatex -jobname=vm_resume [company]-[job-title]-[date]_vm_resume.tex
```

**Output:** The `-jobname=vm_resume` flag produces `vm_resume.pdf` for easy sharing/upload, while keeping the `.tex` file with the decorated name for version tracking.

**IMPORTANT:** Use `xelatex` (not `pdflatex`). The master resume uses `fontspec` and custom font features that require XeLaTeX.

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

### Step 6b: Pre-Application Review Checkpoint

**Before applying, review checklist:**

- [ ] **Eli review completed** (if time permits) - use "Eli Reviewed" checkbox in Notion
- [ ] **Referrer message reviewed** (if referral application)
- [ ] **No visa mention** in any outreach materials
- [ ] **Job ID captured** from posting for ATS tracking
- [ ] **Resume compiled** successfully (<4 pages)

**Review workflow:**
1. Send customized resume to Eli for feedback
2. Wait for review (track via "Eli Reviewed" checkbox)
3. Make any requested adjustments
4. Only then proceed to apply

**If time is critical:**
- Note in Notion that Eli review was skipped due to timing
- Apply anyway, but flag for future reference

---

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

#### Step 7b: Determine Application Status

**Status selection depends on user's application state:**

| User Says | Status | Applied Date |
|-----------|--------|--------------|
| "I applied" / "already submitted" / "just applied" | Applied | Today's date |
| "Ready for review" / "customization complete" | Review | (not set) |
| No indication yet | Review | (not set) |

**Key principle:** If user confirms they've already applied via the company portal, set Status to "Applied" with Applied Date. Don't default to "Review" when application is already submitted.

**Listen for signals:**
- "I submitted it" → Applied
- "uploaded and applied" → Applied
- "just applied, do Notion" → Applied
- "ready for Eli to review" → Review
- No explicit mention → Review (default)

#### Step 7c: Prepare Detailed Changes Documentation

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
- Job ID: [JOB-12345 or "Not found"]
- Status: Review
- Customized Resume: true
- Date Customizing Started: [Today's date - YYYY-MM-DD]
- Job Posting: [URL]
- Location: [City, State or Remote]
- Company Size: [Startup/SMB/Enterprise] (based on [research source])
- Work Style: [Remote/Hybrid/Office] (based on [JD or website])

**Page Body:**

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

## Notion Integration

### Creating Job Application Entries

Use code-mode to create entries and add content:

```typescript
// Step 1: Create the page with properties
const DATABASE_ID = "2c8b6eb0-ddc0-81f0-884e-e0de405d82ae";

const page = await notion.notion_API_post_page({
  parent: { database_id: DATABASE_ID },
  properties: {
    "Job": { title: [{ text: { content: "Company - Role Title" } }] },
    "Company": { rich_text: [{ text: { content: "Company" } }] },
    "Role": { rich_text: [{ text: { content: "Role description" } }] },
    "Status": { select: { name: "Applied" } },
    "Fit": { number: 96 },  // Careersy ATS score
    "Company Size": { select: { name: "Enterprise" } },
    "Work Style": { select: { name: "Hybrid" } },
    "Location": { rich_text: [{ text: { content: "Sydney, Australia" } }] },
    "Job Posting": { url: "https://..." },
    "Applied Date": { date: { start: "2026-02-02" } },
    "Added Date": { date: { start: "2026-02-02" } },
    "Resume Customized?": { checkbox: true }
  }
});

// Step 2: Add content blocks (notes, analysis, etc.)
await notion.notion_API_patch_block_children({
  block_id: page.id,
  children: [
    { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Careersy ATS Analysis" } }] } },
    { object: "block", type: "paragraph", paragraph: { rich_text: [{ type: "text", text: { content: "Original: 92 → Updated: 96 (+4 points)" } }] } },
    { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Key Changes Made" } }] } },
    { object: "block", type: "bulleted_list_item", bulleted_list_item: { rich_text: [{ type: "text", text: { content: "Header: Old Title → New Title" } }] } },
    { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Resume" } }] } },
    { object: "block", type: "paragraph", paragraph: { rich_text: [{ type: "text", text: { content: "Path: ~/Documents/cv/customized/[folder]/[file].pdf" }, annotations: { code: true } }] } },
    { object: "block", type: "heading_2", heading_2: { rich_text: [{ type: "text", text: { content: "Notes" } }] } },
    { object: "block", type: "bulleted_list_item", bulleted_list_item: { rich_text: [{ type: "text", text: { content: "Applied via [portal] on [date]" } }] } }
  ]
});
```

### Required Notion Content Structure

Each job entry should include these sections (in order):

1. **Careersy ATS Analysis**
   - Original → Updated score with delta (e.g., "92/100 → 96/100 (+4 points)")
   - Resume strength positioning (e.g., "Top 2-3% for this role")
   - Score breakdown by category:
     - Hard Skills & Technical Depth (40%)
     - Domain / Context Fit (20%)
     - Execution & Delivery (20%)
     - Leadership & Collaboration (10%)
     - Communication & Relevance (10%)

2. **Key Changes Made** (bullet list)
   - Header transformation (old → new)
   - Tagline transformation (old → new)
   - Summary rewrites and emphasis
   - Experience bullet reframes by company
   - Skills section reorganization
   - Tech stack additions

3. **Resume**
   - Path to customized PDF (code formatted)
   - User can add PDF embed manually

4. **Notes** (bullet list)
   - Application date and portal used
   - Work style details (hybrid days, location)
   - Careersy verdict quote
   - Remaining optimization opportunities
   - Any tracking changes (email, referral, etc.)

5. **Job Description**
   - Full JD text for reference

---

## Step 11: Update Skill with Learnings

**After completing each resume customization, review what worked and update this skill.**

This step makes the skill self-improving. Each customization teaches something new - capture it.

### What to Capture

**New transformation patterns:**
- Add to the "Common transformation patterns" table in Step 3
- Format: `| From → To | Header Change | Tagline Shift | Example |`
- Example: `| Technical → Deployment Strategist | "Principal AI Engineer" → "Deployment Strategist · Field Product Leader" | ... | Databricks DS |`

**New positioning vocabulary:**
- Deployment Strategist language: "value scoping", "MVP pilots", "PRD authoring", "escalation manager"
- Sales language: "land-and-expand", "quota attainment", "pipeline growth"
- Consulting language: "trusted advisor", "C-suite partnership", "transformation engagements"
- Digital Agency Director language: "industry-leading digital media strategies", "benchmarking client capabilities", "strategic oversight to implementation teams", "MFA (Made For Advertising)", "platform enablement", "media-quality best practices"

**Workflow improvements:**
- Browser automation fixes (e.g., JavaScript DOM manipulation for ChatGPT input)
- Extension disconnection recovery patterns
- Re-scoring workflow refinements

**Status flow learnings:**
- When user says "already applied" → use Applied status
- Edge cases in status determination

### How to Update

1. **Identify the learning** - What worked well? What was missing from the skill?
2. **Find the right section** - Where does this learning belong?
3. **Make surgical edits** - Add to existing patterns, don't create new sections
4. **Bump version** - Increment patch version (0.7.0 → 0.8.0)
5. **Test on next job** - Verify the update helps

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-03 | **CRITICAL:** Added mandatory Careersy workflow section at top, explicit post-implementation re-score requirements, updated Common Pitfalls to emphasize re-scoring is #1 mistake. Fixed issue where implementation was completed without automatic re-scoring. |
| 0.9.0 | 2026-02-02 | Added Digital Agency Director pattern (PHD OMG), iterative 90+ scoring workflow (request /rewrite until 90+), MFA/media-quality vocabulary |
| 0.8.0 | 2026-02-02 | Added Deployment Strategist pattern (Databricks), status flow clarification, self-improvement step |
| 0.7.0 | 2026-02-02 | Browser automation notes, re-scoring workflow, extension handling |
| 0.6.0 | 2026-01-xx | Initial Careersy integration |

---

## Reference

**Master resume location:** `/Users/v/Documents/cv/resume.tex`

**Customized resumes location:** `/Users/v/Documents/cv/customized/[company]-[role]/`

**Notion database:** https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c

**Notion database_id (for API):** `2c8b6eb0-ddc0-81f0-884e-e0de405d82ae`

**README workflow:** `/Users/v/Documents/cv/customized/README.md`

**Claude-mem queries:** Search for similar past transformations before starting new customization
