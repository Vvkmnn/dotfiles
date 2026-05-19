---
description: Scan recent code changes for security vulnerabilities
---

Use the security-reviewer agent to scan recent changes for vulnerabilities.

Focus on:
1. Run `git diff --name-only` to identify changed files
2. Check each file against OWASP Top 10 (injection, broken auth, sensitive data, XSS, access control)
3. Search for secrets, credentials, API keys in code
4. Check for unsafe patterns (eval, innerHTML, SQL concatenation, chmod 777)
5. Rate each finding: Critical / High / Medium / Low with file:line references and recommended fixes
