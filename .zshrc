# Vivek Menon - vvkmnn.xyz

# MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
# MMMMMMMMMMMMMMMMMMMMMMNNmmmmNNMMMMMMMMMMMMMMMMMMMM
# MMMMMMMMMMMMMMMMNho:.`        `-:ohNMMMMMMMMMMMMMM
# MMMMMMMMMMMMMd+.                    .+dMMMMMMMMMMM
# MMMMMMMMMMNs.                .shs+:.   .sMMMMMMMMM
# MMMMMMMMMs`                -yMMMMMy.     `sMMMMMMM
# MMMMMMMm-                 `MMMMMs`         -mMMMMM
# MMMMMMd`                  .MMMMm            `dMMMM
# MMMMMd`                   :MMMMd             `mMMM
# MMMMM-            `odyo:. +MMMMy              -MMM
# MMMMy           .sNMMMMh: oMMMMo               yMM
# MMMM/           oMMMMy.   :MMMM+               /MM
# MMMM.            sMMMd`    /MMM:               .MM
# MMMM-             sMMMd`    /MM-               -MM
# MMMM+              sMMMd`    /M`               +MM
# MMMMm               sMMMh`    :                mMM
# MMMMMo               yMMMh`                   oMMM
# MMMMMM/               yMMMh                  /MMMM
# MMMMMMMo               yMMMh                oMMMMM
# MMMMMMMMh.              yMMMh             .hMMMMMM
# MMMMMMMMMMs.             oydMh          .sMMMMMMMM
# MMMMMMMMMMMMh:               .`       :hMMMMMMMMMM
# MMMMMMMMMMMMMMNh+-                -+hNMMMMMMMMMMMM
# MMMMMMMMMMMMMMMMMMMmhso+////+oshmMMMMMMMMMMMMMMMMM
# MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

## Personal Defaults
export LANG=en_US.UTF-8
export BROWSER=open
export TERM=xterm-256color
export PATH="/usr/local/bin:$PATH"
export EDITOR='vim'

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Aliases
source $HOME/.aliases

## Application Defaults

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# RVM
export PATH="$PATH:$HOME/.rvm/bin"

# Continuum Anaconda
export PATH=~/anaconda3/bin:$PATH

# Google Go
export GOPATH=~/Code/Go

# Google Cloud
if [ -f "$HOME"/.gcloud/google-cloud-sdk/path.zsh.inc ]; then source "$HOME"/.gcloud/google-cloud-sdk/path.zsh.inc; fi

# Iterm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

## Shell Defaults

# Spaceship
SPACESHIP_PROMPT_SYMBOL="ॐ "
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_COLOR=blue
SPACESHIP_DIR_TRUNC=2
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=blue

# Little Helper!
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'

# Zplug
source ~/.zplug/init.zsh

# Autosuggestions
zplug "zsh-users/zsh-autosuggestions"

# Syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting" #, defer:2

# Git Plugin
zplug "plugins/git",   from:oh-my-zsh

# Spaceship Theme
zplug "denysdovhan/spaceship-zsh-theme", use:spaceship.zsh, from:github, as:theme

# Athame (Vim in Shell)
zplug "ardagnir/athame"

# Z - jump around
zplug rupa/z

# Load theme file
# zplug 'dracula/zsh', as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	fi
fi

# Then, source plugins and add commands to $PATH
zplug load # --verbose
