---
name: second-opinion
author: Vvkmnn
description: >
  Get a fresh Codex opinion at high-value gates. Use for meaningful code review,
  architecture or security challenges, risky migrations, concurrency, data loss,
  hard bugs, or genuine uncertainty. Prefer the official OpenAI Codex plugin;
  keep reviews read-only and synthesize evidence rather than model votes.
version: 3.0.0
---

# Second Opinion

Claude may lead. Codex supplies an independent OpenAI lens with fresh context.
Use it where disagreement can materially improve the result, not on every turn.

## Route

Prefer the official `codex@openai-codex` plugin:

- `/codex:review --background` — normal review of meaningful current changes.
- `/codex:review --base <ref> --background` — branch review.
- `/codex:adversarial-review --background <focus>` — challenge architecture,
  assumptions, security, rollback, races, data loss, or reliability.
- `/codex:status`, `/codex:result`, `/codex:cancel` — background lifecycle.
- `/codex:transfer` — continue the handoff in Codex TUI or Codex.app.
- `/codex:rescue` — only when the owner explicitly asks Codex to investigate or
  implement a bounded task.

Do not enable the plugin's automatic review gate. It can create expensive loops
and turns a selective second opinion into background policy.

## Important consultation

The plugin inherits the normal Codex config, which is deliberately Sol at medium
effort. For a rare critical consultation, use a one-shot high-effort review:

```sh
codex exec review --uncommitted --ephemeral --strict-config \
  --model gpt-5.6-sol -c 'model_reasoning_effort="high"' \
  -c 'approval_policy="never"' -c 'sandbox_mode="read-only"'
```

For a focused question outside native review mode, keep the run ephemeral and
read-only:

```sh
codex exec --ephemeral --strict-config --skip-git-repo-check \
  --model gpt-5.6-sol -c model_reasoning_effort=high \
  -c approval_policy=never --sandbox read-only \
  "Give a blunt independent technical opinion. Identify concrete risks, missed cases, and reasons to reject the proposed approach."
```

Use the direct CLI only when the plugin is unavailable or the important review
needs an explicit effort override. Never use the dangerous bypass flags.

## Write boundary

- Reviews are read-only.
- A write-capable rescue requires an explicit owner request and bounded scope.
- Give concurrent writers separate git worktrees; keep one writer per checkout.
- Claude or the owner reviews the resulting diff and reruns relevant tests.

## Synthesis

Return:

1. Agreements that materially increase confidence.
2. Codex findings Claude missed.
3. Disagreements, resolved by evidence and reasoning quality.
4. The resulting recommendation and any required verification.

An error, timeout, empty result, or rate limit is inconclusive. Report it plainly;
never fabricate a clean verdict. Other model providers are opt-in only: do not
auto-fan-out, promise free usage, or send sensitive code elsewhere without the
owner's explicit request.
