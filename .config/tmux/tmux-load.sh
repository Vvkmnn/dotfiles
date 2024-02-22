#!/bin/sh

# Path to the Tmux Plugin Manager (tpm)
TPM_PATH="$HOME/.tmux/plugins/tpm"

# Check if tpm is installed by checking the directory's existence
if [ -d "$TPM_PATH" ]; then
    # tpm is installed, use the tmux configuration with tpm
    TMUX_CONF="$HOME/.config/tmux/tmux-advanced.conf"
else
    # tpm is not installed, use the tmux configuration without tpm
    TMUX_CONF="$HOME/.config/tmux/tmux-simple.conf"
fi

# Load the selected tmux configuration
tmux source-file "$TMUX_CONF"

