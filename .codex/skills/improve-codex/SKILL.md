---
name: improve-codex
description: Keep this machine's Codex setup best-in-class and current. Use when the user asks to improve, audit, update, benchmark, research, or troubleshoot Codex, ChatGPT macOS/iOS integration, Codex config, Codex skills/plugins/MCP, model defaults, notifications, appshots, Computer Use, or dotfiles AI guidance.
---

# Improve Codex

Maintain Codex without copying Claude's heavier architecture. Prefer one clean
default, current docs, and measured changes.

## Workflow

1. Inspect local truth first:
   - `codex --version`
   - `codex doctor --all`
   - `codex features list`
   - `codex debug models`
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
5. Recommend the smallest durable change:
   - docs in `~/.ai` for shared policy
   - `~/.ai/codex/config.toml` for safe defaults
   - this skill only for repeated Codex-maintenance workflow
   - local `~/.codex/config.toml` merge through `~/.ai/setup codex`

## Defaults

- Codex TUI is the normal Codex surface for repo work.
- Codex.app and ChatGPT.app provide notifications, mobile control, appshots,
  browser, and Computer Use.
- Use `gpt-5.5` standard tier with high reasoning by default.
- Avoid persistent Fast mode; use `/fast on` only for short latency-sensitive work.
- Do not track Codex auth, SQLite, history, logs, sessions, plugin caches, or app
  runtime state.

## Output

Report:

- local health findings
- current-docs findings
- real-user findings when researched
- proposed dotfiles changes
- validation commands run and remaining manual macOS gates
