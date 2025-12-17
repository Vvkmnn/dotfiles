#!/usr/bin/env bash
# Modern Homebrew setup using Brewfile
# Installs all formulae, casks, taps, and Mac App Store apps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${SCRIPT_DIR}/Resources/Brewfile"

echo "==> macOS package installation via Homebrew"

# Check for Homebrew, install if missing
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install from Brewfile
echo "Installing packages from Brewfile..."
if [[ -f "${BREWFILE}" ]]; then
    brew bundle install --file="${BREWFILE}"
else
    echo "Error: Brewfile not found at ${BREWFILE}"
    exit 1
fi

# Cleanup
echo "Cleaning up..."
brew cleanup

echo "✓ Homebrew setup complete"
