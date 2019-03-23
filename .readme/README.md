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

## Screenshot

![](screenshot.png)

## Install

``` sh
git init --bare $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles pull
```

## Setup

``` sh
dotfiles config --local status.showUntrackedFiles no # Only watch specified folders, not every folder in $HOME
```

## Submodules

``` sh
dotfiles submodule init # Create all folders 
dotfiles submodule update # Update all folders to master branch
```

## Backup

    cd
    mkdir -p .backup && \
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
    xargs -I{} mv {} .backup/{}

## Reinstall

    ssh-keygen -t rsa -b 4096 -C "example@example.com"
    pbcopy < ~/.ssh/id_rsa.pub
    /usr/bin/ssh-add -K ~/.ssh/id_rsa
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
    git clone --bare git@github.com:Vvkmnn/dotfiles.git $HOME/.dotfiles
    dotfiles checkout
    dotfiles config status.showUntrackedFiles no

## Install

    ./.setup/setup.sh
    ./.setup/...

## Update

    dotfiles submodule update --init --recursive                                   
