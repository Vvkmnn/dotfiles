---
name: simplify-code
description: Run code-simplifier agent on recently modified code. Use PROACTIVELY before commits, PRs, or at end of significant coding sessions. Safe - never changes functionality.
---

Invoke the code-simplifier agent to review and simplify recently modified code.

**Safety guarantee**: The agent never changes what code does - only how it does it. All original features, outputs, and behaviors remain intact.

Use the Task tool to launch `code-simplifier:code-simplifier` agent with prompt:
"Review and simplify the code modified in this session. Focus on clarity, consistency, and maintainability. Apply project standards from CLAUDE.md. Preserve all functionality - never change behavior."

Report what was simplified. If no changes needed, say so briefly.
