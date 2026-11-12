---
name: analyze-usage
author: Vvkmnn
description: Use when the owner asks what they spent Claude tokens/money on, usage over time, cost or tokens per project/model/session, "where did my usage go", or wants to analyze the local telemetry ledger. Answers how/when/where/what-model/why from the raw per-host ledgers the statusline writes.
version: 0.1.0
---

# Analyze Usage

The statusline (`~/.claude/statusline.sh` → `_append_telemetry`) writes a raw, append-only
usage ledger, one JSON row per fresh haiku probe (~2 min), **git-crypt encrypted**, one file
per machine. Schema reference: `~/.claude/docs/CONFIG.md` → **Telemetry ledger**.

- **Files:** `~/.claude/status/telemetry-*.jsonl` (glob = whole fleet once synced; `host` field distinguishes). Ignore `*.v1flat` / `*.migrated` (old schema — the glob already excludes them).
- **Row:** `{v, ts, host, rl, in}` — `rl` = whole `rate_limit.json`, `in` = whole Claude Code statusline stdin, verbatim (nothing dropped). Flatten at read time.

## THE gotcha (read first)

`in.cost.total_cost_usd`, `in.context_window.total_input_tokens/total_output_tokens`, and the
`total_lines_*` are **cumulative per session**. To get a session's spend, take the **max row
per `session_id`** — never sum rows (that double-counts). To get spend in a *time window*, diff
consecutive rows within a session. Cache fields under `current_usage` are point-in-time, not cumulative.

## Recipes (proven, copy-paste)

Run from `~/.claude/status`. All glob `telemetry-*.jsonl` (fleet-wide).

**What you spent tokens on — per session, cost desc:**
```sh
jq -rs '[.[]|select(.in.session_id)]|group_by(.in.session_id)
 |map(max_by(.in.cost.total_cost_usd//0) as $r|{name:($r.in.session_name//"?"),
   proj:(($r.in.workspace.project_dir//$r.in.cwd)|split("/")|last),
   model:(($r.in.model.id//$r.in.model)|sub("claude-";"")),cost:($r.in.cost.total_cost_usd//0),
   tin:($r.in.context_window.total_input_tokens//0),tout:($r.in.context_window.total_output_tokens//0),
   dl:(($r.in.cost.total_lines_added//0)-($r.in.cost.total_lines_removed//0))})
 |sort_by(-.cost)|.[]|["$"+((.cost*100|round)/100|tostring),.model,.proj,
   (.tin/1000|round|tostring)+"k",(.tout/1000|round|tostring)+"k",(.dl|tostring),.name]|@tsv' \
 telemetry-*.jsonl | column -t -s $'\t'
```

**Rollup by project / model / host** — swap the `group_by` key and sum the per-session maxes:
```sh
jq -rs '[.[]|select(.in.session_id)]|group_by(.in.session_id)|map(max_by(.in.cost.total_cost_usd//0))
 |group_by(.in.model.id//.in.model)|map({k:(.[0].in.model.id//.[0].in.model),
   cost:(map(.in.cost.total_cost_usd//0)|add),n:length})|sort_by(-.cost)|.[]
 |["$"+((.cost*100|round)/100|tostring),(.n|tostring),.k]|@tsv' telemetry-*.jsonl | column -t -s $'\t'
```
(For project: `group_by(.in.workspace.project_dir // .in.cwd)`. For host: `group_by(.host)`.)

**Why each session — kickoff prompt** (recycle the transcript we captured at `.in.transcript_path`):
```sh
jq -rs '[.[]|select(.in.session_id)]|group_by(.in.session_id)|map(max_by(.in.cost.total_cost_usd//0))
 |sort_by(-(.in.cost.total_cost_usd//0))|.[]|[(.in.session_name//"?"),(.in.transcript_path//"")]|@tsv' \
 telemetry-*.jsonl | while IFS=$'\t' read -r name tpath; do
   [ -f "$tpath" ] && q=$(jq -rc 'select(.type=="user" and (.isMeta|not))
     |(.message.content)|if type=="array" then (map(select(.type=="text").text)|join(" ")) else . end' \
     "$tpath" 2>/dev/null | grep -vE '^\s*$|<(command|system)-' | head -1 | cut -c1-140)
   printf '● %-30s ↳ %s\n' "$name" "${q:-?}"; done
```

**When — hour × day-of-week activity** (bucket `ts`): group rows by `strftime` of `.ts` into a
7×24 grid; count distinct `session_id` or sum cost deltas per bucket. `ts` is epoch UTC — adjust for local tz.

**Landscape / limit-drift** (the one thing transcripts *can't* give): `rl.five_hour.utilization`
over `ts` shows your position vs Anthropic's cap. There is **no absolute-limit header**, so detect
allowance changes via `utilization ÷ true-spend-in-window` — a step-change means Anthropic moved your ceiling.

## Notes

- `session_name` is a free human-readable topic label (e.g. `tmux-crash-recovery-system`) — often answers "what" without touching transcripts.
- `[1m]` in `model.id` = 1M-context tier (premium pricing) — usually the cost driver; break it out.
- Missing fields are `null` (jq handles gracefully). `rl` shape can vary when `_source != "haiku_probe"` (oauth fallback) — guard with `//`.
- The ledger is Anthropic's own numbers (not a `ccusage`/LiteLLM estimate) — trust `total_cost_usd` as authoritative.
- Deferred: a packaged `telemetry-report` command + 7×24 heatmap render. These recipes are the substrate.
