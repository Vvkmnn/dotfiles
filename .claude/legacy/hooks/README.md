# Claude Code Hooks

This directory contains hooks for Claude Code that provide safety, visibility, and extensibility.

## Active Hooks

### 🔒 pre-tool-use.js
**Event**: PreToolUse  
**Matchers**: Edit, MultiEdit, Write, Bash

**Features**:
- **File Reading**: Shows current file content before Edit/MultiEdit/Write operations
- **Git Confirmation**: Blocks all git commands until you confirm
- **RM Confirmation**: Blocks destructive rm commands until you confirm

**Examples**:
```bash
# This will show current file content before editing
Edit: /path/to/file.js

# These will prompt for confirmation
git add .
git commit -m "changes"
rm -rf dangerous/
```

## Placeholder Hooks

All other hook events have placeholder scripts ready for future customization:

### 📊 post-tool-use.js
**Event**: PostToolUse  
**Triggered**: After any tool completes successfully  
**Use for**: Logging, cleanup, follow-up actions, metrics

### 🔔 notification.js
**Event**: Notification  
**Triggered**: Tool permission requests, idle timeouts (60s+)  
**Use for**: Custom notifications, external integrations, audit logs

### 🛑 stop.js
**Event**: Stop  
**Triggered**: When main Claude agent finishes responding  
**Use for**: Session cleanup, final logging, backup operations

### 🎯 subagent-stop.js
**Event**: SubagentStop  
**Triggered**: When Task tool subagent finishes  
**Use for**: Subagent metrics, complex task tracking, aggregation

### 📦 pre-compact.js
**Event**: PreCompact  
**Triggered**: Before conversation compaction (manual/auto)  
**Use for**: Backup conversations, preserve context, notifications

## Configuration

Add to `/Users/v/.claude/settings.json`:

```json
{
  "model": "sonnet",
  "hooks": [
    {
      "event": "PreToolUse",
      "matchers": ["Edit", "MultiEdit", "Write", "Bash"],
      "command": "node /Users/v/.claude/hooks/pre-tool-use.js"
    }
  ]
}
```

To enable additional hooks, add more entries:

```json
{
  "event": "PostToolUse",
  "matchers": ["*"],
  "command": "node /Users/v/.claude/hooks/post-tool-use.js"
}
```

## Hook Input Format

All hooks receive JSON via stdin with this structure:

```json
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file",
    "old_string": "...",
    "new_string": "..."
  },
  "conversation_id": "...",
  "matcher": "Edit"
}
```

## Exit Codes

- **0**: Allow operation to proceed
- **1**: Block operation (PreToolUse only)

## Safety Notes

- PreToolUse hooks can block operations (exit 1)
- Other hooks should always exit 0 to avoid breaking workflow
- Failed hooks don't block Claude Code execution
- Use try/catch to handle errors gracefully

## Customization

Each placeholder script includes:
- JSON parsing from stdin
- Error handling
- Use case examples in comments
- Proper exit codes

Edit any script to add your custom logic while maintaining the basic structure.