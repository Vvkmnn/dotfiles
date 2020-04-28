# Fish
set fish_greeting      # Remove Default Greeting
bind \cg forward-word # Autocomplete with Tab-Return
bind \cf complete     # Autocomplete with Tab-Return
# set fish_plugins z vi-mode

# Fisher
if not functions -q fisher
    echo "Installing fisher for the first time..." >&2
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fisher
end

# Bass (Bash)
if functions -q bass
    bass source ~/.fishrc
end

# Spacefish (Theme)
if functions -q fish_prompt
    # export SPACEFISH_CHAR_SYMBOL="λ"
    export SPACEFISH_CHAR_SYMBOL="ॐ"
    export SPACEFISH_PROMPT_PREFIXES_SHOW=false
    export SPACEFISH_TIME_SHOW=true
    # export SPACEFISH_PROMPT_SEPARATE_LINE=false
    # set SPACEFISH_PROMPT_ORDER char 
    # set SPACEFISH_RPROMPT_ORDER time user dir host git package node docker ruby golang php rust haskell julia aws conda pyenv kubecontext exec_time line_sep battery jobs exit_code 
# end

# Spacefish (Theme)
# if functions -q pure_prompt 
    # set -g pure_symbol_prompt "ॐ"
    # set -g pure_separate_prompt_on_error true
    # export PROMPT='%(?.%F{magenta}.%F{red}❯%F{magenta})❯%f '
end


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval /usr/local/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

