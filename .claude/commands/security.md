---
description: Scan recent code changes for security vulnerabilities
---

DISPATCH the `security-reviewer` agent via the Agent tool (subagent_type: "security-reviewer") — do NOT inline the scan in the main session. It runs in the background; continue other work and report findings when it returns.

Agent prompt must include:
1. Run `git diff --name-only` to identify changed files
2. Check each file against OWASP Top 10 (injection, broken auth, sensitive data, XSS, access control)
3. Search for secrets, credentials, API keys in code
4. Check for unsafe patterns (eval, innerHTML, SQL concatenation, chmod 777)
5. Rate each finding: Critical / High / Medium / Low with file:line references and recommended fixes
