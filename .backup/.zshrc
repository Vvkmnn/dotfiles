#TODO: Change ZSH path from Dropbox to local as per .dots file
# Path to your oh-my-zsh installation. Currently Dropbox, may fix later.
#export ZSH=~/.oh-my-zsh

export ZSH=~/Dropbox/dotfiles/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.Junip
ZSH_THEME="dracula"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(brew brew-cask z osx python git github zsh-syntax-highlighting)
#git brew brew-cask autoenv zsh-syntax-highlighting python virtualenv pip osx zsh-autosuggestions z
 # autoenv z brew brew-cask git github osx)

# Plugin configuration



# User configuration

# export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
#if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='atom'
# else
#   export EDITOR='atom'
#fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# z
. `brew --prefix`/etc/profile.d/z.sh

# Homebrew Cask
# Specify your defaults in this environment variable
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# executable
# Make custom scripts executable as programs
#chmod u+x ~/Dropbox/bin/*

# Prompt
# Source: http://www.lowlevelmanager.com/2012/03/smile-zsh-prompt-happysad-face.html
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)' #%F{gray} before to color prompt

# Default Editor - Atom
export EDITOR='atom'

# Autoenv
#source /usr/local/opt/autoenv/activate.sh

# Venv Wrapper
#VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
#source /usr/local/bin/virtualenvwrapper.sh

# Google App Engine
#export GAE="/usr/local/google_appengine"
#export PYTHONPATH="$PYTHONPATH:$GAE"
#export PATH="$PATH:$GAE"

# Remove the 'You have new mail' prompt; uncomment as necessary
# MAILCHECK=0

# Source oh-my-zsh script
source $ZSH/oh-my-zsh.sh

#TODO: Add Dropbox bin to the to the path
#TODO: Make a ~/.path
# Add `~/bin` to the `$PATH`
#export PATH="$HOME/bin:$PATH";

#TODO: change bash_prompt to bash and zsh
# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
#for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
#    [ -r "$file" ] && [ -f "$file" ] && source "$file";
#done;
#unset file;

#Anaconda
# added by Anaconda3 4.2.0 installer
export PATH="/Users/vivek.menon/anaconda3/bin:$PATH"

#GO
# Modify for local dropbox
# Currently using computer path
#export GOPATH="/Users/vivek.menon/Dropbox/bin/go"
export GOPATH="/Users/vivek.menon/Code/Go"

# The next line updates PATH for the Google Cloud SDK.
if [ -f /Users/vivek.menon/Code/Gcloud/google-cloud-sdk/path.zsh.inc ]; then
  source '/Users/vivek.menon/Code/Gcloud/google-cloud-sdk/path.zsh.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f /Users/vivek.menon/Code/Gcloud/google-cloud-sdk/completion.zsh.inc ]; then
  source '/Users/vivek.menon/Code/Gcloud/google-cloud-sdk/completion.zsh.inc'
fi

# Dotfiles
alias dotfiles='/usr/bin/git --git-dir=/Users/vivek.menon/.dotfiles/ --work-tree=/Users/vivek.menon'

# Dotfiles
dotbackup () {
mkdir -p .dotfiles-backup && \
dotfiels checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .dotfiles-backup/{}
}