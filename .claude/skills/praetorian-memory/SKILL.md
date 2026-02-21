---
name: praetorian-memory
description: Cross-session memory - invoke at session start, after research, or before context runs low
---

# ⚜️ Praetorian Memory Protocol

Cross-session memory that persists across conversations.

## When to Restore

At session start or when resuming work on a topic:
- `praetorian_restore(query="topic")` - Find past work
- `praetorian_restore()` - Get recent compactions

## When to Compact

After these events:
- **WebFetch** - Save web research
- **Task completion** - Save subagent results
- **Reading 3+ files** - Save codebase insights
- **Making decisions** - Save rationale
- **Before context runs low** - Preserve work

## Format

```
praetorian_compact(
  type: "web_research" | "task_result" | "file_reads" | "decisions",
  title: "<concise title>",
  key_insights: ["insight 1", "insight 2"],
  refs: ["file.ts:123"]
)
```

Auto-merges similar titles. Compact freely.

## Optional: Automatic Reminders

For automatic prompts after WebFetch/Task, add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "WebFetch|Task",
      "hooks": [{
        "type": "command",
        "command": "echo '{\"hookSpecificOutput\":{\"additionalContext\":\"Consider praetorian_compact for this result\"}}'"
      }]
    }]
  }
}
```
