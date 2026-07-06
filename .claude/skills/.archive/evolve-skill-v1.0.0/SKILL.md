---
name: evolve-skill
description: >
  Use when completing a task that used a custom skill from ~/.claude/skills/ and
  the skill had missing steps, edge cases, or outdated instructions. Also use after
  debugging sessions where a non-obvious solution, workaround, or error resolution
  was discovered through investigation. Triggers: (1) verify.md completion checklist
  step 5b, (2) /evolve-skill command for session retrospective, (3) "save this as
  a skill" or "what did we learn?", (4) after any non-trivial debugging discovery.
---

# Evolve Skill

Continuous learning system that improves existing skills and extracts new ones from
work sessions. Incorporates best practices from
[Claudeception](https://github.com/blader/Claudeception) v3.0.0 (MIT).

## Two Modes

### Mode 1: Improve Existing Skill

After using a custom skill from `~/.claude/skills/`, evaluate:

- **Missing steps** discovered during use
- **Better examples** from this session
- **New edge cases** encountered
- **Outdated instructions** that caused confusion
- **Workflow improvements** identified

**Process:**
1. Identify the skill that was used
2. Note what worked and what didn't
3. Propose surgical Edit updates (don't rewrite)
4. Get user approval before modifying SKILL.md
5. Bump version: patch = wording, minor = new scenario, major = restructure

### Mode 2: Extract New Skill

After debugging or discovery, evaluate whether the knowledge is worth preserving.

**Extract when you encounter:**
1. **Non-obvious solutions** — required significant investigation
2. **Tool integration knowledge** — beyond what documentation covers
3. **Error resolution** — misleading error messages with non-obvious root causes
4. **Workflow optimizations** — multi-step processes that can be streamlined
5. **Project-specific patterns** — conventions or configs not documented elsewhere

## Quality Gates

Before extracting or updating, verify ALL four:

- **Reusable** — helps future tasks, not just this instance
- **Non-trivial** — required discovery, not documentation lookup
- **Specific** — exact trigger conditions and solution describable
- **Verified** — solution actually worked, not theoretical

## Process

### Step 1: Check Existing Skills

Before creating anything new, search for related skills:

```bash
# List all skills
ls ~/.claude/skills/*/SKILL.md

# Search by keywords
grep -ri "keyword" ~/.claude/skills/ --include="SKILL.md" -l

# Search by error message
grep -rF "exact error message" ~/.claude/skills/ --include="SKILL.md"
```

**Decision matrix:**

| Found | Action |
|-------|--------|
| Nothing related | Create new skill |
| Same trigger + same fix | Update existing (minor version bump) |
| Same trigger, different root cause | Create new, add "See also:" links |
| Partial overlap | Update existing with new subsection |
| Stale or wrong | Update with corrections (major bump) |

### Step 2: Identify the Knowledge

- What was the problem or task?
- What was non-obvious about the solution?
- What would someone need to know to solve this faster next time?
- What are the exact trigger conditions?

### Step 3: Research (When Appropriate)

Search for best practices when the topic involves specific tools, frameworks, or APIs.
Use Context7, WebSearch, or documentation. Skip for project-specific internal patterns.

### Step 4: Structure New Skills

```markdown
---
name: descriptive-kebab-case-name
description: >
  Use when [specific triggering conditions and symptoms].
  [Include exact error messages, frameworks, tools.]
---

# Skill Name

## Problem
[What this skill addresses]

## When to Use
[Exact triggers: error messages, symptoms, scenarios]

## Solution
[Step-by-step]

## Verification
[How to confirm it worked]

## Notes
[Caveats, edge cases, related skills]
```

### Step 5: Write Effective Descriptions

The `description` field is critical for skill discovery. Claude matches current context
against descriptions to decide which skills to load.

- Start with "Use when..." — triggering conditions only
- Include specific symptoms, error messages, tool names
- Do NOT summarize the skill's workflow (causes Claude to skip reading the full skill)
- Write in third person

### Step 6: Save

- **User-wide skills:** `~/.claude/skills/[name]/SKILL.md`
- Use verb-noun imperative naming: `evolve-skill`, `customize-resume`, `configure-neovim`
- Get user approval before writing

## Retrospective Mode

When invoked explicitly (`/evolve-skill` or "what did we learn?"):

1. **Review session** — scan conversation for extractable knowledge
2. **Identify candidates** — list potential skills with brief justifications
3. **Prioritize** — focus on highest-value, most reusable knowledge
4. **Extract** — create/update 1-3 skills per session
5. **Summarize** — report what was created/updated and why

## Self-Reflection Prompts

Use after completing any significant task:

- "What did I learn that wasn't obvious before starting?"
- "If I faced this problem again, what would I wish I knew?"
- "What error message led me here, and what was the actual cause?"
- "Is this reusable, or specific to this one situation?"

## Anti-Patterns

- **Over-extraction** — not every task deserves a skill. Mundane solutions don't need preserving
- **Vague descriptions** — "Helps with React problems" won't surface when needed
- **Unverified solutions** — only extract what actually worked
- **Doc duplication** — don't recreate official docs; link to them, add what's missing
- **Interrupting main work** — always batch skill evolution at END of task

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-16 | Initial version. Incorporates Claudeception v3.0.0 extraction process + our "improve existing skills" mode. Source: [blader/Claudeception](https://github.com/blader/Claudeception) SHA `69db71b` |
