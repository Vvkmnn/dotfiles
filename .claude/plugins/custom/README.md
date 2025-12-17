# Custom Plugins - Personal Marketplace

Your personal collection of custom Claude Code plugins.

## Installed Plugins

### writing
Resume customization, cover letters, and professional writing

**Skills:**
- `writing:resume-customization` - Transforms master resume for specific job applications with ATS optimization, Australian English, and Notion tracking

### automating
Job tracking, pipeline management, and workflow automation

**Skills:**
- `automating:job-tracker` - Manages Notion job database with search, batch additions, and pipeline health checks

### coding
Development workflows and coding skills (placeholder for future use)

## Setup Required

### Notion Database

⚠️ **Action Required:** Add "Unavailable" status option to your Notion job applications database

**Steps:**
1. Open https://www.notion.so/job-applications-2c8b6eb0ddc08051a721d31a4c60af1c
2. Click any "Status" cell
3. Click "Edit property"
4. Add new option: "Unavailable"
5. Choose gray color with strikethrough (🚫)

This is needed for `automating:job-tracker` Mode 4 (Pipeline Health Check) to mark closed job postings.

## Usage

**Add a job to tracker:**
```
"Add this job to Notion: https://jobs.netflix.com/..."
```

**Check pipeline health:**
```
"Check my job pipeline"
```

**Customize resume for a job:**
```
"Customize my resume for Netflix Senior AI Engineer

JD: [paste or URL]
ATS Analysis: [paste external scoring]
Notion: [optional - will search/create if not provided]"
```

## File Locations

- **Plugins:** `/Users/v/.claude/plugins/custom/`
- **Skills:** Each plugin has `/skills/` directory
- **Master Resume:** `/Users/v/Documents/cv/resume.tex`
- **Customized Resumes:** `/Users/v/Documents/cv/customized/`
- **Notion Tracker:** `/Users/v/Documents/cv/customized/README.md`
