# Disabled Plugins Reference

> Updated: 2026-03-17. Optimization: `groovy-pondering-flamingo.md`
> Re-enable globally: set `true` in `~/.claude/settings.json` under `enabledPlugins`
> Re-enable per-project: add to `<project>/.claude/settings.json`:
> ```json
> { "enabledPlugins": { "plugin-name@marketplace": true } }
> ```

## Why Disabled

63 plugins injected 15k+ tokens of agent descriptions per session (~7% of 200k context). Direct JSONL search across 794 sessions confirmed 36 plugins had zero actual skill/agent invocations. Context pollution degrades output — clean 30% context outperforms polluted 60%.

## Trail of Bits Security Suite (15 plugins)

Zero invocations across all sessions. Specialized for security audits not in current workflow.

**Re-enable when:** Starting a security-focused project, doing penetration testing, writing detection rules, auditing cryptographic code, or reviewing code for vulnerabilities.

| Plugin | What It Does | Best For |
|--------|-------------|----------|
| `audit-context-building@trailofbits` | Per-function security analysis with deep architectural context | Security code audits — invoke `audit-context` skill |
| `static-analysis@trailofbits` | CodeQL + Semgrep scanning with SARIF parsing | SAST scanning pipelines |
| `semgrep-rule-creator@trailofbits` | Custom Semgrep rule authoring with test-driven flow | Writing detection rules |
| `semgrep-rule-variant-creator@trailofbits` | Port Semgrep rules across languages | Multi-language codebases |
| `variant-analysis@trailofbits` | Find similar vulnerabilities across codebase | After finding one vuln, find all variants |
| `insecure-defaults@trailofbits` | Detect fail-open / insecure default configurations | Config review, hardening |
| `property-based-testing@trailofbits` | Hypothesis/QuickCheck property-based testing | Fuzzing, edge case discovery |
| `testing-handbook-skills@trailofbits` | LibFuzzer, AFL++, cargo-fuzz, OSS-Fuzz, harness writing | Fuzz testing infrastructure |
| `constant-time-analysis@trailofbits` | Timing side-channel detection | Cryptographic implementations |
| `differential-review@trailofbits` | Security-focused diff review | Security-sensitive PRs |
| `sharp-edges@trailofbits` | Error-prone API / dangerous pattern detection | API safety review |
| `spec-to-code-compliance@trailofbits` | Verify code implements spec exactly | Protocol/standard compliance |
| `dwarf-expert@trailofbits` | DWARF binary debug info analysis | Binary reverse engineering |
| `yara-authoring@trailofbits` | YARA malware detection rule authoring | Malware research |
| `ask-questions-if-underspecified@trailofbits` | Clarify requirements before implementing | Redundant with CLAUDE.md rules |

## Redundant Plugins (7 plugins) — Better version kept

| Disabled | Kept Instead | Why Redundant |
|----------|-------------|---------------|
| `error-debugging@claude-code-workflows` | `debugging-toolkit` | Same `debugger` agent. debugging-toolkit adds `dx-optimizer`. error-debugging's unique `error-detective` (log correlation) is niche. |
| `unit-testing@claude-code-workflows` | `tdd-workflows` | 3rd copy of `debugger` agent. tdd-workflows has `tdd-orchestrator` (red-green-refactor discipline). |
| `code-review@claude-plugins-official` | `compound-engineering` (ce-review) | ce-review provides domain-specialist reviewers. code-review has unique `gh pr comment` integration — **re-enable if doing heavy PR review work**. |
| `feature-dev@claude-plugins-official` | `compound-engineering` (ce-plan) | ce-plan provides document-driven planning. feature-dev is more interactive but never invoked. |
| `security-guidance@claude-plugins-official` | `security-scanning` (if re-enabled) | Passive security hook, but zero invocations. Trail of Bits suite is more thorough if security work needed. |
| `repomix-commands@repomix` | `repomix-mcp` | MCP server provides same tools directly. Commands are user-facing wrappers — `pack-remote`/`pack-local` skills. |
| `repomix-explorer@repomix` | `repomix-mcp` | MCP server's `read_repomix_output`/`grep_repomix_output` cover this. Explorer adds analysis agents. |

