# Codex

Codex is one AI CLI in the family beside Claude and any other useful LLM tool.
Keep its setup clean: TUI for Codex repo work, desktop app for macOS/iOS
integration, one maintenance skill, no profile sprawl.

## When using Codex

- Start in the repo: `codex`
- Use `/plan` for complex or ambiguous work.
- Use `/compact` before context quality drops, not after the model is already
  struggling.
- Use `/fast on` only for short latency-sensitive turns; leave persistent Fast
  mode off.
- Use `/model` when the task clearly needs a different model; otherwise keep the
  default.
- Use `/review` before committing meaningful code changes.
- Use `codex resume --last` when continuing recent TUI work.

## Codex model policy

- Codex default: `gpt-5.5`, standard tier, high reasoning.
- Escalate to `xhigh` only for hard architecture, debugging, security, or deep
  research loops.
- Use lighter models only when cost/latency matters more than depth.
- Do not optimize for maximum token burn. Optimize for useful completed work.

## Config policy

`~/.codex/config.toml` is local runtime state plus personal defaults. Do not
commit it raw.

Tracked source of truth:

- `~/.ai/codex/config.toml` — safe template for defaults only
- `~/.codex/AGENTS.md` — small Codex compatibility shim pointing to `~/.ai`
- `~/.codex/skills/improve-codex/SKILL.md` — one maintenance skill

Local-only state:

- auth tokens
- SQLite databases
- sessions/history/logs
- plugin cache and marketplaces
- app-server and Computer Use runtime files
- generated app/plugin MCP blocks

## macOS integration

Use the Codex TUI when you choose Codex for repo work. Use Codex.app and
ChatGPT.app for:

- desktop notifications
- ChatGPT iOS remote control
- Appshots
- in-app browser
- Computer Use when a GUI is truly required

Manual gates live in macOS System Settings:

- Notifications for Codex and ChatGPT
- Accessibility for Codex Computer Use when needed
- Screen Recording for Appshots/Computer Use
- Input Monitoring only when a tool explicitly requires it

Keep locked Computer Use disabled unless this Mac is intentionally configured as
an always-on host.

## Maintenance

Run the `improve-codex` skill when Codex behavior, config, models, skills,
plugins, or macOS integration may have drifted. It should verify current docs and
local state before recommending changes.

Health checks:

```sh
codex doctor --all
codex features list
codex debug models
git --git-dir=$HOME/.dotfiles --work-tree=$HOME status --short
```

If `codex doctor` reports DNS/reachability failures inside a sandbox, separate
that from real auth/config/state failures.
