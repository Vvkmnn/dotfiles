---
name: browse-claude
author: Vvkmnn
description: This skill should be used when needing Chrome browser access, before using browser automation tools, when `mcp__claude-in-chrome__*` tools return "extension not connected", or when user asks to "open Chrome", "use browser", "browse to", "navigate to", "claude in chrome", or any web interaction task. Creates fresh, isolated browser sessions per task.
version: 0.1.0
---

# Browse Claude - Chrome Browser Management

## Purpose

Self-serve Chrome browser access when the Claude in Chrome extension is needed. User's default browser is Safari, so Chrome must be explicitly opened for browser automation tasks.

## When to Use

**Proactive (before browser tasks):**
- About to use any `mcp__claude-in-chrome__*` tool
- User asks to browse, navigate, or interact with a website
- Need to take screenshots, fill forms, or automate web interactions

**Reactive (after failures):**
- `tabs_context_mcp` returns "extension not connected"
- Any Chrome MCP tool fails with connection error

## Core Principles

1. **Check first** - Always check if Chrome is running before opening
2. **Minimize windows** - One fresh tab for the task, not multiple windows
3. **Graceful recovery** - If user closes Chrome, ask before reopening
4. **Closeable workspace** - User can close the tab/window when task is done

## Workflow

### Step 1: Check if Chrome is Running

```bash
pgrep -x "Google Chrome" > /dev/null && echo "running" || echo "not running"
```

**If running:** Skip to Step 3 (MCP check)
**If not running:** Continue to Step 2

### Step 2: Open Chrome (only if not running)

```bash
open -a "Google Chrome"
sleep 5
```

Opens Chrome with one window. Extension auto-connects.

### Step 3: Check MCP Connection

```typescript
mcp__claude-in-chrome__tabs_context_mcp({ createIfEmpty: true })
```

**Expected:** Returns `availableTabs` and `tabGroupId`

**If "extension not connected":**
- Wait 3 more seconds, retry once
- If still failing → Ask user to verify extension installed

### Step 4: Create Fresh Tab for This Task

```typescript
mcp__claude-in-chrome__tabs_create_mcp()
```

Creates one new tab in the MCP tab group - user's dedicated workspace for this task.

### Step 5: Navigate

```typescript
mcp__claude-in-chrome__navigate({ url: "https://...", tabId: <newTabId> })
```

**Task complete.** User can close this tab when done.

## Handling User Closes Chrome

When Chrome MCP tools fail mid-task with "extension not connected" or "tab doesn't exist":

**DO NOT silently reopen Chrome.** Ask first:

```
"Chrome was closed. Would you like me to:
1. Open a fresh browser to continue this task
2. Stop browser work for now

[1/2]"
```

This respects user intent - they may have closed Chrome deliberately.

## Quick Reference

| Action | Tool/Command |
|--------|--------------|
| Check connection | `tabs_context_mcp({ createIfEmpty: true })` |
| Open Chrome | `open -a "Google Chrome"` |
| Wait for extension | `sleep 5` |
| Create new tab | `tabs_create_mcp()` |
| Navigate | `navigate({ url, tabId })` |
| Take screenshot | `computer({ action: "screenshot", tabId })` |

## Error Recovery

| Error | Action |
|-------|--------|
| "extension not connected" | Open Chrome, wait 5s, retry |
| "tab doesn't exist" | Call `tabs_context_mcp` for fresh tab IDs |
| Connection still fails after 2 retries | Ask user to verify extension installed |

## Notes

- User's default browser is Safari - Chrome won't open automatically
- **Check if Chrome running first** - `pgrep -x "Google Chrome"` before opening
- **One fresh tab per task** - creates closeable workspace, not multiple windows
- Tab IDs from previous sessions are invalid - always get fresh context
- Extension auto-connects when Chrome is running; no manual `/chrome` needed
- **Ask before reopening** - if user closes Chrome mid-task, don't silently reopen
