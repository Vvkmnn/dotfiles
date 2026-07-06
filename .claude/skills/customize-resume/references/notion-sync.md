# Notion Sync — job-tracker integration

> Moved verbatim from SKILL.md (lines 1267-1348) in the 2026-07-06 restructure.

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

