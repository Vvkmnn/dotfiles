---
name: draft-github
author: Vvkmnn
description: Draft high-quality GitHub PRs, issues, and comments. Use when creating pull requests, filing bug reports, proposing features, or commenting on issues. Trigger on "create PR", "file issue", "draft PR", "bug report", "feature request", "pr-draft", "draft-pr".
argument-hint: "[pr|issue|comment] [optional: issue number or target branch]"
disable-model-invocation: true
allowed-tools: [Bash, Read, Grep, Glob]
version: 0.1.0
---

# GitHub Submissions

Every submission should demonstrate you've done the work — reproduced the bug, read the source, identified the cause, proposed a fix.

## Pull Requests

**Always draft mode** — `gh pr create --draft` unless explicitly told otherwise.

**Before creating:**
1. Check working tree for uncommitted changes
   - Ask before committing temp code, debug prints, config tweaks
   - Stash or separate-commit unrelated changes
2. Ensure branch is pushed and up to date with target
3. Analyze commits since branching: `git log main..HEAD --oneline`
4. Read modified files to understand full scope
5. Check for related GitHub issues: `gh issue list`

**Title:** Conventional commit format when repo uses it (`fix:`, `feat:`, `fix(scope):`). Otherwise specific and descriptive. Never "Fix bug" or "Update code".

**Body structure** (when repo has no PR template):

- **Summary**: 1-2 sentences — what changed and why
- **Changes**: Grouped by root cause if multi-fix. Flat bullet list with present tense verbs (Adds, Fixes, Updates, Removes). Link to `file:line` in the repo for non-obvious changes
- **Testing**: Specific results — "All 46 unit tests pass" + "18/18 e2e tests against live API", not just "tests pass"

**Optional sections** (include only when valuable):

- **Problem**: When the "why" needs more context (error messages, user impact)
- **Note**: Migration impact, breaking changes, minimum version bumps
- **Related**: Links to issues (`Fixes #N`), prior PRs, external docs

**Style rules:**
- Present tense always — "Adds authentication" not "Added authentication"
- Show inline diffs for key changes: ```diff blocks
- No file listings — reviewers see the diff
- No overselling — "Fixes crash" not "Dramatically improves stability"
- Related links: quality over quantity, omit section entirely if nothing valuable
- `Fixes #N` to auto-close issues when applicable

**If repo has a PR template:** Follow it, but enhance with the patterns above where sections are sparse.

### Example PR body (based on actual style)

```
Fixes #1093 and #1094.

## Summary

Seven bugs across type models and resource methods that cause crashes or produce invalid data.

## Changes

### Type validation (#1093)

- **`Content2` model** (`types/task.py`): `requires_confirmation` changed from `bool` to `Union[bool, str]` — fixes `view_task_steps()` `ValidationError`
- **`update_params()`** (`resources/tool.py`): strip `required` from property dicts — JSON Schema requires `required` as top-level array

### Resource methods (#1094)

- **`create_tool()`** (`resources/tools.py:52`): `uuid.uuid4()` → `str(uuid.uuid4())` — fixes `TypeError: Object of type UUID is not JSON serializable`

## Testing

- All 46 existing unit tests pass
- 18/18 end-to-end tests against live API
```

## Bug Reports

**Structure:** Problem → Reproduction → Root cause → Suggested fix

**Required:**
- Version/environment info at top (SDK version, commit hash, OS)
- Minimal reproduction with runnable code snippet
- Exact error message (full traceback, not paraphrased)

**Strongly encouraged:**
- Root cause with link to source: `[resources/tool.py:52](https://github.com/.../blob/main/...#L52)`
- Suggested fix as ```diff block
- Related issues/PRs cross-referenced at bottom

**Multiple bugs in same area?** Number each bug with `---` dividers. Each gets its own Reproduction / Root cause / Suggested fix. File one issue if they share a component, separate issues if unrelated.

### Example issue body (based on actual style)

```
Four bugs in tool and agent resource methods that cause crashes or silent data loss.

**SDK version**: 10.2.2 (PyPI) / `main` at `af61c22`

---

## 1. `create_tool()` fails with `TypeError`

### Reproduction

python
from relevanceai import RelevanceAI
client = RelevanceAI()
tool = client.tools.create_tool(title="test", description="test")
# TypeError: Object of type UUID is not JSON serializable


### Root cause

[`resources/tools.py:52`](https://github.com/RelevanceAI/relevanceai/blob/main/relevanceai/resources/tools.py#L52) — `uuid.uuid4()` produces a UUID object, not a string.

### Suggested fix

diff
-        tool_id = uuid.uuid4()
+        tool_id = str(uuid.uuid4())

```

## Feature Requests

**Structure:** Context → Current behavior → Proposed solution → Priority

**Required:**
- What exists today and why it's insufficient
- Concrete proposed API/behavior (code example, JSON shape, CLI flag)
- What you tried as workarounds

**Include when relevant:**
- Related issues that establish precedent
- Priority self-assessment (Low/Medium/High)
- Alternative solutions considered

## Comments and Reviews

- Be specific — reference file:line, quote the relevant code
- Propose solutions, don't just point out problems
- One concern per comment thread

## Repo Template Compliance

Always check for templates first:
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/` directory
- Follow the template, enhance with patterns above where sections are sparse
- Fill in all checkboxes honestly

## Before Submitting

- [ ] Title is specific and descriptive
- [ ] Reproduction steps tested and runnable
- [ ] Related issues linked (`Fixes #N` for PRs)
- [ ] No sensitive data (tokens, keys, internal URLs)
- [ ] Present tense in PR change descriptions
- [ ] Draft mode for PRs
- [ ] Environment info included for bug reports
