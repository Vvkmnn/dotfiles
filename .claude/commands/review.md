---
description: Review recent code changes for quality, security, and best practices
---

DISPATCH the `code-reviewer` agent via the Agent tool (subagent_type: "code-reviewer") — do NOT inline the review in the main session (fresh context finds what the author-context misses). It runs in the background; continue other work and report findings when it returns.

Agent prompt must include:
1. Run `git diff --stat` to see what changed
2. Review each changed file against the checklist (readability, correctness, functional style, security, tests, scope)
3. Organize findings into Critical / Warning / Suggestion tiers with file:line references
4. Include specific code examples showing how to fix each issue
