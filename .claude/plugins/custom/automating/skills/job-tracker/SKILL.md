---
name: job-tracker
description: This skill should be used when the user asks to "add job to Notion", "track this job", "add these jobs" (batch), "find [company] in my tracker", "check my job pipeline", "are my saved jobs still open", or provides a job description/URL without a Notion link. Manages Notion job application database with search, creation, batch additions, and pipeline health checks.
version: 0.1.0
---

# Job Tracker - Notion Database Management

## Purpose

Manage the Notion job applications database at https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c. Handles job discovery, tracking, batch additions, and pipeline health monitoring.

## When to Use

Use this skill when the user:
- Provides a job posting URL or description without a Notion link
- Asks to add job(s) to their tracker
- Wants to find an existing job entry
- Wants to check if saved jobs are still open

## Four Operating Modes

### Mode 1: Single Job Addition

**Trigger:** User provides one job URL or pasted JD

**Workflow:**
1. Parse input (URL or text)
2. If URL → Use WebFetch to get job description content
3. Extract from JD:
   - **Company name** (extract from posting)
   - **Role title** (extract job title)
   - **Location** (city/state or "Remote")
   - **Work Style** (Remote/Hybrid/Office - look for keywords)
4. Research **Company Size:**
   - **Startup**: Early-stage, high-growth (<500 employees, rapid scaling)
   - **SMB**: Small-to-medium (500-5000 employees, examples: Canva, Zip, Prophet, OpenAI)
   - **Enterprise**: Large corporations (5000+ employees, examples: Microsoft, Amazon, PwC, Macquarie)
5. Search Notion database for existing entry:
   ```typescript
   const DATABASE_ID = "2c8b6eb0-ddc0-81f0-884e-e0de405d82ae";
   // Query by Company name and Role title
   ```
6. If found → Show match, ask: "Found existing entry for [Company] [Role]. Update it or create new?"
7. If not found → Show proposed entry (see User Approval section)
8. After user approves → Create entry with Status = "Considering"
9. Ask: "Want to customize resume for this role now?" → If yes, invoke `writing:resume-customization`

### Mode 2: Batch Job Addition

**Trigger:** User provides multiple job URLs at once

**Workflow:**
1. Parse all URLs/JDs from input
2. For each job:
   - Fetch JD content if URL
   - Extract Company, Role, Location, Work Style
   - Research Company Size
   - Check Notion for duplicates
3. Show summary table:
   ```
   Adding 5 jobs to tracker:

   | Company | Role | Location | Size | Duplicate? |
   |---------|------|----------|------|------------|
   | Netflix | Senior AI Eng | Los Gatos | Enterprise | No |
   | Canva | ML Lead | Sydney | SMB | No |
   | Meta | AI Solutions | Remote | Enterprise | Yes (existing) |
   | ... | ... | ... | ... | ... |

   Notes:
   - Meta AI Solutions already exists in tracker (skip)
   - Will create 4 new entries

   Proceed? [yes/no/review individually]
   ```
4. After user approves → Create all new entries with Status = "Considering"
5. Report: "✅ Added 4 jobs to pipeline. Skipped 1 duplicate."

### Mode 3: Search/Find

**Trigger:** "Find [company] [role] in my tracker"

**Workflow:**
1. Search Notion database by keywords (company name, role title)
2. If multiple matches → Show list with key details:
   ```
   Found 3 matches for "Netflix AI":

   1. Netflix - Senior AI Engineer (Los Gatos, Applied 2024-12-10)
   2. Netflix - AI Solutions Architect (Remote, Considering)
   3. Netflix - ML Lead (Los Gatos, Interview)

   Which one? [1/2/3/none - create new]
   ```
3. If single match → Confirm: "Found: [Company] - [Role]. Use this entry?"
4. If no matches → "No matches found. Create new entry for [query]?"

### Mode 4: Pipeline Health Check

**Trigger:** "Check my pipeline", "Are saved jobs still open?", "Clean up old jobs"

