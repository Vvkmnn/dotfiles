#!/usr/bin/env bash
# Bot prompts for installing and describing softwaree
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