**Re-enable repomix-commands when:** You want `/pack-remote` and `/pack-local` slash commands for convenience.
**Re-enable code-review when:** Doing frequent PR reviews and want `gh pr comment` integration.

## Zero-Usage Workflow Plugins (14 plugins)

Zero skill invocations across 794 sessions. High-quality plugins for workflows not currently active.

### Infrastructure & Backend
**Re-enable when:** Building backend services, setting up CI/CD, designing databases, or deploying to cloud.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `backend-development@claude-code-workflows` | API design, microservices, event sourcing, CQRS, GraphQL, Temporal, saga orchestration | Backend service architecture |
| `cicd-automation@claude-code-workflows` | GitHub Actions templates, GitLab CI, Terraform, Kubernetes, secrets management | CI/CD pipeline setup |
| `database-design@claude-code-workflows` | PostgreSQL schema design, SQL optimization | Database schema work |
| `deployment-validation@claude-code-workflows` | Cloud architecture validation, deployment checks | Pre-deploy verification |

### Code Quality & Review
**Re-enable when:** Doing comprehensive PR reviews, large refactors, or quality audits.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `pr-review-toolkit@claude-plugins-official` | **6 agents (~33KB)**: silent-failure-hunter, type-design-analyzer, pr-test-analyzer, comment-analyzer, code-reviewer, code-simplifier | Thorough PR reviews (biggest single token cost) |
| `code-refactoring@claude-code-workflows` | Legacy modernizer, code reviewer agents | Large-scale refactoring |
| `quality-tools@cc-skills` | Multi-agent profiling, schema validation, dead-code detection, pre-ship review | Quality audits before release |
| `security-scanning@claude-code-workflows` | security-auditor + threat-modeling-expert agents | Active security scanning |

### Language-Specific (Advanced)
**Re-enable when:** Doing systems programming in Rust/Go/C or need advanced language patterns beyond what python-development and javascript-typescript provide.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `systems-programming@claude-code-workflows` | Rust async, Go concurrency, C memory safety | Rust/Go/C projects |

### Specialized Tools
**Re-enable when:** Building Agent SDK apps, generating documents, managing dotfiles with chezmoi, or building frontend UIs.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `agent-sdk-dev@claude-plugins-official` | Agent SDK app scaffolding + verification (TS + Python) | Claude Agent SDK development |
| `frontend-design@claude-plugins-official` | Production UI with Tailwind, accessibility, responsive design | Frontend/UI projects |
| `doc-tools@cc-skills` | LaTeX builds, Pandoc PDF generation, ASCII diagrams, academic PDF conversion | Document generation, academic work |
| `dotfiles-tools@cc-skills` | Chezmoi sync, drift checking workflows | Chezmoi-based dotfile management (you have `update-dotfiles` skill already) |

### Already Disabled (kept disabled)

| Plugin | Why |
|--------|-----|
| `cc_chrome_devtools_mcp_skill` | Replaced by claude-in-chrome MCP |
| `github@claude-plugins-official` | Use gh CLI directly |
| `superpowers@claude-plugins-official` | Duplicate of marketplace version |
| `interface-design@interface-design` | Zero usage, niche |

## Kept Plugins (27 plugins)

| Category | Plugins | Why Kept |
|----------|---------|----------|
| Core (5) | superpowers, superpowers-dev-for-cc, elements-of-style, compound-engineering, explanatory-output-style | Foundational skills, plan mode, Context7 MCP |
| Workflow (7) | commit-commands, git-pr-workflows, tdd-workflows, debugging-toolkit, plugin-dev, shell-scripting, ralph-loop | Daily tools confirmed by JSONL session search |
| Language (2) | python-development, javascript-typescript | Active Python/TS work. orchestrate.md updated with invoke triggers |
| Quality (1) | code-simplifier | 2 sessions confirmed usage. Operates on code (complements elements-of-style for prose) |
| MCP (1) | repomix-mcp | Direct MCP server access (tools, not just skills) |
| LSP (5) | typescript, pyright, rust-analyzer, lua, swift | Near-zero cost — no agent descriptions injected |
| Emporium (6) | praetorian, orator, gladiator, historian, oracle, vigil | Custom tools, low overhead |

## Result

63 enabled -> 27 enabled. ~10k tokens saved per session from agent descriptions.
