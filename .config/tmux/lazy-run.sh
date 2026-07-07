#!/bin/bash
# Generic lazy restore: shows command, waits for Enter, runs it
# Ctrl+C drops to shell instead of closing pane
# Called by @resurrect-processes for nvim and other programs

trap 'exec "$SHELL" -l' INT

# save intended CWD + recover if stale (e.g., SSD disconnected)
_intended_cwd="$PWD"
[[ -d . ]] || builtin cd "$PWD" 2>/dev/null || builtin cd ~ 2>/dev/null

_context() {
  local ctx
  if [[ "$PWD" != "$_intended_cwd" ]]; then
    ctx="${_intended_cwd/#$HOME/~} (not found)"
  else
    ctx="${PWD/#$HOME/~}"
  fi
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  [ -n "$branch" ] && ctx="$ctx • $branch"
  echo "$ctx"
}

# E4 prompt: bracket, face, and command share one random Tokyo Night color
_prompt() {
  local faces=('[¬_¬]' '[^_^]' '[-_-]' '[o_o]' '[>_<]' '[T_T]' '[u_u]' '[n_n]' '[x_x]' '[~_~]' '[$_$]' '[+_+]' '[v_v]')
  local colors=('38;2;122;162;247' '38;2;187;154;247' '38;2;125;207;255' '38;2;158;206;106' '38;2;224;175;104' '38;2;247;118;142')
  local face="${faces[$((RANDOM % ${#faces[@]}))]}"
  local color="${colors[$((RANDOM % ${#colors[@]}))]}"
  echo ""
  local ctx
  ctx=$(_context)
  echo -e "  \033[${color}m┌─ ${face}\033[0m  \033[1;${color}m$*\033[0m"
  echo -e "  \033[${color}m│\033[0m  \033[${color}m${ctx}\033[0m"
  echo -e "  \033[${color}m└─\033[0m Press Enter to start, Ctrl+C for shell"
  echo ""
}

/opt/homebrew/bin/tmux rename-window "$1" 2>/dev/null

_prompt "$@"
read -r

# re-try intended CWD (SSD may have reconnected while waiting at prompt)
[[ -d "$_intended_cwd" ]] && cd "$_intended_cwd" 2>/dev/null

/opt/homebrew/bin/tmux set-window-option automatic-rename on 2>/dev/null
exec "$@"
