# Plan Lifecycle

## Rule
Plans are living documents. Update as you work. Sync with Tasks.

### Plan Format

**Two layers — status at top, details below fold:**

- **Progress line** at very top: `**Progress: 5/8 done** | Active: Feature X, Bug Y`
- **Four sections**: `## Done` (`[x]` items), `## In Progress` (with sub-step checkboxes showing where you are), `## Up Next`, `## Discovered`
- **Bold feature names** for scanning: `- [ ] **Feature name** — brief status`
- **Abandoned items** in Done with strikethrough: `- [x] ~~**Approach**~~ — abandoned: [reason]`
- **Detail sections** below `---`: `## Detail: Feature name` — read only when starting that item, collapse to 1-line summary after completing
- **Summary** as final section: `## Summary` — 2-3 lines max, plain English. Cover the hardest/scariest technical aspect, current state, and what's left. Written so a non-engineer can understand what's happening in a PhD-level plan

### After Compaction

1. Read the plan's `## Context`, `## Done`, and `## In Progress` sections — skip Detail sections for items you haven't started yet
2. **Announce** the plan title and status: "Continuing plan: [title]. X/Y done. Active: [items]."
3. Check TaskList for in-session progress — update any stale tasks to match plan state
4. Trust `[x]` markers in Done — do NOT grep the codebase to verify done items
5. Create Tasks from `## In Progress` items
6. Read the Detail section ONLY for the item you're about to implement

### Implementation Workflow

**After exiting plan mode (first action):**
1. TaskCreate for every `- [ ]` item in the plan — this populates the Flowing display
2. Only then: read files, invoke skills, begin implementation
3. The task list is invisible to the user until TaskCreate is called

**Starting a plan item:**
1. TaskUpdate → in_progress
2. Read that item's Detail section (only that section, not the full plan)
3. Implement the change

**After completing a plan item:**
1. **TaskUpdate → completed** — this updates the Flowing display. Skip it and items stay [ ] forever
2. Avoid editing the plan file mid-coding (disrupts flow). Batch plan updates for natural pauses instead
3. When updating the plan at a natural pause, collapse that item's Detail section to a 1-line summary

**After a subagent completes plan item work:**
1. **TaskUpdate → completed** for that item immediately when the subagent returns
2. Subagents run in isolated conversations — they cannot update the parent task list, only you can
3. Don't move to the next item or dispatch another subagent without updating first

**At natural pauses, UPDATE the plan file:**

Natural pauses: after compaction, between major work phases, before switching tasks, before session end. At these moments:
1. Read the plan file first — match FULL lines including descriptions
2. Mark all completed items `[x]` — this is the persistent record across sessions
3. Batch all checkbox updates into a single Edit
4. Never send parallel Edits to the same file
5. Update the `**Progress: X/Y done**` line at the top to match checkbox counts

**When abandoning an approach:**
1. Move to Done with strikethrough + reason: `- [x] ~~**Approach**~~ — abandoned: [why]`
2. Delete its Detail section
3. Note what was learned (informs next approach)

**When implementation reveals new issues:**
1. TaskCreate for the new item (immediate, no friction)
2. Batch-update the plan file when there's a natural pause (multiple items done, or a significant discovery)

### Token Efficiency

