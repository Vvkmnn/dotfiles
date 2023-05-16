# dotfiles

```
##################################################
##################################################
######################        ####################
################                    ##############
#############                #######   ###########
###########                #########     #########
#########                 ########         #######
########                  ######            ######
#######                   ######             #####
######            ####### ######              ####
#####           ######### ######               ###
#####           #######   ######               ###
#####            ######    #####               ###
#####             ######    ####               ###
#####              ######    ###               ###
#####               ######    #                ###
######               ######                   ####
#######               #####                  #####
########               #####                ######
##########              #####             ########
############             #####          ##########
##############               ##       ############
##################                ################
##################################################
##################################################
```

[A](https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789) [dotfile](https://dotfiles.github.io) [repo](https://news.ycombinator.com/item?id=11070797)[.](https://www.atlassian.com/git/tutorials/dotfiles)

## Pre Install

### Debian

```sh
sudo apt get install git zsh curl vim python3-pip ngrok
```

### MacOS
[xcode](https://developer.apple.com/xcode/resources/)
```sh
xcode-select --install
```

[brew.sh](https://brew.sh)
```sh
## zsh
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

## brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## utils
brew install yabai skhd \
             git-open bottom \
             ngrok \

## emacs
brew install git ripgrep coreutils fd
brew install emacs-mac \
   --with-dbus\
   --with-starter\
   --with-librsvg\
   --with-imagemagick\
   --with-xwidgets\ 
   --with-ctags\
   --with-native-comp\
   --with-mac-metal\
   --with-natural-title-bar\
   --with-spacemacs-icon\

## casks
brew install --cask protonmail-bridge protonvpn
brew install --cask 1password adguard
brew install --cask karabiner-elements
brew install --cask miniconda
```

## Install

```sh
# ssh
ssh-keygen -t rsa -b 4096 -C "example@example.com"
cat ~/.ssh/id_rsa.pub

# github
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:Vvkmnn/dotfiles.git --branch <os> $HOME/.dotfiles
dotfiles stash
dotfiles checkout

# optional
git config --global credential.helper 'cache --timeout=7777'
dotfiles config status.showUntrackedFiles no

```

## Backup

```
cd
mkdir -p .backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .backup/{}
```

## Post Install

```
# submodules
dotfiles submodule init
dotfiles submodule update

# TODO guided
./.setup/setup.sh

# individual
chmod +x ./setup/*.sh
./.setup/<example>.sh

# core
vim.sh   # Editor
zsh.sh   # Shell
emacs.sh # IDE
#brave.sh # Browser TODO Opera

# utility
debian.sh
capslock.sh
```

## Update

``` sh
# combined
dotfiles submodule update --init --recursive

# create + update
dotfiles submodule init # Create all folders 
dotfiles submodule update # Update all folders to master branch
```

