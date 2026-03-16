---
name: configure-project
author: Vvkmnn
description: This skill should be used when the user asks to "set project model", "switch project model", "use opus for this project", "use sonnet for this project", "show project model", "what model is this project using", "remove project model", "clear project model", or "reset to global model". Manages project-local Claude Code configuration in .claude/settings.local.json.
version: 0.1.0
---

# Project Claude

Manage project-level Claude Code configuration. Currently supports model management with `.claude/settings.local.json`.

## Purpose

When working across multiple projects, some may benefit from different Claude models than your global default. This skill manages project-local settings that override global preferences without affecting other projects.

**Settings hierarchy**: Project local (`.claude/settings.local.json`) → Project shared (`.claude/settings.json`) → User global (`~/.claude/settings.json`)

## When to Use

Use this skill when:
- Setting a specific model for the current project only
- Checking what model the current project uses
- Removing project-specific settings to revert to global defaults

## Operations

### Set Project Model

When user requests to set, switch, or use a specific model for the project:

1. **Create directory** if needed:
   - Check if `.claude/` exists in current directory
   - Create with `mkdir -p .claude` if missing

2. **Read existing settings**:
   - Check if `.claude/settings.local.json` exists
   - If exists, read current content to preserve other fields
   - If missing, start with empty object `{}`

3. **Update model field**:
   - Add or update `"model"` field with requested value
   - Preserve all other existing fields (permissions, env, hooks, etc.)
   - Valid models: `opus`, `sonnet`, `opusplan`, `haiku`, `default`, or full model names like `claude-sonnet-4-5-20250929`

4. **Write back**:
   - Write updated JSON to `.claude/settings.local.json`
   - Use proper JSON formatting (2-space indentation)

5. **Confirm**:
   - Report success with the model that was set
   - Note that `.claude/settings.local.json` is auto-ignored by git

### View Project Model

When user asks what model the project is using:

1. **Check file existence**:
   - Look for `.claude/settings.local.json` in current directory

2. **Read and report**:
   - If file exists and has `"model"` field, report the value
   - If file exists but no `"model"` field, report "No project-specific model (using global default)"
   - If file doesn't exist, report "No project-specific model (using global default)"

3. **Context**:
   - Optionally mention the global default if known (from `~/.claude/settings.json` or the current session)

### Remove Project Model

When user requests to clear or remove the project model setting:

1. **Check file existence**:
   - Verify `.claude/settings.local.json` exists
   - If missing, report "No project settings to remove"

2. **Read current content**:
   - Parse the JSON to get all fields

3. **Remove model field**:
   - Delete the `"model"` field while preserving other fields
   - If file becomes empty (`{}`), delete the entire file
   - If other fields remain, write back the updated JSON

4. **Confirm**:
   - Report that project model was removed
   - Note that project will now use global default

## Implementation Notes

- Use Read/Write/Edit tools directly (no script needed)
- Always preserve existing fields when modifying settings
- Handle edge cases gracefully (empty files, malformed JSON)
- `.claude/settings.local.json` is automatically gitignored by Claude Code
- JSON should use 2-space indentation for consistency

## Examples

**Set model:**
```json
// Before: file doesn't exist
// After:
{
  "model": "opus"
}
```

**Set model (preserve existing):**
```json
// Before:
{
  "permissions": {
    "allow": ["Bash(npm test)"]
  }
}

// After:
{
  "permissions": {
    "allow": ["Bash(npm test)"]
  },
  "model": "opus"
}
```

**Remove model:**
```json
// Before:
{
  "model": "opus",
  "env": {
    "DEBUG": "1"
  }
}

// After:
{
  "env": {
    "DEBUG": "1"
  }
}
```
