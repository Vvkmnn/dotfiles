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

[all](#all) · [macos](#macos) · [linux](#linux) · [windows](#windows)

### tracked

```
  shell ──────── .alias .functions .minimal .profile .rc .shell .zshrc .zshenv .zimrc .p10k.zsh
  editor ─────── .vimrc .config/nvim (submodule → v.nvim)
  ai ─────────── AI.md .ai/ (shared AI setup, Codex, ChatGPT)
  codex ──────── .codex/AGENTS.md .codex/skills/improve-codex/ (runtime ignored)
  claude ─────── .claude/ (thin adapter + Claude-specific rules/skills/hooks)
  git ────────── .gitconfig .gitmessage .gitattributes .gitmodules
  karabiner ──── .config/karabiner/ (json, scripts, assets, automatic_backups)
  sketchybar ─── .config/sketchybar/ (sketchybarrc, helpers, plugins)
  wm ─────────── .skhdrc .yabairc .config/yabai/
  terminal ───── .config/ (ghostty, tmux, kitty, alacritty, wezterm)
  launch ─────── .config/launchagents/ (tmux auto-start, mcp-proxy)
  alfred ─────── .alfred/ (~400 files: prefs, workflows, themes)
  fish ───────── .config/ (fish, fisher, omf)
  docker ─────── .docker/
  setup ──────── .setup/ (36 scripts, Brewfile)
  meta ────────── .github/README.md .github/LOG.md .logo .theme .assets/

  ~1136 files
```

### branches

```
  master ─────────── front page
  v-macos ────────── every Mac — one branch, ~/.ai/scale tunes each machine
  v-debian ────────── Debian
  v-debian-wsl ───── WSL
  archive/* ──────── every retired branch, kept forever
```

### commands

```
  dotfiles status            what changed
  dotfiles diff              see changes
  dotfiles add <file>        stage
  dotfiles commit -m "..."   commit
  dotfiles push              push
  dotfiles log --oneline     history
  dotfiles ls-files ~        tracked files
  dotfiles branch -a         all branches
```

## all

### [git](https://github.com/Vvkmnn/dotfiles)

```sh
  ssh ──────────────────────────────────────────────

ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub

  clone ────────────────────────────────────────────

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:Vvkmnn/dotfiles.git --branch <os> $HOME/.dotfiles
dotfiles stash
dotfiles checkout
dotfiles config status.showUntrackedFiles no

  conflicts ────────────────────────────────────────

mkdir -p .backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .backup/{}

  optional ─────────────────────────────────────────

git config --global credential.helper 'cache --timeout=7777'
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
```

#### [git-crypt](https://github.com/AGWA/git-crypt)

```sh
brew install git-crypt
git-crypt unlock ~/dotfiles.key
# key: ~/Documents/key (also in 1Password)

  verify ───────────────────────────────────────────

dotfiles show HEAD:.utcp_config.json | head -1
# → GITCRYPT header = still encrypted
# → JSON content = decrypted
```

### shell

#### [zcomet](https://github.com/agkozak/zcomet)

```sh
git clone https://github.com/agkozak/zcomet.git ~/.zcomet/bin
```

#### [fzf](https://github.com/junegunn/fzf)

```sh
brew install fzf
# shell integration loaded via .shell
# Ctrl-R ── fzf history search (vi-mode compatible)
# Ctrl-T ── fzf file finder
# Alt-C ─── fzf cd
```

#### zsh

```sh
chsh -s $(which zsh)
```

#### theme

```sh
~/.theme/README.md
~/.theme/current
# shared theme docs, palette, and rollback notes
```

### editor

#### [nvim](https://github.com/Vvkmnn/v.nvim.git)

`.config/nvim` → submodule

```sh
dotfiles submodule update --init --recursive

  brew ─────────────────────────────────────────────

brew install neovim

  debian (build from source) ───────────────────────

cd .neovim                                          \
&& make CMAKE_BUILD_TYPE=RelWithDebInfo             \
&& make install
```

#### [emacs](https://github.com/railwaycat/homebrew-emacsmacport)

```sh
brew tap railwaycat/emacsmacport
brew install emacs-mac                              \
  --with-spacemacs-icon --with-ctags                \
  --with-native-compilation --with-mac-metal        \
  --with-starter
```

### [tmux](https://github.com/tmux/tmux/wiki)

```sh
brew install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  config ── ~/.config/tmux/tmux.conf
  plugins ─ tpm, resurrect, continuum, minimal-tmux-status, tmux-battery
  server ── auto-starts at login via LaunchAgent (see macos > launch agents)
  restore ─ continuum auto-restores sessions on server start
  wrapper ─ ~/.config/tmux/tmux-server.sh (crash recovery, polls socket)
```

### ai

```
  shared AI layer ─────────────────────────────────

  AI.md ─────────────── root pointer for AI tools
  .ai/README.md ─────── shared machine setup charter
  .ai/codex.md ──────── Codex TUI/App daily-use policy
  .ai/chatgpt.md ────── ChatGPT macOS/iOS integration
  .ai/setup ─────────── one setup command
```

### [codex](https://developers.openai.com/codex)

```
  .codex/ ─────────────────────────────────────────

  AGENTS.md ───────────────────── Codex compatibility shim → ~/.ai
  skills/improve-codex/SKILL.md ─ one maintenance skill

  local-only, gitignored:
  auth · SQLite · logs · history · sessions · plugin caches · app runtime
```

### [claude](https://docs.anthropic.com/en/docs/claude-code)

```
  .claude/ ─────────────────────────────────────────

  ├── CLAUDE.md ─────── global instructions
  ├── PAST.md ───────── changelog of config changes
  ├── FUTURE.md ─────── ideas and future features
  ├── settings.json ─── plugins, hooks, permissions
  ├── statusline.sh ─── custom status bar
  │
  ├── rules/ ────────── 10 behavioral rules
  │   ├── explore.md       investigate before acting
  │   ├── verify.md        evidence-based claims
  │   ├── test.md          testing requirements
  │   ├── plan.md          plan lifecycle + tasks
  │   ├── minimize.md      simplicity principles
  │   ├── teach.md         educational insights
  │   ├── recover.md       error recovery
  │   ├── avoid.md         context efficiency
  │   ├── orchestrate.md   subagent delegation
  │   └── preview.md       preview before acting
  │
  ├── skills/ ───────── 29 custom skills
  │
  ├── hooks/ ────────── 6 event hooks (JS)
  │   ├── session-start.js      context + reminders
  │   ├── pre-tool-use.js       safety guards
  │   ├── post-tool-use.js      tracking
  │   ├── pre-compact.js        plan snapshot
  │   ├── notification.js       system alerts
  │   └── stop.js               session cleanup
  │
  └── mcp/ ──────────── 36 MCP servers
      ├── MCP.md            server inventory
      ├── config.json       mcp-proxy config (git-crypt)
      └── mcp.json.bak     encrypted backup (native format)
```

```
  secrets ──────────────────────────────────────────

  .utcp_config.json ─────────── code-mode servers   (git-crypt)
  .claude.json ─────────────── Claude config       (git-crypt)
  .claude/mcp/mcp.json.bak ── MCP backup          (git-crypt)
  .claude/mcp/config.json ─── mcp-proxy config    (git-crypt)

  key: ~/Documents/key (also in 1Password)
  new machine: git-crypt unlock ~/dotfiles.key
  .utcp_config.json decrypts → code-mode servers ready
  mcp.json.bak is portable backup in native mcpServers format
```

#### [mcp-proxy](https://github.com/TBXark/mcp-proxy)

NOT brew `mcp-proxy` (`sparfenyuk/mcp-proxy`, Python — different project)

```sh
go install github.com/TBXark/mcp-proxy@latest
mkdir -p ~/.claude/mcp/bin
cp "$(go env GOPATH)/bin/mcp-proxy" ~/.claude/mcp/bin/
```

## macos

### [xcode](https://developer.apple.com/xcode/resources/)

```sh
xcode-select --install
```

### [brew](https://brew.sh)

```sh
  install ──────────────────────────────────────────

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  Brewfile ─────────────────────────────────────────

brew bundle install --file=~/.setup/Resources/Brewfile

  individual ───────────────────────────────────────

brew install neovim gh jq fzf btop tmux bat        \
             coreutils gnupg fnm git-crypt go

  window management ────────────────────────────────

brew install koekeishiya/formulae/skhd              \
             koekeishiya/formulae/yabai
brew install FelixKratz/formulae/sketchybar

  casks ────────────────────────────────────────────

brew install --cask ghostty 1password alfred        \
                    karabiner-elements discord      \
                    chatgpt mullvadvpn

  node ─────────────────────────────────────────────

fnm install --lts

  python ───────────────────────────────────────────

brew install python3 pipx
pipx install virtualenv
```

### configure

#### [scripts](https://github.com/Vvkmnn/dotfiles/tree/v-macos/.setup)

```sh
chmod +x ~/.setup/*.sh
# ~/.setup/setup.sh     guided setup (runs others)
# ~/.setup/brew.sh      packages (or use Brewfile)
# ~/.setup/macos.sh     system defaults
# ~/.setup/fonts.sh     nerd fonts
# ~/.setup/mas.sh       Mac App Store apps
```

#### [defaults](https://macos-defaults.com)

```sh
  Dock ─────────────────────────────────────────────

defaults write com.apple.dock static-only -bool true
defaults write com.apple.dock orientation right
defaults write com.apple.dock tilesize -int 27

  Finder ───────────────────────────────────────────

defaults write com.apple.Finder AppleShowAllFiles true
defaults write com.apple.finder CreateDesktop false

  system ───────────────────────────────────────────

defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write NSGlobalDomain AppleHighlightColor -string "0.800000 0.200000 0.200000"
```

#### [services](https://github.com/koekeishiya/yabai/wiki)

```sh
  yabai scripting addition ─────────────────────────

echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) \
| cut -d " " -f 1) $(which yabai) --load-sa" \
| sudo tee /private/etc/sudoers.d/yabai

  start ────────────────────────────────────────────

skhd --start-service
yabai --start-service
brew services start felixkratz/formulae/sketchybar
```

#### [launch agents](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)

```sh
  templates use __HOME__ placeholder ── see .config/launchagents/README.md

  install ──────────────────────────────────────────

for f in ~/.config/launchagents/*.plist; do
    sed "s|__HOME__|$HOME|g" "$f" > ~/Library/LaunchAgents/$(basename "$f")
    launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/$(basename "$f")
done

  agents ───────────────────────────────────────────

  com.user.tmux          tmux server with crash recovery
                         requires: tmux, ~/.config/tmux/tmux-server.sh
                         sessions auto-restore via resurrect + continuum

  com.claude.mcp-proxy   shared MCP server proxy (TBXark/mcp-proxy)
                         requires: ~/.claude/mcp/bin/mcp-proxy, config.json
                         all Claude Code sessions share one proxy

  verify ───────────────────────────────────────────

launchctl list | grep -E "tmux|mcp-proxy"
```

## linux

### [debian](https://wiki.debian.org/LTS)

```sh
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install git zsh curl vim openssh-client \
                     aptitude build-essential         \
                     ninja-build gettext cmake unzip
```

## windows

### [wsl](https://learn.microsoft.com/en-us/windows/wsl/install)

```sh
winget install Debian.Debian
```

then follow [debian](#debian)

### [autohotkey](https://www.autohotkey.com/)

```sh
  capslock → Esc + Ctrl ────────────────────────────

cat .setup/capslock.ahk
explorer.exe .setup
```
