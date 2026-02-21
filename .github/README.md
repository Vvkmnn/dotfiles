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
  shell ──────── .alias .functions .profile .rc .shell .zshrc .zshenv .zimrc .p10k.zsh
  editor ─────── .vimrc .config/nvim (submodule → v.nvim)
  claude ─────── .claude/ (9 rules, 28 skills, 13 commands, 6 hooks, 36 servers)
  git ────────── .gitconfig .gitmessage .gitattributes .gitmodules
  karabiner ──── .config/karabiner/ (json, scripts, automatic_backups)
  sketchybar ─── .config/sketchybar/ (sketchybarrc, plugins)
  wm ─────────── .skhdrc .yabairc .config/yabai/
  terminal ───── .config/ (ghostty, tmux, kitty, alacritty, wezterm)
  alfred ─────── .alfred/ (~400 files: prefs, workflows, themes)
  fish ───────── .config/ (fish, fisher, omf)
  docker ─────── .docker/
  setup ──────── .setup/ (36 scripts, Brewfile)
  meta ────────── .github/README.md .logo .theme .assets/

  ~1126 files
```

### branches

```
  master ─────────── base
  v-macos-macbook ── MacBook
  v-macos-studio ─── Mac Studio
  v-macos ────────── generic macOS
  v-debian ────────── Debian
  v-debian-wsl ───── WSL
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

ssh-keygen -t rsa -b 4096 -C "you@example.com"
cat ~/.ssh/id_rsa.pub

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

### [nvim](https://github.com/Vvkmnn/v.nvim.git)

`.config/nvim` → submodule

```sh
dotfiles submodule update --init --recursive
```

### [tmux](https://github.com/tmux-plugins/tpm)

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### [claude](https://docs.anthropic.com/en/docs/claude-code)

```sh
  decrypt ──────────────────────────────────────────
  code-mode servers restore automatically

git-crypt unlock ~/dotfiles.key

  verify ───────────────────────────────────────────

dotfiles show HEAD:.utcp_config.json | head -1
# → GITCRYPT header means still encrypted
# → JSON content means decrypted, code-mode servers ready
```

```
  .claude/ ─────────────────────────────────────────

  ├── CLAUDE.md ─────── global instructions
  ├── PAST.md ───────── changelog of config changes
  ├── FUTURE.md ─────── ideas and future features
  ├── settings.json ─── plugins, hooks, permissions
  ├── statusline.sh ─── custom status bar
  │
  ├── rules/ ────────── 9 behavioral rules
  │   ├── explore.md       investigate before acting
  │   ├── verify.md        evidence-based claims
  │   ├── test.md          testing requirements
  │   ├── minimize.md      simplicity principles
  │   ├── teach.md         educational insights
  │   ├── recover.md       error recovery
  │   ├── avoid.md         context efficiency
  │   ├── orchestrate.md   subagent delegation
  │   └── preview.md       preview before acting
  │
  ├── skills/ ───────── 28 custom skills
  ├── commands/ ─────── 13 slash commands
  │
  ├── hooks/ ────────── 6 event hooks (JS)
  │   ├── session-start.js      context + reminders
  │   ├── pre-tool-use.js       safety guards
  │   ├── post-tool-use.js      tracking
  │   ├── permission-request.js approval flow
  │   ├── notification.js       system alerts
  │   └── stop.js               session cleanup
  │
  └── mcp/ ──────────── 36 MCP servers
      ├── MCP.md            server inventory
      └── mcp.json.bak     encrypted backup (native format)
```

```
  secrets ──────────────────────────────────────────

  .utcp_config.json ──────── code-mode servers   (git-crypt)
  .claude.json ────────────── Claude config       (git-crypt)
  .claude/mcp/mcp.json.bak ─ MCP backup          (git-crypt)

  key: ~/Documents/key (also in 1Password)
  new machine: git-crypt unlock ~/dotfiles.key
  .utcp_config.json decrypts → code-mode servers ready
  mcp.json.bak is portable backup in native mcpServers format
```

### setup

```sh
chmod +x ~/.setup/*.sh
# ~/.setup/setup.sh     guided setup (runs others)
# ~/.setup/brew.sh      packages (or use Brewfile)
# ~/.setup/macos.sh     system defaults
# ~/.setup/fonts.sh     nerd fonts
# ~/.setup/mas.sh       Mac App Store apps
# ~/.setup/zsh.sh       shell setup
# ~/.setup/tmux.sh      tmux config
# ~/.setup/nvim.sh      neovim setup
# ~/.setup/debian.sh    debian packages
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
             coreutils gnupg fnm

  window management ────────────────────────────────

brew install koekeishiya/formulae/skhd              \
             koekeishiya/formulae/yabai
brew install FelixKratz/formulae/sketchybar

  casks ────────────────────────────────────────────

brew install --cask ghostty 1password alfred        \
                    karabiner-elements discord      \
                    chatgpt mullvadvpn

  node ─────────────────────────────────────────────

# nvm install node                                  # deprecated
fnm install --lts

  python ───────────────────────────────────────────

brew install python3 pipx
pipx install virtualenv
```

### defaults

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

### services

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

### [nvim](https://neovim.io/)

```sh
brew install neovim
```

### [emacs](https://github.com/railwaycat/homebrew-emacsmacport)

```sh
brew tap railwaycat/emacsmacport
brew install emacs-mac                              \
  --with-spacemacs-icon --with-ctags                \
  --with-native-compilation --with-mac-metal        \
  --with-starter
```

## linux

### [debian](https://wiki.debian.org/LTS)

```sh
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install git zsh curl vim openssh-client \
                     aptitude build-essential         \
                     ninja-build gettext cmake unzip
```

### zsh

```sh
chsh -s $(which zsh)
```

### [nvim](https://neovim.io/)

build from source on older Debian

```sh
cd .neovim                                          \
&& make CMAKE_BUILD_TYPE=RelWithDebInfo             \
&& make install
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
