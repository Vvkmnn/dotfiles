# Vivek Menon - vvkmnn.xyz

# ##################################################
# ##################################################
# ######################        ####################
# ################                    ##############
# #############                #######   ###########
# ###########                #########     #########
# #########                 ########         #######
# ########                  ######            ######
# #######                   ######             #####
# ######            ####### ######              ####
# #####           ######### ######               ###
# #####           #######   ######               ###
# #####            ######    #####               ###
# #####             ######    ####               ###
# #####              ######    ###               ###
# #####               ######    #                ###
# ######               ######                   ####
# #######               #####                  #####
# ########               #####                ######
# ##########              #####             ########
# ############             #####          ##########
# ##############            #####       ############
# ##################                ################
# ##################################################
# ##################################################

#
# User configuration sourced by interactive shells
#
# Path
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Theme
PURE_PROMPT_SYMBOL="ॐ "

# Prompt
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'

## brew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

## gcloud
if [ -f "${HOME}/.google/path.zsh.inc" ]; then source "${HOME}/.google/path.zsh.inc"; fi
if [ -f "${HOME}/.google/completion.zsh.inc" ]; then source "${HOME}/.google/completion.zsh.inc"; fi

## fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## z 
. /usr/local/etc/profile.d/z.sh

# Framework (Zim)
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim # Define zim location

[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh # Start zim
