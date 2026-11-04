#!/bin/bash
# claude-crab.sh — the crab box every Claude launcher shows while it waits for you (owner 2026-11-04:
# "I like my claude crab"). One drawing, used by `c` (~/.functions) and by claude-session-restore.sh.
#
#   bash claude-crab.sh info <session-id> <cwd>
#       prints TITLE:…, IDLE:…, PROMPT:… lines read from the session's transcript. Fast on big files:
#       the title comes from a grep for the last rename, prompts and idle time from the last 2 MB only
#       (the 166 MB walkthrough transcript would otherwise cost seconds per prompt). Fails open: a
#       missing or unreadable transcript prints nothing.
#
#   bash claude-crab.sh box <face> <command> <session-id> <cwd> [last line]
#       draws the box: the crab with <face>, the command Enter will run, folder • branch • idle, the
#       title, the last three prompts, and the last line (default "Press Enter to resume, Ctrl+C for
#       shell"). Never wider than 60 columns: long lines are cut with …. Colour: one of five Tokyo
#       Night tones, picked per draw, as the restore script did since E4.
#
#   bash claude-crab.sh name <session-id> <cwd>
#       prints the title if there is one, else the id's first block: the pane title `↵ resume <name>`.
set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/bin:/bin"

WIDTH=60

transcript() { # <session-id> <cwd> → path of the transcript, or nothing
	local sid="$1" cwd="$2" enc
	cwd=$(cd "$cwd" 2>/dev/null && pwd -P || printf '%s' "$cwd")
	enc=$(printf '%s' "$cwd" | sed 's|/|-|g; s|\.|-|g')
	local f="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}/$enc/$sid.jsonl"
	[ -s "$f" ] && printf '%s' "$f"
}

info() { # <session-id> <cwd>
	local f; f=$(transcript "$1" "$2") || return 0
	[ -n "$f" ] || return 0
	local title
	# the last rename, searched in the last 20 MB only (a full pass over 166 MB took 1.6 s): a rename older
	# than that is not shown, the box still draws
	title=$(tail -c 20000000 "$f" 2>/dev/null | grep -o '"customTitle":"[^"]*"' | tail -1 | sed 's/^"customTitle":"//; s/"$//')
	[ -n "$title" ] && printf 'TITLE:%s\n' "$title"
	tail -c 2000000 "$f" 2>/dev/null | python3 -I -c '
import json, sys, time
from datetime import datetime
prompts, last = [], None
for line in sys.stdin:
    try: d = json.loads(line)
    except Exception: continue
    if d.get("type") != "user": continue
    m = d.get("message", {}); c = m.get("content", "") if isinstance(m, dict) else ""
    text = c if isinstance(c, str) else next((b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"), "")
    text = text.strip()
    if not text or text.startswith("<"): continue   # tool results and system blocks are not prompts
    prompts.append(" ".join(text.split())[:60])
    ts = d.get("timestamp")
    if ts:
        try: last = datetime.fromisoformat(ts.replace("Z", "+00:00")).timestamp()
        except Exception: pass
if last:
    s = int(time.time() - last)
    print("IDLE:" + (f"{s}s" if s < 60 else f"{s//60}m" if s < 3600 else f"{s//3600}h" if s < 86400 else f"{s//86400}d"))
for p in prompts[-3:]: print("PROMPT:" + p)
' 2>/dev/null
}

name() { # <session-id> <cwd>
	local t; t=$(info "$1" "$2" | sed -n 's/^TITLE://p')
	printf '%s' "${t:-${1%%-*}}"
}

cut_to() { # <text> <prefix cells> → the text cut so prefix + text fits WIDTH, … when cut
	local s="$1" max=$((WIDTH - ${2:-9}))
	[ "${#s}" -le "$max" ] && printf '%s' "$s" || printf '%s…' "${s:0:$((max - 1))}"
}

box() { # <face> <command> <session-id> <cwd> [last line]
	local face="$1" cmd="$2" sid="$3" cwd="$4" last="${5:-Press Enter to resume, Ctrl+C for shell}"
	local colors=(33 36 35 34 32) c dim=90
	c=${colors[$((RANDOM % 5))]}
	local ctx="${cwd/#"$HOME"/\~}" branch idle title line
	branch=$(git -C "$cwd" branch --show-current 2>/dev/null) && [ -n "$branch" ] && ctx="$ctx • $branch"
	local -a prompts=()
	while IFS= read -r line; do
		case "$line" in
			TITLE:*) title="${line#TITLE:}" ;;
			IDLE:*) idle="${line#IDLE:}" ;;
			PROMPT:*) prompts+=("${line#PROMPT:}") ;;
		esac
	done < <(info "$sid" "$cwd")
	[ -n "${idle:-}" ] && ctx="$ctx • ${idle} idle"
	printf '\n'
	printf '  \033[%sm┌─ (\\/) (%s) (\\/)\033[0m  \033[1;%sm%s\033[0m\n' "$c" "$face" "$c" "$(cut_to "$cmd" 25)"
	printf '  \033[%sm│\033[0m\n' "$c"
	printf '  \033[%sm│\033[0m      \033[%sm%s\033[0m\n' "$c" "$c" "$(cut_to "$ctx" 9)"
	if [ -n "${title:-}" ]; then
		printf '  \033[%sm│\033[0m\n' "$c"
		printf '  \033[%sm├──\033[0m  \033[1m%s\033[0m\n' "$c" "$(cut_to "$title" 7)"
	fi
	if [ "${#prompts[@]}" -gt 0 ]; then
		printf '  \033[%sm│\033[0m\n' "$c"
		for line in "${prompts[@]}"; do printf '  \033[%sm│\033[0m      \033[%sm❯ %s\033[0m\n' "$c" "$dim" "$(cut_to "$line" 11)"; done
	fi
	printf '  \033[%sm│\033[0m\n' "$c"
	printf '  \033[%sm└──\033[0m %s\n\n' "$c" "$last"   # never cut: this line is the instruction
}

case "${1:-}" in
	info) shift; info "$@" ;;
	name) shift; name "$@" ;;
	box) shift; box "$@" ;;
	*) printf 'usage: claude-crab.sh info|name|box …\n' >&2; exit 2 ;;
esac