**Workflow:**
1. Query Notion for all jobs with Status = "Considering"
2. For each job:
   - Fetch Job Posting URL via WebFetch
   - Check if page exists (404 = closed)
   - Look for closure indicators:
     - "no longer accepting applications"
     - "position filled"
     - "closed"
     - "applications have closed"
     - Date in past with "deadline" or "closes"
3. Categorize results:
   ```
   Pipeline Health Check Results:

   ✅ Still Open (12 jobs):
   - Netflix Senior AI Engineer
   - Canva ML Lead
   - Quantium Lead AI Client Solutions
   [... list continues]

   ❌ No Longer Available (3 jobs):
   - Meta Solutions Manager (page returns 404)
   - Amazon Strategy Lead (posting says "applications closed Dec 1")
   - Google AI Researcher (posting says "position filled")

   Move 3 unavailable jobs to "Unavailable" status? [yes/no/review each]
   ```
4. After user confirms → For each closed job:
   a. Update Status to "Unavailable"
   b. **Add closure reason to Notes section:**
      ```
      ## Notes
      Job posting closed on 2024-12-16 (automated health check)
      Reason: Page returned 404
      ```
      OR
      ```
      ## Notes
      Job posting closed on 2024-12-16 (automated health check)
      Reason: Posting says "applications closed Dec 1, 2024"
      ```

**How to add to Notes section:**
- Read existing page content to preserve any user notes
- Append closure info to existing Notes section
- Use Notion API to update page body with appended content

## Notion Database Constants

```typescript
const DATABASE_ID = "2c8b6eb0-ddc0-81f0-884e-e0de405d82ae";
const DATABASE_URL = "https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c";
```

## User Approval Guardrail

**CRITICAL: Always show proposed changes and get user approval before ANY Notion MCP calls.**

### Single Job Template

```
Adding job to tracker:

**Company:** [Company Name]
**Role:** [Job Title]
**Location:** [City, State or Remote]
**Company Size:** [Startup/SMB/Enterprise] (based on [employee count/research])
**Work Style:** [Remote/Hybrid/Office] (based on JD wording)
**Job Posting:** [URL]
**Status:** Considering
**Added Date:** 2024-12-16

Create this entry? [yes/no/modify]
```

### Batch Jobs Template

```
Adding [N] jobs to tracker:

| Company | Role | Location | Size | Work Style |
|---------|------|----------|------|------------|
| Netflix | Senior AI Eng | Los Gatos | Enterprise | Hybrid |
| Canva | ML Lead | Sydney | SMB | Hybrid |
| ... | ... | ... | ... | ... |

All entries will have:
- Status: Considering
- Added Date: 2024-12-16
- Job Description: Full JD text in page body

Create all [N] entries? [yes/no/review individually]
```

### Pipeline Health Update Template

```
Updating [N] jobs to "Unavailable" with closure reasons:

1. Meta Solutions Manager
   - Status: Considering → Unavailable
   - Reason: Page returned 404
   - Notes: Will add "Job posting closed on 2024-12-16 (automated health check). Reason: Page returned 404"

2. Amazon Strategy Lead
   - Status: Considering → Unavailable
   - Reason: Posting says "applications closed Dec 1, 2024"
   - Notes: Will add "Job posting closed on 2024-12-16 (automated health check). Reason: applications closed Dec 1, 2024"

Update these [N] entries? [yes/no/review each]
```

## Notion Entry Structure

**Properties to set:**
```typescript
{
  "Company": { title: [{ text: { content: "Company Name" } }] },
  "Role": { rich_text: [{ text: { content: "Job Title" } }] },
  "Status": { select: { name: "Considering" } },
  "Eli Reviewed": { checkbox: false },
  "Customized Resume": { checkbox: false },
  "Added Date": { date: { start: "YYYY-MM-DD" } },
  "Job Posting": { url: "https://..." },
  "Location": { rich_text: [{ text: { content: "Sydney, AUS" } }] },
  "Company Size": { select: { name: "Enterprise" } },
  "Work Style": { select: { name: "Hybrid" } }
}
```

