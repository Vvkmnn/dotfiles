dotfiles
======

A '[bare]([https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/])' dotfiles repo approach for cross-device comfort, as popularized on [Hacker News](https://news.ycombinator.com/item?id=11070797).

## Setup

    git init --bare $HOME/.dotfiles
    alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    config config --local status.showUntrackedFiles no
    echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
    echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc

## Install

    git clone --bare git@github.com:Vvkmnn/dotfiles.git $HOME/.dotfiles
    function config {
    /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
    }
    mkdir -p .dotfiles-backup
    dotfiles checkout
    if [ $? = 0 ]; then
    echo "Checked out dotfiles.";
    else
        echo "Backing up pre-existing dotfiles.";
        config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
    fi;
    config checkout
    config config status.showUntrackedFiles no