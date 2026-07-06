---
name: craft-commit
description: Use when the user asks to commit, make a git commit, stage and commit, save changes to git, or says "commit this", "lets commit", "commit and push", "push this", "save and push", "ship it", "land this", or any variation implying they want to create a git commit from current changes. Also triggers on "/commit". Handles smart staging, logical grouping, commit message generation matching the repo's existing style, and optional push. OWNS the commit step — run verify-work first for non-trivial changes; for the PR afterward use draft-github; plugin commit-commands is the lightweight fallback.
author: Vvkmnn
version: 1.1.0
---

# Smart Git Commit

Create logical, well-formatted commits with interactive approval.

## Arguments
- `$ARGUMENTS` - Optional description of changes (helps with commit message)
- `--auto` - Skip approval prompts, execute all commits immediately
- `--no-chunk` - Single commit instead of splitting into logical groups

## Workflow

### Phase 1: Analyze Changes
```bash
# Run these in parallel to understand the current state
git status --porcelain
git diff --stat
git diff --cached --stat
git log --oneline -15  # Recent commit style reference
```

### Phase 2: Flag Risky Files
Before proposing any commits, warn about files that should NOT be staged:
- `.env*` files (credentials)
- `*credentials*`, `*secret*`, `*key*`, `*token*` (sensitive data)
- `*.pem`, `*.key`, `*.p12` (certificates/keys)
- Files > 1MB (large binaries)
- `node_modules/`, `dist/`, `.next/`, `build/` (build artifacts)

Display flagged files prominently so user sees them before any staging.

### Phase 3: Group Changes Logically
Split changes into logical commits by category:
1. **feat** - New feature code (src/, lib/)
2. **fix** - Bug fixes
3. **test** - Test files (*test*, *spec*)
4. **docs** - Documentation (*.md, docs/)
5. **style** - Formatting only (no logic changes)
6. **refactor** - Code restructuring (no behavior change)
7. **chore** - Dependencies, configs (package.json, tsconfig, etc.)

If `--no-chunk` flag is present, combine all into one commit.

### Phase 4: Sequential Approval (ONE AT A TIME)
For each commit group:

1. **Present the commit**:
   ```
   COMMIT 1/3: type(scope)
   ─────────────────────────
   Files to stage:
     - path/to/file1.ts
     - path/to/file2.ts

   Proposed message:
     type(scope): Subject line here
   ```
   (body only if repo history uses bodies)

2. **Wait for user approval** using AskUserQuestion:
   - "Approve" - Stage files and commit
   - "Edit message" - Let user provide new message
   - "Skip" - Don't commit these files, move to next group
   - "Abort" - Stop the entire commit process

3. **Execute if approved**:
   ```bash
   git add <files>
   git commit -m "$(cat <<'EOF'
   type(scope): Subject line

   Body text here
   EOF
   )"
   ```

4. **Move to next commit** and repeat until done

If `--auto` flag is present, skip approval prompts and execute all commits.

## Message Style

**Primary source of truth: the repo's own `git log --oneline -15`.**
Read it every time. Match the existing casing, scope conventions, and level of detail.
Only fall back to the format below when the repo has no history or fewer than 3 commits.

### Fallback Format (new repos only)
```
type(scope): Subject (max 50 chars, no period)

Optional body (only if repo history shows multi-line commits):
- Bullet points for discrete changes
- Imperative mood ("Add" not "Added")
```

The very first commit in a new repo should always be:
```
feat(git): Initial commit with <concise project summary>
```

### Types (always lowercase)
- **feat** - New feature or capability
- **fix** - Bug fix
- **refactor** - Code restructuring (no behavior change)
- **style** - Formatting only (no logic change)
- **docs** - Documentation
- **test** - Tests
- **chore** - Dependencies, configs, tooling

### Subject Line (always capitalized)
- First word after `:` is capitalized: `feat(auth): Add session refresh`
- Imperative mood: "Add", "Fix", "Remove" — not "Added", "Fixes", "Removing"
- Be specific and searchable: name the thing changed, not vague intent
  - Good: `feat(hooks): Add settings guard and sibling suggestions`
  - Bad: `feat: Update hooks`
  - Bad: `feat(hooks): Various improvements`
- No trailing period

### Scope
Always include scope in parentheses: `feat(auth)`, `fix(api)`, `docs(readme)`
Derive scope from the primary directory or module being changed.
Use the most specific meaningful scope — `feat(pre-plan)` over `feat(hooks)` when only one hook changed, but `feat(hooks)` when several hooks changed together.

## Rules
- NEVER mention Claude, AI, LLM, copilot, or any AI tooling in commit messages — no "Co-Authored-By", "Generated with", or similar
- NEVER stage flagged risky files without explicit user confirmation
- NEVER commit if there are no changes to commit
- Always read `git log --oneline -15` first and match the repo's established style
- Always show `git status` after final commit to confirm clean state
- Commit messages must be specific enough to find via `git log --grep` later
