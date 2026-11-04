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
check pane-session-tests node "$C/hooks/pane-session.test.js"
# --- launcher: `c` resumes this pane's own session (the pane option, with its transcript under this cwd)
# and names a parked background job for this cwd instead of looping. The two zsh functions are lifted
# out of ~/.functions and run against a stub tmux and a scratch HOME. ---
lt="${TMPDIR:-/tmp}/selftest-launcher"; enc=$(printf '%s' "$C" | sed 's|/|-|g; s|\.|-|g'); rm -rf "$lt"; mkdir -p "$lt/home/.claude/projects/$enc" "$lt/home/.claude/sessions"
printf '#!/bin/sh\ncase "$*" in *@claude_session) printf "aaaaaaaa-1111-2222-3333-444444444444\\n";; *@claude_args) printf -- "--plugin-dir /x\\\\ y\\n";; set-option*) printf "%%s\\n" "$*" >> "%s";; esac\n' "$lt/calls" > "$lt/tmux"; chmod +x "$lt/tmux"
echo '{}' > "$lt/home/.claude/projects/$enc/aaaaaaaa-1111-2222-3333-444444444444.jsonl"
printf '{"pid":1,"sessionId":"bbbbbbbb-1111-2222-3333-444444444444","cwd":"%s","kind":"bg"}' "$C" > "$lt/home/.claude/sessions/1.json"
printf '{"pid":2,"sessionId":"cccccccc-1111-2222-3333-444444444444","cwd":"%s","kind":"interactive"}' "$C" > "$lt/home/.claude/sessions/2.json"
awk '/^  __claude_pane_session\(\) \{/,/^  \}/; /^  __claude_parked\(\) \{/,/^  \}/; /^  __claude_pane_args\(\) \{/,/^  \}/; /^  __claude_save_args\(\) \{/,/^  \}/; /^  __claude_live_elsewhere\(\) \{/,/^  \}/' "$HOME/.functions" > "$lt/fns.zsh"
lout=$(cd "$C" && HOME="$lt/home" TMUX=stub TMUX_PANE='%1' CLAUDE_TMUX_BIN="$lt/tmux" zsh -c "source '$lt/fns.zsh' && __claude_pane_session && echo && __claude_parked" 2>&1)
[ "$(printf '%s' "$lout" | sed -n 1p)" = "aaaaaaaa-1111-2222-3333-444444444444" ] && ok "launcher: pane session resolved" || fail "launcher: pane session (got: $lout)"
[ "$(printf '%s' "$lout" | sed -n 2p)" = "bbbbbbbb-1111-2222-3333-444444444444" ] && ok "launcher: parked job named, interactive one not" || fail "launcher: parked (got: $lout)"
lout2=$(cd "$C" && HOME="$lt/home" TMUX=stub TMUX_PANE='%1' CLAUDE_TMUX_BIN="$lt/tmux" zsh -c "source '$lt/fns.zsh'; rm '$lt/home/.claude/projects/-Users-v--claude/aaaaaaaa-1111-2222-3333-444444444444.jsonl'; __claude_pane_session || echo none" 2>&1)
[ "$lout2" = "none" ] && ok "launcher: no transcript under this cwd, no resume" || fail "launcher: stale pane option leaked (got: $lout2)"
# W1: the pane's launch flags come back as separate words, spaces intact; saving quotes them the same way
lout3=$(cd "$C" && HOME="$lt/home" TMUX=stub TMUX_PANE='%1' CLAUDE_TMUX_BIN="$lt/tmux" zsh -c "source '$lt/fns.zsh'; s=\$(__claude_pane_args); a=(\"\${(@Q)\${(z)s}}\"); print -r -- \${#a} \"\${a[2]}\"; __claude_save_args --add-dir '/a b' --model opus; cat '$lt/calls'" 2>&1)
[ "$(printf '%s' "$lout3" | sed -n 1p)" = "2 /x y" ] && ok "launcher: saved flags read back as words" || fail "launcher: flags (got: $lout3)"
case "$lout3" in *"set-option -p -t %1 @claude_args --add-dir '/a b' --model opus"*) ok "launcher: flags saved quoted on the pane" ;; *) fail "launcher: save (got: $lout3)" ;; esac
# W2: a session whose registry entry has a live pid and a pane is "open elsewhere"; a dead pid is not
printf '{"pid":%s,"sessionId":"dddddddd-1111-2222-3333-444444444444","cwd":"%s","kind":"interactive","tmux":"2:@1.%%7"}' "$$" "$C" > "$lt/home/.claude/sessions/3.json"
printf '{"pid":999999,"sessionId":"eeeeeeee-1111-2222-3333-444444444444","cwd":"%s","kind":"interactive","tmux":"2:@1.%%8"}' "$C" > "$lt/home/.claude/sessions/4.json"
lout4=$(cd "$C" && HOME="$lt/home" zsh -c "source '$lt/fns.zsh'; __claude_live_elsewhere dddddddd-1111-2222-3333-444444444444; echo; __claude_live_elsewhere eeeeeeee-1111-2222-3333-444444444444 || echo free" 2>&1)
[ "$(printf '%s' "$lout4" | sed -n 1p)" = "2:@1.%7" ] && ok "launcher: live session elsewhere named by pane" || fail "launcher: live elsewhere (got: $lout4)"
[ "$(printf '%s' "$lout4" | sed -n 2p)" = "free" ] && ok "launcher: dead pid never blocks a resume" || fail "launcher: dead pid (got: $lout4)"
rm -rf "$lt"
# --- the reaper stays dead (it killed seven sessions on 2026-11-02): no live line in the launcher or the
# restore script names claude-idle-checker, and the script itself is not executable ---
for f in "$HOME/.functions" "$HOME/.config/tmux/claude-session-restore.sh"; do
	n=$(grep -v -E '^\s*#' "$f" 2>/dev/null | grep -c 'claude-idle-checker')
	[ "$n" -eq 0 ] && ok "reaper: not armed by ${f##*/}" || fail "reaper: ${f##*/} still names claude-idle-checker ($n lines)"
