#!/usr/bin/env bash
# Bot based methods for installing and describing softwaree
# Based on work by Adam Eivy

## Color Sequences
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_RED=$ESC_SEQ"31;01m"
COL_BLUE=$ESC_SEQ"37;01m"
COL_PURPLE=$ESC_SEQ"34;01m"


## Prompt Functions
function tell() {
    echo "$COL_GREEN[-_-]$COL_RESET: "$1
}

function ask() {
    read -p "$(echo "$COL_PURPLE[ಠ_ಠ]$COL_RESET: $1")" $2
}

function warn() {
    echo "$COL_YELLOW[._.]$COL_RESET: "$1
}

function error() {
    echo "$COL_RED[o_O]$COL_RESET: "$1
}

function fin () {
    echo "$COL_BLUE[^_^]$COL_RESET: "$1
}


## Dependency Functions
function require_cask() {
    warn "Installing brew cask $1..."
    brew cask list $1 > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        warn "Installing brew cask install $1 $2..."
        brew cask install $1
        if [[ $? != 0 ]]; then
            error "failed to install $1! aborting..."
            # exit -1
        fi
    fi
   
}

function require_brew() {
    warn "brew $1 $2..."
    brew list $1 > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        warn "brew install $1 $2..."
        brew install $1 $2
        if [[ $? != 0 ]]; then
            error "failed to install $1! aborting..."
            # exit -1
        fi
    fi
   
}

function require_node(){
    warn "node -v"
    node -v
    if [[ $? != 0 ]]; then
        warn "node not found, installing via homebrew"
        brew install node
    fi
    
}

function require_gem() {
    warn "gem $1..."
    if [[ $(gem list --local | grep $1 | head -1 | cut -d' ' -f1) != $1 ]];
        then
            warn "gem install $1..."
            gem install $1
    fi
    
}

function require_npm() {
    sourceNVM
    nvm use 4.4.4
    warn "npm $*"
    npm list -g --depth 0 | grep $1@ > /dev/null
    if [[ $? != 0 ]]; then
        warn "npm install -g $*"
        npm install -g $@
    fi
    
}

function require_apm() {
    warn "checking atom plugin: $1..."
    apm list --installed --bare | grep $1@ > /dev/null
    if [[ $? != 0 ]]; then
        warn "apm install $1..."
        apm install $1
    fi
    
}

function sourceNVM(){
    export NVM_DIR=~/.nvm
    source $(brew --prefix nvm)/nvm.sh
}


function require_nvm() {
    mkdir -p ~/.nvm
    cp $(brew --prefix nvm)/nvm-exec ~/.nvm/
    sourceNVM
    nvm install $1
    if [[ $? != 0 ]]; then
        warn "installing nvm"
        require_brew nvm
        . ~/.bashrc
        nvm install $1
    fi
    
}
