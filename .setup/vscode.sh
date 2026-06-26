#!/usr/bin/env bash
# VS Code settings — reference snapshot from vBook.
# Not required to run. Prints instructions if you want to apply manually.

cat <<'EOF'

Tracked under ~/.vscode/ (already on disk if you cloned dotfiles):
  settings.json     user-level settings
  keybindings.json  user-level keybindings
  extensions.txt    extension IDs (one per line)

You may not need to apply these — VS Code's built-in Settings Sync
likely covers it. To apply manually anyway:

  cp ~/.vscode/settings.json    "$HOME/Library/Application Support/Code/User/settings.json"
  cp ~/.vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"
  xargs -n1 code --install-extension < ~/.vscode/extensions.txt

(For the `code` CLI you need to first run in VS Code:
  Cmd+Shift+P → "Shell Command: Install 'code' command in PATH")

To refresh this snapshot on vBook after tweaking VS Code:

  cp "$HOME/Library/Application Support/Code/User/settings.json"    ~/.vscode/settings.json
  cp "$HOME/Library/Application Support/Code/User/keybindings.json" ~/.vscode/keybindings.json
  code --list-extensions > ~/.vscode/extensions.txt
  dotfiles add .vscode && dotfiles commit -m "CHORE(vscode): Refresh snapshot"

EOF
