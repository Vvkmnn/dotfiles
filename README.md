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

[A](https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789) [dotfile](https://dotfiles.github.io) [repo](https://news.ycombinator.com/item?id=11070797).

## Pre Install

``` sh
# debian
sudo apt get install git zsh curl vim python3-pip
```

## Install

```sh
# ssh
ssh-keygen -t rsa -b 4096 -C "example@example.com"
cat ~/.ssh/id_rsa.pub

# github
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:Vvkmnn/dotfiles.git --branch <device> $HOME/.dotfiles
dotfiles stash
dotfiles checkout

# optional
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
capslock.sh
debian.sh
```

## Update

``` sh
# combined
dotfiles submodule update --init --recursive

# create + update
dotfiles submodule init # Create all folders 
dotfiles submodule update # Update all folders to master branch
```