**Page body to create:**
```typescript
children: [
  { type: "heading_2", heading_2: { rich_text: [{ text: { content: "Resume" } }] } },
  { type: "paragraph", paragraph: { rich_text: [{ text: { content: "(No customized resume yet)" } }] } },
  { type: "heading_2", heading_2: { rich_text: [{ text: { content: "Job Description" } }] } },
  { type: "paragraph", paragraph: { rich_text: [{ text: { content: "[Full JD text from WebFetch]" } }] } },
  { type: "heading_2", heading_2: { rich_text: [{ text: { content: "Notes" } }] } },
  { type: "paragraph", paragraph: { rich_text: [{ text: { content: "" } }] } }
]
```

## Status Options

**Current statuses:**
- **Applied** - Submitted, awaiting response
- **In Progress** - Active engagement
- **Interview** - Interview stage
- **Offer** - Received offer
- **Rejected** - Not proceeding
- **Considering** - Pipeline role, not yet applied (default for this skill)
- **Review** - Resume customized, ready to apply
- **Unavailable** - Job posting closed/expired (NEW - needs to be added to Notion database)

**⚠️ User Action Required:** Add "Unavailable" status option to Notion database Status select field before using Mode 4.

## Integration with resume-customization

After successfully creating a job entry, ask:
```
✅ Job added to tracker: [Company] - [Role]

Want to customize your resume for this role now? [yes/no]
```

If yes → Invoke `writing:resume-customization` skill with:
- JD text (already fetched)
- Notion page ID (just created)
- Company and Role (extracted)

## Extracting Information from Job Descriptions

**Company name:**
- Look for "About [Company]" sections
- Check meta tags or page title
- Extract from URL domain (e.g., netflix.com → Netflix)

**Role title:**
- Usually in `<h1>` or page title
- Look for "Position:", "Role:", "Job Title:"

**Location:**
- Look for "Location:", "Office:", "Based in:"
- Check for "Remote", "Hybrid", "On-site" keywords
- If multiple locations listed, use primary or "Multiple locations"

**Work Style (Remote/Hybrid/Office):**
- **Remote**: "fully remote", "work from anywhere", "remote-first"
- **Hybrid**: "hybrid", "flexible", "2-3 days in office"
- **Office**: "on-site", "in-person", "office-based", no remote mention

**Company Size (Startup/SMB/Enterprise):**
- Research via WebSearch if not obvious
- Look for employee count on company website
- Check LinkedIn company page
- Use known examples as reference

## Common Pitfalls

1. **Not checking for duplicates** - Always search Notion before creating
2. **Missing user approval** - NEVER create Notion entries without showing and asking first
3. **Incorrect company size** - Research thoroughly, don't guess
4. **Incomplete JD fetch** - Ensure WebFetch got full content, not just snippet
5. **Pipeline health false positives** - Some pages redirect or have dynamic content; review before marking unavailable
6. **Forgetting closure reason in Notes** - Always document WHY job was marked unavailable

## Success Metrics

**Mode 1 completion:**
- ✅ Job description fetched successfully
- ✅ All required fields extracted (Company, Role, Location, Size, Work Style)
- ✅ Checked for duplicates in Notion
- ✅ User approved before creation
- ✅ Entry created with correct Status and properties
- ✅ Asked about resume customization

**Mode 2 completion:**
- ✅ All job URLs processed
- ✅ Duplicates identified and reported
- ✅ Summary table shown with all details
- ✅ User approved batch creation
- ✅ All entries created successfully

**Mode 3 completion:**
- ✅ Search executed with user's keywords
- ✅ Results presented clearly
- ✅ User confirmed selection or created new

**Mode 4 completion:**
- ✅ All "Considering" jobs checked
- ✅ Availability status determined accurately
- ✅ Results categorized (open vs closed)
- ✅ User approved status updates
- ✅ Notion Status updated to "Unavailable"
- ✅ Closure reason added to Notes section with date

## Reference

**Notion Database URL:** https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c

**Database ID:** `2c8b6eb0-ddc0-81f0-884e-e0de405d82ae`

**README:** `/Users/v/Documents/cv/customized/README.md`

**Integration:** `writing:resume-customization` skill
