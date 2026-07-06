# AI

This dotfiles repo uses `~/.ai/` as the shared AI operating layer.

Read these first:

- `~/.ai/README.md` — machine setup mission, secrets, and runbook
- `~/.ai/codex.md` — Codex TUI/App defaults and maintenance
- `~/.ai/chatgpt.md` — ChatGPT macOS/iOS integration

Rules:

- Keep tool-specific folders thin; do not duplicate shared policy.
- Use `op` and git-crypt for secrets; never track local auth/session/runtime state.
- Prefer simple defaults over profiles, hooks, or skills until repeated usage proves value.
- Verify with concrete commands before claiming setup is healthy.
