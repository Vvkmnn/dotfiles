# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/v/.fzf/bin* ]]; then
  export PATH="$PATH:/Users/v/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/v/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/v/.fzf/shell/key-bindings.zsh"

