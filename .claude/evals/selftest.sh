#!/bin/bash
# selftest.sh — quota-free baseline of the Claude setup. Runs in seconds, no model calls.
# Prints one line per check and appends `kind: component` rows to evals/ledger.jsonl so every
# run is a dated, comparable baseline. bench.sh is the quota-costing layer above this.
#
# Checks: settings.json valid · every hook parses · safety-hook test suite · statusline renders
# the documented sample JSON correctly (field alignment + waiting flag) under 100 ms · subagent
# line renders · plugin always-on token sum · counts (plugins, agents, skills, rules lines) ·
# dotfiles drift · Claude Code version.
set -uo pipefail

readonly C="$HOME/.claude"
readonly LEDGER="$C/evals/ledger.jsonl"
readonly TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
fails=0

row() { # component metric value [note]
	jq -nc --arg ts "$TS" --arg c "$1" --arg m "$2" --argjson v "$3" --arg note "${4:-}" \
		'{ts:$ts,kind:"component",component:$c,metric:$m,value:$v,arm:"",task:"",run:0,source:"selftest.sh",note:$note}' >> "$LEDGER"
}
ok()   { printf 'ok    %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; fails=$((fails + 1)); }
check() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$name"; row "check:$name" pass 1; else fail "$name"; row "check:$name" pass 0; fi; }

mkdir -p "$(dirname "$LEDGER")"
echo "selftest $TS · claude $(claude --version 2>/dev/null | head -1)"

check settings-json-valid jq empty "$C/settings.json"
for h in "$C"/hooks/*.js "$C"/hooks/lib/*.js; do check "hook-syntax:$(basename "$h")" node --check "$h"; done
check hook-tests node "$C/hooks/pre-tool-use.test.js"
check waiting-flag-tests node "$C/hooks/waiting-flag.test.js"
# tmux best-of-day keeper (lambda.sh keep_daily): today's copy must exist once a save has run today.
check tmux-daily-keep test -s "$HOME/.local/share/tmux/resurrect/pinned/daily/tmux_resurrect_$(date +%Y%m%d).txt"

# --- statusline: alignment is asserted on a known sample (a shifted field can never pass) ---
now=$(date +%s)
# Sample renders must never feed the real usage ring: point it at a scratch file for this run.
ring="${TMPDIR:-/tmp}/selftest-usage-ring.tsv"; export CLAUDE_USAGE_RING="$ring"; rm -f "$ring"
export CLAUDE_STATUSLINE_WAITING="0:"   # pin the ? count: the live tmux flags must not reach a sample render
sample=$(printf '{"cwd":"%s","model":{"id":"claude-opus-5-5"},"workspace":{"current_dir":"%s"},"cost":{"total_cost_usd":12.34,"total_duration_ms":7200000,"total_api_duration_ms":2880000},"context_window":{"context_window_size":1000000,"used_percentage":51.4},"prompt_cache":{"warm":true,"hit_ratio":0.94},"effort":{"level":"high"},"thinking":{"enabled":true},"rate_limits":{"five_hour":{"used_percentage":40,"resets_at":%d},"seven_day":{"used_percentage":30,"resets_at":%d}},"vim":{"mode":"NORMAL"},"pr":{"number":1234,"review_state":"pending"}}' "$HOME" "$HOME" $((now + 2880)) $((now + 561600)))
start=$(date +%s%N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1e9))')
line=$(printf '%s' "$sample" | COLUMNS=140 "$C/statusline.sh" | sed $'s/\e\\[[0-9;]*m//g')
end=$(date +%s%N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1e9))')
ms=$(( (end - start) / 1000000 ))
for tok in 'Oᵀ⁺' '? 0' 'ψ 51%' 'λ 30%' '(40% 5h)' 'τ 6d' '#1234' '$ 12'; do
	if printf '%s' "$line" | grep -qF -- "$tok"; then ok "statusline:$tok"; else fail "statusline:$tok  (line: $line)"; fi
done
row statusline render_ms "$ms"
# v4 renders in 95–105 ms warm (v3 was 87); the first cold run of a session lands near 150, so the budget is 200.
[ "$ms" -lt 200 ] && ok "statusline:render ${ms}ms" || fail "statusline:render ${ms}ms (budget 200)"
# --- λ burn rate: a quiet baseline is never red; a burst (5h 5→40 % and 7d 20→30 % in 20 min) is.
# Red is the only signal (no "!"), so the raw escape sequence is what the check reads. ---
red=$'\e[38;2;232;36;36m'
raw=$(printf '%s' "$sample" | "$C/statusline.sh")
case "$raw" in *"λ"*"${red}30%"*) fail "statusline:baseline must not be red (line: $line)" ;; *) ok "statusline:baseline not red" ;; esac
printf '%s\t5\t20\n%s\t20\t25\n' "$((now - 2400))" "$((now - 600))" > "$ring"   # 30 min of samples: the projection's minimum
burst=$(printf '%s' "$sample" | "$C/statusline.sh")
case "$burst" in *"${red}30%"*) ok "statusline:burst renders λ red" ;; *) fail "statusline:burst not red (line: $(printf '%s' "$burst" | sed $'s/\e\\[[0-9;]*m//g'))" ;; esac
# --- fit: at every width the row is never wider than the pane (cells, colour codes stripped) ---
for cols in 160 140 95 70 63 50 36; do
	wline=$(printf '%s' "$sample" | COLUMNS="$cols" "$C/statusline.sh" | sed $'s/\e\\[[0-9;]*m//g')
	[ "${#wline}" -le "$cols" ] && ok "statusline:fits ${cols} (${#wline})" || fail "statusline:overflow at ${cols}: ${#wline} cells (line: $wline)"
done
rm -f "$ring"
# --- ?N: a stub tmux reports two waiting panes -> "?2" after the λ group ---
stub="${TMPDIR:-/tmp}/selftest-tmux"; printf '#!/bin/sh\ncase "$1" in list-panes) printf "1\\tclaude\\n\\tzsh\\n1\\tnode\\n1\\tzsh\\n";; *) printf "";; esac\n' > "$stub"; chmod +x "$stub"
nline=$(printf '%s' "$sample" | CLAUDE_STATUSLINE_WAITING= TMUX=stub CLAUDE_TMUX_BIN="$stub" "$C/statusline.sh" | sed $'s/\e\\[[0-9;]*m//g')
case "$nline" in *'? 2'*) ok "statusline:?N counts waiting panes" ;; *) fail "statusline:?N missing (line: $nline)" ;; esac
rm -f "$stub"
check subagent-statusline sh -c 'echo "{\"tasks\":[{\"id\":\"t\",\"agentType\":\"Explore\",\"status\":\"running\",\"tokenCount\":5,\"tokenSamples\":[5]}]}" | '"$C"'/subagent-statusline.sh | grep -q "\"id\":\"t\""'

# --- cost and size numbers (the "are we leaner" metrics) ---
plugins=$(jq '[.enabledPlugins|to_entries[]|select(.value==true)]|length' "$C/settings.json")
row plugins enabled "$plugins"; ok "plugins enabled: $plugins"
if [ "${SELFTEST_PLUGIN_COST:-0}" = "1" ]; then
	total=0
	for p in $(jq -r '.enabledPlugins|to_entries[]|select(.value==true)|.key' "$C/settings.json"); do
		t=$(claude plugin details "$p" 2>/dev/null | grep -oE 'Always-on:\s+~?[0-9.]+k?' | grep -oE '[0-9.]+k?' | head -1)
		case "$t" in *k) t=$(awk -v v="${t%k}" 'BEGIN{printf "%d", v*1000}') ;; esac
		total=$((total + ${t:-0}))
	done
	row plugins always_on_tokens "$total"; ok "plugins always-on tokens: $total"
fi
rules=$(cat "$C"/rules/*.md "$C/CLAUDE.md" | wc -l | tr -d ' ');   row rules lines "$rules";   ok "always-loaded instruction lines: $rules"
agents=$(ls "$C"/agents/*.md | wc -l | tr -d ' ');                  row agents count "$agents"; ok "agents: $agents"
skills=$(ls -d "$C"/skills/*/ | wc -l | tr -d ' ');                 row skills count "$skills"; ok "skills: $skills"
drift=$(/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --short 2>/dev/null | wc -l | tr -d ' ')
row dotfiles uncommitted_files "$drift"; ok "dotfiles uncommitted files: $drift"
gen=$(/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" tag -l 'gen/*' --sort=-creatordate | head -1)
ok "generation: ${gen:-none yet}"

# --- research routes (station 9, 2026-11-04): retired MCPs never referenced again; no write-capable allow rule ---
retired=$(grep -rlE 'mcp__(hackernews|stackoverflow|brave_search|twitter|apify|rss|magic_ui|paper_search)__' "$C/CLAUDE.md" "$C/rules" "$C/skills"/*/SKILL.md "$C/agents" 2>/dev/null | grep -v '/\.archive/' | tr '\n' ' ')
[ -z "$retired" ] && ok "research: no retired MCP referenced" || fail "research: retired MCP referenced in: $retired"
# `gh api *` and `curl *` stay allowed for reads; the hook asks when a method or body flag makes them writes.
writes=$(jq -r '.permissions.allow[]' "$C/settings.json" | grep -E '^Bash\((git push|gh (pr (close|merge|comment|edit|review|ready|create)|issue (create|close|comment|edit|delete)|release (create|delete|edit|upload)|repo (create|delete|edit|archive|fork|sync))|opencli [a-z0-9-]+ (login|post|reply|like|delete|create|update|upload|send|publish|buy|pay))' | tr '\n' ' ')
[ -z "$writes" ] && ok "permissions: no unguarded write allow rule" || fail "permissions: unguarded write allow rule: $writes"
for c in 'gh api -X POST repos/o/r/issues' 'curl -d x https://h' 'gh pr close 3'; do
	d=$(printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$c" | node "$C/hooks/pre-tool-use.js" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecision // "none"')
	[ "$d" = ask ] && ok "hook asks: $c" || fail "hook does not ask for: $c ($d)"
done

echo "selftest: $fails failure(s)"
exit "$fails"
