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

## Environment -------------------------------------

export LANG=en_US.UTF-8
export BROWSER=open
export TERM=xterm-256color
export ARCHEY_LOGO_FILE=$HOME/.logo

# Editor
export EDITOR='vim' # $VISUAL is the default for most shells
export EDITOR=$VISUAL # $EDITOR in case
export ALTERNATE_EDITOR='vim'                                        # $EDITOR if all else fails

# Brew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# openSSL
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"


## Path --------------------------------------------

## brew
PATH="/usr/local/sbin:$PATH"

## openSSL
PATH="/usr/local/opt/openssl/bin:$PATH"

# Miniconda Python
PATH="$HOME/.miniconda/bin:$PATH"

# NVM Node
PATH="$HOME/.nvm/versions/node/v12.1.0/bin:$PATH"

# Doom Emacs
PATH="$HOME/.emacs.d/bin:$PATH"

# MacOS (Brew) Emacs
PATH="/Applications/Emacs.app/Contents/MacOS/bin:$PATH"

## Work --------------------------------------------
PATH="$HOME/Documents/lake/lake-hydra/bin:$PATH"

