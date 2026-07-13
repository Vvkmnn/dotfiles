# AI Fleet

This is the shared contract for Claude, Codex, and any later AI surface across
the owner's Macs. Tool-specific skills may provide commands, but policy lives
here.

## Topology

| Host | Role |
|---|---|
| `vminim4` | future always-on hub for long, heavy, or remotely supervised work |
| `vbookairm3` | mobile general-purpose machine |
| `vbookneoa18` | light mobile machine |

Use the current machine for interactive work. Route long builds, durable tmux
sessions, or remote automation to the Mini once it is commissioned.

## Three layers

1. **Machine:** Tailscale, SSH, mosh, and tmux provide reachability and continuity.
2. **Worktree:** one AI writes in a worktree; independent readers may inspect it.
3. **Model:** Claude or Codex may lead. Another model reviews at useful boundaries.

This prevents “multi-agent” from becoming several processes editing the same
files with no ownership boundary.

## Handoff contract

Every delegated task should include:

- repo and worktree path
- objective and explicit non-goals
- relevant files or a stable diff/commit
- commands already run and their results
- expected artifact: plan, patch, review, or test report
- instruction not to commit, push, or rewrite unrelated work unless requested

Return evidence, not just confidence. A disagreement is resolved by reproducing
the claim or inspecting the code—not by model vote.

## Parallelism

- Parallelize independent research, repository scans, tests, or reviews.
- Keep parallel fan-out small—normally two or three workers.
- Never run multiple writers in one worktree.
- Give necessary concurrent writers separate git worktrees and reconcile their
  diffs from a stable base.
- Prefer a fresh independent review after implementation over constant chatter
  between models.

## Cross-machine operation

Use existing fleet helpers and the Claude `ssh-fleet` adapter for exact commands:

- check Tailscale reachability before SSH
- inspect remote work with `tmux list-windows` and `tmux capture-pane`
- send a bounded prompt with `tmux send-keys`, then capture the resulting artifact
- treat pane command and captured output as status; shared `@agent_status` hooks
  are not wired yet
- keep authentication in the 1Password SSH agent; never copy private keys

## Codex app server

Ephemeral mode is correct for local interactive Codex. Do not add a daemon merely
to make a health check green. Reconsider a persistent app server when `vminim4`
becomes the trusted hub and a real remote client needs it; bind access to the
tailnet or an SSH tunnel, never the public internet.

## Secrets and state

Share policy and reproducible config through dotfiles. Keep OAuth tokens, API
keys, sessions, SQLite databases, logs, plugin caches, and process state local.
Use `op` at execution time and git-crypt only for intentionally tracked secrets.
