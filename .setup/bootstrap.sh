#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";
echo $PWD

git pull origin master;

function doIt() {
    # add --dry-run to test rsync
    rsync --dry-run --exclude ".git/" --exclude "README.md" --exclude "LICENSE" \
    --exclude ".DS_Store"  -avph --no-perms . ~;
    source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;