| Action | Do | Don't |
|--------|-----|-------|
| After compaction | Read Context + Done/In Progress sections | Read all Detail sections (read only the next item's Detail) |
| Starting an item | Read that item's Detail section | Read all Detail sections |
| Completing an item | Move to Done, collapse Detail to 1-line summary of what was done/learned | Leave full analysis or delete entirely |
| New discovery | Add 1-line to In Progress + short Detail | Write a 50-line analysis |

### Task Integration

**Two systems, both required:**

| System | Tool | Updates | Persists |
|--------|------|---------|----------|
| Flowing display | TaskUpdate | Immediately | Session only (`~/.claude/tasks/`) |
| Plan file | Edit | At natural pauses | Across sessions (`plans/*.md`) |

**Both must stay in sync.** See Implementation Workflow above for when to call each. TaskUpdate without plan Edit = display updates but next session loses progress. Plan Edit without TaskUpdate = user sees stale display.

### Session Start — Plan Relevance

When a plan file exists and a new session begins:

1. Read the plan's title + Done/In Progress sections only
2. Compare the user's current ask against the plan topic
3. Decide:

**Clearly related** → announce and continue:
"Existing plan: [title]. 3 active, 5 complete. Active items: [list]. Continuing."

**Clearly unrelated** → proactively suggest fresh plan:
"Your ask is about [new topic], but the existing plan covers [old topic] (3 pending, 5 done). These seem unrelated — should I start a fresh plan?"

**Unclear** → ask:
"Existing plan covers [topic]. Is your ask related, or should I start fresh?"

**When continuing a related plan:**
4. Scan active items — do they still make sense given what's done?
5. If an item references an abandoned approach or contradicts current state → move to Done with abandonment note before proceeding
6. Never execute a plan item without first confirming it's still valid

After compaction (same session, same task) → announce plan title + status, then continue. If the user's last message doesn't match the plan topic, do the full relevance check above.

### When to Rewrite vs Edit

| Situation | Action |
|-----------|--------|
| Continuing existing work | Edit incrementally — preserve status, add detail |
| Improving plan structure | Rewrite OK — preserve all status markers and content |
| New unrelated task | Rewrite OK — confirm with user first |
| Plan fully complete, new task | Rewrite OK |
| Simplifying because plan is "too long" | **Never** — trim completed Detail sections instead |
| User provides plan content | Preserve all specifics — improve structure, don't lose detail |
| Losing status markers or progress | **Never** |

### User-Provided Plans

When the user provides a plan or plan-like content:

1. **Preserve specifics** — never silently drop file:line refs, regexes, exact values, or technical detail the user included. Analyze and iterate, but don't lose precision.
2. **Improve, don't simplify** — you can ask questions, suggest changes, restructure for clarity. Don't strip a detailed plan down to a skeleton.
3. **"Implement" = execute** — if the user says "implement this", write the plan to file and start working, don't re-enter plan mode to rewrite it.

### Plan Lineage

When creating a new plan (rewrite or fresh start), include a `## Previous` section at the bottom:

- **Reference the old plan file**: `Previous: old-plan-name.md` — always include the filename so future sessions can read it for context
- **1-line summary**: what it covered
- **Key outcomes**: what was done, what was abandoned and why
- **Lessons**: patterns discovered, gotchas, decisions that inform future work

### Protection (enforced by hooks)

- Write to existing plan files triggers `ask` with done/pending counts (pre-tool-use.js)
  - Plan mode + no pending items → allowed silently (new task, no friction)
  - Plan mode + pending items → soft ask ("Building on it, or starting fresh?")
  - Implementation mode → contextual ask with done/pending counts
  - Nothing is banned — user can always approve a rewrite after seeing the context
- Edit to plan files → always allowed in any mode (incremental updates)
- PreCompact hook appends status snapshot before compaction (pre-compact.js)
- CLAUDE.md points to this rule file for plan guidance
- Plans are living documents — update during implementation, not just in plan mode

### Anti-Patterns

| Don't | Do |
|-------|-----|
| Read full plan after compaction | Read Done/In Progress section only |
| Grep codebase to check if item is done | Trust `[x]` markers in Done |
| Leave completed Detail sections or delete them entirely | Collapse to 1-line summary of what was done/learned |
| Skip plan updates or edit mid-coding | TaskUpdate during work, batch plan Edits at natural pauses only |
| Silently rewrite a plan with pending work | Announce what exists, ask user to confirm |
| Execute plan items without evaluating current state | Evaluate each item before starting — stale items get updated, not executed |
| Leave abandoned approaches as pending items | Move to Done with abandonment note immediately |
| Complete work without calling TaskUpdate | Always TaskUpdate → completed — includes after subagent returns (they can't update parent tasks) |
| Say "plan is stale" or "can be cleaned up later" | Update it NOW — if you're talking about it, you're at a natural pause |
| Trust [ ] markers without checking your own work | If you completed it, mark it [x] — stale markers mislead future sessions |
| Send parallel Edits to the same plan file | One Edit per file, batch changes together |
| Match partial item text in old_string | Include full line with description suffix |
| Strip specifics from a user-provided plan | Preserve file:line refs, regexes, exact values — improve structure, don't lose detail |
| Enter plan mode when user says "implement" | Execute directly — save plan for tracking only |
| Create new plan with no reference to previous | Include `## Previous` with file name, summary, outcomes |
| Invoke skills or read files before TaskCreate after ExitPlanMode | TaskCreate for all pending items first — Flowing display is empty until you do |
| Write Summary longer than 3 lines or use jargon | 2-3 plain English lines: what we did, what's scary, what's left |

## Complements
- `explore.md` — Investigation before modifying plan items
- `verify.md` — Verify implementation before marking `[x]`
- `minimize.md` — Keep plans lean and detail sections short
- `orchestrate.md` — A plan should note its **model/effort scope**: which tier the work needs (e.g. "Opus xhigh for the hard tier, Sonnet subagents for volume"), so the model/effort auto-re-dials to match when the plan runs
