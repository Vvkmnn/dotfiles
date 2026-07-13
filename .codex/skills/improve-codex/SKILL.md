---
name: improve-codex
description: Keep this machine's Codex setup best-in-class and current. Use when the user asks to improve, audit, update, benchmark, research, or troubleshoot Codex, ChatGPT macOS/iOS integration, Codex config, Codex skills/plugins/MCP, model defaults, notifications, appshots, Computer Use, or dotfiles AI guidance.
---

# Improve Codex

Maintain Codex without copying Claude's heavier architecture. Claude may be the
owner's primary surface; Codex should stay an independent, current, high-quality
OpenAI lens. Prefer one clean default, current docs, and measured changes.

## Workflow

1. Inspect local truth first:
   - `codex --version`
   - `codex doctor --all`
   - `codex features list`
   - `codex debug models`
   - `claude plugin list` when the Claude bridge matters
   - `git --git-dir=$HOME/.dotfiles --work-tree=$HOME status --short`
2. Read shared policy:
   - `~/.ai/README.md`
   - `~/.ai/codex.md`
   - `~/.ai/chatgpt.md` when app or mobile integration matters
3. Refresh official Codex docs with the `openai-docs` skill before making claims
   about current Codex behavior, models, config keys, skills, plugins, hooks, MCP,
   automations, or app features.
4. Research real user practice when the user asks for best-in-class standards.
   Separate verified examples from speculation; do not invent public config
   patterns when search evidence is weak.
5. Compare against three to seven current references before changing defaults:
   official OpenAI docs/local Codex catalog plus verified public patterns such as
   Jess Frazelle's dotfiles, Feiskyer's Codex settings, Trail of Bits skills,
   gstack, or Superpowers. Borrow principles; do not install frameworks by default.
6. Recommend the smallest durable change:
   - docs in `~/.ai` for shared policy
   - `~/.ai/codex/config.toml` for safe defaults
   - this skill only for repeated Codex-maintenance workflow
   - local `~/.codex/config.toml` merge through `~/.ai/setup codex`

## Defaults

- Codex TUI is the normal Codex surface for repo work.
- Codex.app and ChatGPT.app provide notifications, mobile control, appshots,
  browser, and Computer Use.
- Use `gpt-5.6-sol` standard tier with medium reasoning by default.
- Use high reasoning for plan mode and rare important consultations.
- Route to `gpt-5.6-terra` for balanced volume work and `gpt-5.6-luna` for quick
  scans only when cost or latency beats maximum judgment quality.
- Escalate effort to `xhigh`, `max`, or `ultra` selectively; do not treat maximum
  effort as the default answer to every task.
- Avoid persistent Fast mode; use `/fast on` only for short latency-sensitive work.
- Leave the auto-compaction threshold unset so the active model owns it.
- Start the TUI composer in Vim normal mode and keep unfocused completion and
  approval notifications enabled.
- Prefer `workspace-write` + `on-request` + workspace network locally. Distinguish
  config intent from an app/managed session's effective sandbox before diagnosing.
- Use bounded subagents only for independent reads, tests, or reviews; keep one
  writer per worktree.
- Prefer OpenAI's `codex@openai-codex` Claude plugin for review lifecycle and
  handoff. Keep the local Claude `second-opinion` skill as thin policy, never an
  automatic review gate or duplicate plugin implementation.
- Do not track Codex auth, SQLite, history, logs, sessions, plugin caches, or app
  runtime state.

## Output

Report:

- local health findings
- current-docs findings
- real-user findings when researched
- proposed dotfiles changes
- validation commands run and remaining manual macOS gates
