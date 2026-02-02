# Preview Before Acting

## Problem
Actions without preview waste iterations. External calls are irreversible. Formatted output often needs adjustment.

## Rule
Default to showing before doing. Discuss, preview, get approval, then execute.

### Always Preview

**External operations:**
- MCP calls that write/modify (GitHub, Notion, Google Drive, etc.)
- API calls to external services
- Sending messages, posting comments, publishing content

**Destructive operations:**
- Deleting files, branches, resources
- Overwriting existing content
- Modifying permissions or settings

**Formatted output:**
- ASCII diagrams, tables, charts
- Code blocks intended for copy-paste
- Shell commands with complex flags
- Generated configs, templates, boilerplate

**Content for external use:**
- Commit messages, PR descriptions
- Issue bodies, comments, reviews
- Documentation sections

### Approval Flow

1. **Discuss** - explain intent and approach
2. **Preview** - show exact output (verbatim, not summarized)
3. **Wait** - explicit approval: "yes", "approved", "proceed", "do it"
4. **Execute** - only after approval

### Dry Run for MCP Calls

MCP calls can't be undone. "Dry run" means describe before executing:

1. **State the operation**: "I'll create a GitHub issue titled 'Fix auth bug'"
2. **Show parameters**: Title, body, labels, assignees
3. **Note side effects**: "This will notify watchers and may trigger CI"
4. **Ask permission**: "Should I proceed?"
5. **Execute only after approval**

No batch MCP calls - one operation at a time, each approved separately.

### Preview Format

For external actions:
```
**Target**: [service/resource]
**Action**: [create/update/delete]
**Content**:
───────────────────────────────
[exact content]
───────────────────────────────
Approve?
```

For formatted output:
```
Here's the [diagram/table/config]:
───────────────────────────────
[formatted content]
───────────────────────────────
Want any changes?
```

### No Approval Needed

- Read-only operations (fetch, list, search, view)
- Local exploration (file reads, grep, git status)
- Conversational responses and explanations
- Explicit batch approval already given
- Local file edits (tool has built-in approval - don't double-ask in prose)
- Simple code changes with clear intent already discussed

### Principle

Preview where there's no built-in approval or where iteration is costly:
- External APIs/MCPs have no undo - preview before calling
- Complex formatting needs visual review - show before finalizing
- Local tool calls (Edit, Write, Bash) have built-in approval - don't double-ask in prose
