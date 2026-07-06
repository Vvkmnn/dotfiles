---
description: Architecture review of the current project or recent changes
---

DISPATCH the `architect` agent via the Agent tool (subagent_type: "architect") — do NOT inline this analysis in the main session. It runs in the background; continue other work and report its findings when it returns.

Agent prompt must include:
1. Map the dependency graph — what depends on what
2. Evaluate separation of concerns, dependency direction, API design
3. Identify scaling implications and error boundaries
4. Check testability and coupling

Output: Architecture summary, strengths, prioritized concerns with file references, and actionable recommendations with trade-offs.
