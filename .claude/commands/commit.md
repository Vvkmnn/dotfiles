---
description: Smart commit with staging proposals and sequential approval
allowed-tools: Bash(git:*), Read, AskUserQuestion
argument-hint: "[description] [--auto] [--no-chunk]"
---

# /commit - Sequential Commit with Smart Staging

Create logical, well-formatted commits with interactive approval. Uses ~/.gitmessage format.

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
git log --oneline -5  # Recent commit style reference
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
1. **FEAT** - New feature code (src/, lib/)
2. **FIX** - Bug fixes
3. **TEST** - Test files (*test*, *spec*)
4. **DOCS** - Documentation (*.md, docs/)
5. **STYLE** - Formatting only (no logic changes)
6. **REFACTOR** - Code restructuring (no behavior change)
7. **CHORE** - Dependencies, configs (package.json, tsconfig, etc.)

If `--no-chunk` flag is present, combine all into one commit.

### Phase 4: Sequential Approval (ONE AT A TIME)
For each commit group:

1. **Present the commit**:
   ```
   COMMIT 1/3: TYPE(scope)
   ─────────────────────────
   Files to stage:
     - path/to/file1.ts
     - path/to/file2.ts

   Proposed message:
     TYPE(scope): Subject line here

     - Detail about change
     - Another detail
   ```

2. **Wait for user approval** using AskUserQuestion:
   - "Approve" - Stage files and commit
   - "Edit message" - Let user provide new message
   - "Skip" - Don't commit these files, move to next group
   - "Abort" - Stop the entire commit process

3. **Execute if approved**:
   ```bash
   git add <files>
   git commit -m "$(cat <<'EOF'
   TYPE(scope): Subject line

   Body text here
   EOF
   )"
   ```

4. **Move to next commit** and repeat until done

If `--auto` flag is present, skip approval prompts and execute all commits.

## Message Format (from ~/.gitmessage)
```
TYPE(scope): Subject (max 50 chars, capitalized, no period)

Body explaining WHY (max 72 char lines)
- Bullet points allowed
- Imperative mood ("Add" not "Added")

Resolves #issue
```

### Types (UPPERCASE)
- **FEAT** - New feature
- **FIX** - Bug fix
- **REFACTOR** - Code restructuring
- **STYLE** - Formatting only
- **DOCS** - Documentation
- **TEST** - Tests
- **CHORE** - Dependencies, configs

### Scope
Always include scope in parentheses: `FEAT(auth)`, `FIX(api)`, `DOCS(readme)`
Derive scope from the primary directory or module being changed.

## Rules
- NEVER include "Co-Authored-By", "Generated with", or AI references
- NEVER stage flagged risky files without explicit user confirmation
- NEVER commit if there are no changes to commit
- Always show `git status` after final commit to confirm clean state
- Match existing commit style from `git log` when possible

## Future Enhancements
<!--
Can add these later:
- `gh issue list` / `gh pr list` for GitHub linking
- Linear ticket detection and linking
- Obsidian documentation of commits
-->