done
[ ! -x "$HOME/.config/tmux/claude-idle-checker.sh" ] && ok "reaper: script not executable" || fail "reaper: claude-idle-checker.sh is executable"
# --- policy: the settings and options the week's silent killers hid behind (parking, the sweep, a restore that
# launches twelve Claudes, a hook that quietly came unwired); each one that drifts turns this red ---
[ "$(jq -r '.disableAgentView // false' "$C/settings.json")" = "true" ] && ok "policy: disableAgentView on, nothing parks" || fail "policy: disableAgentView is not true in settings.json"
cpd=$(jq -r '.cleanupPeriodDays // 30' "$C/settings.json"); [ "$cpd" -ge 365 ] 2>/dev/null && ok "policy: transcripts kept $cpd days (they are the restore)" || fail "policy: cleanupPeriodDays is $cpd, under 365: the sweep would delete the restore"
grep -q "^set -g @resurrect-processes 'false'" "$HOME/.config/tmux/tmux.conf" && ok "policy: resurrect restores layout only" || fail "policy: @resurrect-processes is not 'false' in tmux.conf"
grep -q "^set -g @resurrect-hook-post-save-all 'bash \$HOME/.config/tmux/claude-panes-save.sh'" "$HOME/.config/tmux/tmux.conf" && grep -q "^set -g @resurrect-hook-post-restore-all 'bash \$HOME/.config/tmux/claude-panes-restore.sh'" "$HOME/.config/tmux/tmux.conf" && ok "policy: the pane-session hooks are wired into resurrect" || fail "policy: a resurrect hook for the pane sessions is missing from tmux.conf"
# --- the pane's session across a reboot: resurrect's hooks snapshot @claude_session and @claude_args per pane
# and put them back on panes whose position and cwd still match; an empty save writes nothing ---
pt="${TMPDIR:-/tmp}/selftest-panes"; rm -rf "$pt"; mkdir -p "$pt/snap"
printf '#!/bin/sh\ncase "$1" in\n list-panes) [ -n "${PANES_EMPTY:-}" ] || printf "main:1.0\\t%s\\taaaaaaaa-1111-2222-3333-444444444444\\t--plugin-dir /x\\nmain:2.0\\t/nowhere/shell\\t\\t\\nmain:3.1\\t/nowhere/moved\\tbbbbbbbb-1111-2222-3333-444444444444\\t\\n";;\n display-message) case "$*" in *main:1.0*) printf "%s\\n";; *main:3.1*) printf "/nowhere/elsewhere\\n";; esac;;\n set-option) printf "%%s\\n" "$*" >> "%s";;\nesac\n' "$C" "$C" "$pt/calls" > "$pt/tmux"; chmod +x "$pt/tmux"
CLAUDE_TMUX_BIN="$pt/tmux" CLAUDE_PANES_DIR="$pt/snap" bash "$HOME/.config/tmux/claude-panes-save.sh"
snap=$(ls "$pt/snap"/*.tsv 2>/dev/null | head -1)
[ -n "$snap" ] && [ "$(wc -l < "$snap" | tr -d ' ')" = "2" ] && ok "panes: save keeps the two Claude panes, not the shell" || fail "panes: save (snap: ${snap:-none})"
PANES_EMPTY=1 CLAUDE_TMUX_BIN="$pt/tmux" CLAUDE_PANES_DIR="$pt/snap" bash "$HOME/.config/tmux/claude-panes-save.sh"
[ "$(ls "$pt/snap"/*.tsv | wc -l | tr -d ' ')" = "1" ] && ok "panes: an empty save writes no snapshot" || fail "panes: empty save wrote a file"
CLAUDE_TMUX_BIN="$pt/tmux" CLAUDE_PANES_DIR="$pt/snap" bash "$HOME/.config/tmux/claude-panes-restore.sh"
grep -q 'set-option -p -t main:1.0 @claude_session aaaaaaaa-1111-2222-3333-444444444444' "$pt/calls" && grep -q 'set-option -p -t main:1.0 @claude_args --plugin-dir /x' "$pt/calls" && ok "panes: restore puts session and flags back on the matching pane" || fail "panes: restore (calls: $(cat "$pt/calls" 2>/dev/null))"
grep -q 'main:3.1' "$pt/calls" 2>/dev/null && fail "panes: restore tagged a pane whose cwd moved" || ok "panes: a pane in another folder is never tagged"
rm -rf "$pt"
# --- the crab box (claude-crab.sh): title, idle and the last three prompts from a transcript (tool results
# skipped), the name for the pane title, and a box never wider than 60 cells even with a long command ---
cb="${TMPDIR:-/tmp}/selftest-crab"; rm -rf "$cb"; mkdir -p "$cb/projects/$enc"
cj="$cb/projects/$enc/aaaaaaaa-1111-2222-3333-444444444444.jsonl"
printf '{"type":"custom-title","customTitle":"walkthrough-recovery"}\n{"type":"user","timestamp":"2026-11-04T01:00:00.000Z","message":{"role":"user","content":"one"}}\n{"type":"user","timestamp":"2026-11-04T01:01:00.000Z","message":{"role":"user","content":[{"type":"tool_result","content":"x"}]}}\n{"type":"user","timestamp":"2026-11-04T01:02:00.000Z","message":{"role":"user","content":[{"type":"text","text":"two"}]}}\n{"type":"user","timestamp":"2026-11-04T01:03:00.000Z","message":{"role":"user","content":"three"}}\n{"type":"user","timestamp":"%s","message":{"role":"user","content":"four"}}\n' "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" > "$cj"
cinfo=$(CLAUDE_PROJECTS_DIR="$cb/projects" bash "$HOME/.config/tmux/claude-crab.sh" info aaaaaaaa-1111-2222-3333-444444444444 "$C")
[ "$cinfo" = "$(printf 'TITLE:walkthrough-recovery\nIDLE:0s\nPROMPT:two\nPROMPT:three\nPROMPT:four')" ] && ok "crab: title, idle and the last three prompts" || fail "crab: info (got: $(printf '%s' "$cinfo" | tr '\n' '|'))"
cname=$(CLAUDE_PROJECTS_DIR="$cb/projects" bash "$HOME/.config/tmux/claude-crab.sh" name aaaaaaaa-1111-2222-3333-444444444444 "$C")
[ "$cname" = "walkthrough-recovery" ] && ok "crab: the pane title is the session's title" || fail "crab: name (got: $cname)"
cbox=$(CLAUDE_PROJECTS_DIR="$cb/projects" bash "$HOME/.config/tmux/claude-crab.sh" box '~,,~' 'claude --resume aaaaaaaa --plugin-dir /nowhere/some/very/long/plugin/path/plugins/victrix' aaaaaaaa-1111-2222-3333-444444444444 "$C" "parked as a background job — in another pane: claude stop 99ed114c, then Enter" | sed $'s/\e\\[[0-9;]*m//g')
cw=$(printf '%s\n' "$cbox" | grep -v '└──' | python3 -I -c 'import sys; print(max(len(l.rstrip("\n")) for l in sys.stdin))')
[ "$cw" -le 60 ] && ok "crab: box fits 60 cells ($cw); the fix line is never cut" || fail "crab: box is $cw cells wide"
case "$cbox" in *'(\/) (~,,~) (\/)'*'❯ four'*'claude stop 99ed114c'*) ok "crab: claws, face, prompts and the fix line" ;; *) fail "crab: box content (got: $(printf '%s' "$cbox" | tr '\n' '|'))" ;; esac
rm -rf "$cb"
# --- the prefix+g picker (clh.sh) marks live sessions from Claude's registry and jumps to their pane; a dead
# pid is unmarked and resumes as before ---
pk="${TMPDIR:-/tmp}/selftest-picker"; rm -rf "$pk"; mkdir -p "$pk"
printf '{"pid":%s,"sessionId":"ffffffff-1111-2222-3333-444444444444","status":"waiting","tmux":"2:@1.%%9"}' "$$" > "$pk/a.json"
printf '{"pid":999999,"sessionId":"99999999-1111-2222-3333-444444444444","status":"busy","tmux":"2:@1.%%3"}' > "$pk/b.json"
pmarks=$(/opt/homebrew/bin/bash -c "source <(sed -n '/^registry_marks()/,/^}/p' \"$HOME/.config/fzf/clh.sh\"); REGISTRY=\"$pk\"; registry_marks")
[ "$pmarks" = "$(printf 'MARK\tffffffff-1111-2222-3333-444444444444\t◐\t%%9')" ] && ok "picker: live session marked waiting with its pane, dead pid dropped" || fail "picker: marks (got: $(printf '%s' "$pmarks" | tr '\t' '|'))"
plist=$(printf 'ffffffff-1111-2222-3333-444444444444\t%s\t%s\tslug\tmain\thello\n11111111-1111-2222-3333-444444444444\t%s\t/nowhere/work\tslug2\tmain\tbye\n' "$(date +%s)" "$C" "$(date +%s)" | /opt/homebrew/bin/bash -c "source <(sed -n '/^registry_marks()/,/^}/p; /^format_lines()/,/^}/p' \"$HOME/.config/fzf/clh.sh\"); REGISTRY=\"$pk\"; format_lines" 2>&1)
case "$plist" in *$'\t◐  now'*$'\t   now'*) ok "picker: rows carry the mark, unmarked rows still list" ;; *) fail "picker: list marks (got: $(printf '%s' "$plist" | tr '\t\n' '|/'))" ;; esac
rm -rf "$pk"
# tmux best-of-day keeper (lambda.sh keep_daily): today's copy must exist once a save has run today.
check tmux-daily-keep test -s "$HOME/.local/share/tmux/resurrect/pinned/daily/tmux_resurrect_$(date +%Y%m%d).txt"

# --- statusline: alignment is asserted on a known sample (a shifted field can never pass) ---
now=$(date +%s)
# Sample renders must never feed the real usage ring: point it at a scratch file for this run.
ring="${TMPDIR:-/tmp}/selftest-usage-ring.tsv"; export CLAUDE_USAGE_RING="$ring"; rm -f "$ring"
export CLAUDE_STATUSLINE_WAITING="0:"   # pin the ? count: the live tmux flags must not reach a sample render
sample=$(printf '{"cwd":"%s","model":{"id":"claude-opus-5-5"},"workspace":{"current_dir":"%s"},"cost":{"total_cost_usd":12.34,"total_duration_ms":7200000,"total_api_duration_ms":2880000},"context_window":{"context_window_size":1000000,"used_percentage":51.4},"prompt_cache":{"warm":true,"hit_ratio":0.94},"effort":{"level":"high"},"thinking":{"enabled":true},"rate_limits":{"five_hour":{"used_percentage":40,"resets_at":%d},"seven_day":{"used_percentage":30,"resets_at":%d}},"vim":{"mode":"NORMAL"},"pr":{"number":1234,"review_state":"pending"}}' "$HOME" "$HOME" $((now + 2880)) $((now + 388900)))   # 30 % with 4.5 of 7 days left: on pace, lands 84 %
start=$(date +%s%N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1e9))')
line=$(printf '%s' "$sample" | COLUMNS=160 "$C/statusline.sh" | sed $'s/\e\\[[0-9;]*m//g')   # 160: the long forms fit (the full row is 163 cells; at 140 the fit shrinks them, asserted below)
end=$(date +%s%N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1e9))')
ms=$(( (end - start) / 1000000 ))
for tok in 'Oᵀ⁺' '? 0' 'ψ 51%' 'λ 30%' '(40% 5h)' 'τ 4d 12h reset' 'δ 84% 1d 7h to spare' '#1234' '$ 12 over 2h'; do   # δ from the window's average pace, $ with the session clock
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
# the same session a day into a week that is 60 % spent: the average pace runs dry long before the reset
dry="${sample/\"used_percentage\":30,\"resets_at\":$((now + 388900))/\"used_percentage\":60,\"resets_at\":$((now + 518400))}"
burst=$(printf '%s' "$dry" | "$C/statusline.sh")
case "$burst" in *"${red}60%"*"stop for"*) ok "statusline:running dry renders λ red and δ stop for" ;; *) fail "statusline:running dry not red (line: $(printf '%s' "$burst" | sed $'s/\e\\[[0-9;]*m//g'))" ;; esac
# --- the usage endpoint's cache: a session that outlived a reset reports last week's 95 %; the endpoint says 20 %
# of a week that opened three days ago with four left, Fable at 35 %: the row shows 20 %, (35%ᶠ), and a δ from
# the endpoint's window (20 % over 3 d lands at 47 %), never the stale 95 % ---
fixture="${TMPDIR:-/tmp}/selftest-usage-api.json"
iso() { date -u -r "$1" +%Y-%m-%dT%H:%M:%S.000000+00:00; }
printf '{"limits":[{"kind":"weekly_all","percent":20,"resets_at":"%s"},{"kind":"weekly_scoped","percent":35,"resets_at":"%s","scope":{"model":{"display_name":"Fable"}}}],"seven_day_breakdown":{"window_started_at":"%s"}}' "$(iso $((now + 345720)))" "$(iso $((now + 345720)))" "$(iso $((now - 259200)))" > "$fixture"   # four days plus two minutes: the render happens seconds later and must still read "4d"
stale="${sample/\"used_percentage\":30,\"resets_at\":$((now + 388900))/\"used_percentage\":95,\"resets_at\":$((now - 259200))}"
sline=$(printf '%s' "$stale" | COLUMNS=160 CLAUDE_USAGE_CACHE="$fixture" "$C/statusline.sh" | sed $'s/\e\\[[0-9;]*m//g')
for tok in 'λ 20% (35%ᶠ)' 'τ 4d reset' 'δ 47%' 'to spare'; do
	if printf '%s' "$sline" | grep -qF -- "$tok"; then ok "statusline:endpoint:$tok"; else fail "statusline:endpoint:$tok  (line: $sline)"; fi
done
case "$sline" in *95%*) fail "statusline:endpoint: stale 95% leaked (line: $sline)" ;; *) ok "statusline:endpoint: stale week dropped" ;; esac
rm -f "$fixture"
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
