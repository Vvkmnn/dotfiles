# .setup — frozen reference (NOT the live setup)

> The live, self-contained setup is **`~/.ai/setup`**. This folder is historical
> reference and update context: read it to understand *why*, copy minimal logic
> *from* it — but never wire it *into* `~/.ai/setup`.

## The two folders

|                | `~/.ai/`                          | `~/.setup/` (here)                         |
|----------------|-----------------------------------|--------------------------------------------|
| Role           | **live source of truth**          | **frozen reference / history**             |
| Entry          | `setup` — one self-contained file | `AI.md` runbook + per-tool `*.sh`          |
| Package list   | inline in `setup`                 | `Resources/Brewfile` (older, fuller)       |
| macOS defaults | inline in `setup` (`phase_macos`) | `macos.sh` (older, fuller)                 |
| Run it?        | **yes**                           | **no** — reference only                    |

## Rule: keep `~/.ai/setup` self-contained

`~/.ai/setup` inlines everything it needs — package list, macOS defaults, phases.
Do **not** make it `source` anything in this folder: not `ai/gate.sh`, `ai/ux.sh`,
`macos.sh`, or any per-tool script. If `setup` needs a behavior that lives here,
copy the minimal logic inline. Self-contained means you can point an LLM at one
file and it just runs — no hidden dependency on a reference tree.

> This README exists because that mistake is easy to make: you land in
> `~/.setup/ai/gate.sh`, see a tidy helper, and reach to wire it in. Don't.

## Runtime model: LLM-driven, gates relayed in chat

A person plus an LLM (Claude) run the setup together, in one session. For the
steps macOS won't let a script do — TCC grants (Accessibility / Input
Monitoring), system-extension approvals, appearance toggles like **Reduce
Transparency** (TCC-protected: `defaults write com.apple.universalaccess` is
silently refused on Tahoe) — the LLM opens the System Settings pane, asks the
owner to flip it, and verifies with a probe (`defaults read …`). Conversationally.

The older `AI.md` + `ai/gate.sh` path is **legacy**: Claude reads `AI.md`
top-to-bottom, and `gate.sh` fires an **iPhone notification** then blocks on a
bash `read` loop. That assumes the owner walked away from the terminal. In the
LLM-driven model the owner is *in* the session — the LLM is the notification
channel, so there's no iPhone ping and no bash prompt loop.

## What's here

- `AI.md` — original top-to-bottom bootstrap runbook (legacy iPhone-gate model).
- `ai/` — `gate.sh` (iPhone-ping manual-gate loop), `ux.sh` (box drawing),
  `doctor.sh` (verify). Reference; **not** sourced by `~/.ai/setup`.
- `Resources/` — `Brewfile`, `Brewfile.server` (older, fuller package sets).
- `macos.sh`, `osxprep.sh`, `theme.sh`, per-tool `*.sh` — the laptop's original
  granular scripts. Mined for inline logic in `~/.ai/setup`, not run directly.
- `Archive/` — superseded scripts kept for history.

## When you change `~/.ai/setup`

Edit the inline list/defaults **there**. Optionally backport notable changes into
the matching reference file here so the history stays meaningful — but the
reference never drives a run.
