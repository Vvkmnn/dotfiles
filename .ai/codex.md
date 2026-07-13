# Codex

Codex is one AI CLI in the family beside Claude and any other useful LLM tool.
Claude can remain the owner's primary surface; Codex should still be configured
as an independent strong second opinion. Keep its setup clean: TUI for Codex
repo work, desktop app for macOS/iOS integration, one maintenance skill, no
profile sprawl.

## When using Codex

- Start in the repo: `codex`
- Use `/plan` for complex or ambiguous work.
- The model manages automatic compaction. Use `/compact` manually only when a
  long session has accumulated irrelevant context or changed direction.
- The composer starts in Vim normal mode; use `/vim` to toggle when needed.
- Use `/fast on` only for short latency-sensitive turns; leave persistent Fast
  mode off.
- Use `/model` when the task clearly needs a different model; otherwise keep the
  default.
- Use `/review` before committing meaningful code changes.
- Use `codex resume --last` when continuing recent TUI work.

## Codex model policy

- Codex default: `gpt-5.6-sol`, standard tier, medium reasoning.
- Use `gpt-5.6-sol` for hardest coding, architecture, security, and judgment.
- Use `gpt-5.6-terra` for balanced high-volume review or everyday second opinions.
- Use `gpt-5.6-luna` for quick scans, summaries, and cheap mechanical passes.
- Plan mode defaults to high reasoning. Use a one-shot high-effort Sol invocation
  for critical reviews; do not make maximum effort the daily default.
- Prefer `/model` for a deliberate task-specific switch instead of maintaining
  profiles or automatic routers.
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

## Autonomy and safety

- Normal local default: `workspace-write` with `on-request` approvals and network
  access. Codex can edit, test, install project dependencies, and research without
  turning the whole home directory into an unrestricted execution target.
- A managed app, CI runner, or hosted session may override that policy. Treat
  `codex doctor --all` as the truth about the effective session, not just the file.
- Do not set `danger-full-access` globally. Use it only for an explicitly isolated
  environment or a single trusted invocation where the OS boundary is elsewhere.
- Do not enable automatic approval review globally: it adds model calls while
  retaining the same sandbox. The owner remains the escalation gate by default.

## Parallel work

- Use subagents for two or three independent read-heavy investigations, tests, or
  reviews—not as the default shape of every task.
- Keep one writer per worktree. Give parallel writers separate git worktrees, then
  review a stable diff before integration.
- Pass plans, diffs, commands, and result files between Claude and Codex. Do not
  rely on hidden conversational state or majority voting.
- Shared machine and handoff policy lives in `~/.ai/fleet.md`.

## Claude bridge

`~/.ai/setup codex` installs OpenAI's `codex@openai-codex` Claude plugin when the
Claude CLI is present. Restart Claude after first install, then run
`/codex:setup --disable-review-gate`. The plugin uses the same local Codex binary,
authentication, config, checkout, and usage allowance as the TUI.

Use it selectively for independent review, design challenges, handoff, or bounded
delegation. The Claude `second-opinion` skill owns the operational command routing,
read-only boundary, and rare high-effort override so those details have one source
of truth. Do not enable the automatic review gate. Other providers remain opt-in
and must not receive sensitive code implicitly.

Healthy setup output reports authenticated Codex, advanced runtime available,
`reviewGateEnabled: false`, and no unexpected running jobs. Re-run
`/codex:status --all` when a background review appears stuck.

The plugin starts caller-owned app-server processes as needed. `codex doctor`
showing app-server idle in ephemeral mode is healthy; do not run a daemon merely
to remove that idle line.

## Reference patterns

The setup deliberately borrows narrow, verified ideas rather than cloning another
person's framework:

- [Jess Frazelle's dotfiles](https://github.com/jessfraz/dotfiles/blob/main/.codex/AGENTS.md): concrete repo commands, drift checks, and explicit git-write restraint.
- [Feiskyer's Codex settings](https://github.com/feiskyer/codex-settings): workspace-scoped autonomy and reproducible configuration; no provider/profile sprawl here.
- [Trail of Bits skills](https://github.com/trailofbits/skills): independent, scoped second opinions at risk boundaries; no duplicate skill pack.
- [Garry Tan's gstack Codex preflight](https://github.com/garrytan/gstack/blob/main/codex/SKILL.md): verify executable, version, auth, and isolated results before trusting delegation.
- [Jesse Vincent's Superpowers](https://github.com/obra/superpowers): evidence before completion and fresh review; no always-on multi-skill workflow.
- [OpenAI Codex security guidance](https://learn.chatgpt.com/docs/agent-approvals-security): workspace-write plus on-request as the balanced local preset.

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
plugins, or macOS integration may have drifted. It should verify current docs,
the OpenAI Claude plugin, effective sandbox, and local state before recommending
changes. Update the plugin deliberately rather than updating every plugin during
normal machine setup.

## Multi-model ecosystem

- Claude is allowed to lead the work; Codex should provide independent OpenAI
  judgment, not mirror Claude's assumptions.
- For second opinions, prefer fresh context and tight prompts. Ask Codex for
  concrete risks, missed cases, or reasons to reject a proposed change.
- Do not fan out to weaker/free third-party models for sensitive code. Use them
  only when privacy and reliability are acceptable.
- Synthesize disagreements by reasoning quality, not vote count.

Health checks:

```sh
codex doctor --all
codex features list
codex debug models
git --git-dir=$HOME/.dotfiles --work-tree=$HOME status --short
```

If `codex doctor` reports DNS/reachability failures inside a sandbox, separate
that from real auth/config/state failures.
