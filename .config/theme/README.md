# theme

```
~/.theme/
├── README.md
├── current
├── old.sh
├── palette.sh
├── tmux/
├── zsh/
├── btop/
├── git/
├── lf/
└── yazi/
```

## purpose

This directory is the source of truth for shared terminal/editor theming.
It currently drives the Kanagawa Wave rollout across shell, tmux, Ghostty, Neovim, btop, bat, git tooling, Yazi, Lazygit, and supporting docs.

## active theme

`~/.theme/current`

Current value:

```sh
kanagawa-wave
```

## rollback

### previous prompt theme

Legacy `~/.theme` file preserved as:

```sh
~/.theme/old.sh
```

### restore previous app themes

- Ghostty: restore the previous terminal theme in `~/.config/ghostty/config` (previously `tokyonight`)
- Neovim: restore previous colorscheme in `~/.config/nvim/lua/plugins/modify.lua`
- tmux: remove Kanagawa source block and revert the status/border colors in `~/.config/tmux/tmux.conf`
- shell: remove the `~/.theme/*` sourcing block from `~/.shell`
- btop: restore `color_theme = "Default"` in `~/.config/btop/btop.conf`
- git: remove `path = ~/.theme/git/delta.gitconfig` from `~/.gitconfig`
- yazi/lazygit: remove the symlinked configs in `~/.config/yazi/theme.toml` and `~/.config/lazygit/config.yml` if you want to detach them from `~/.theme/`

## reference

- Docs pointer: `~/.github/README.md`
- Shell pointer: `~/.shell`

## current wiring

```sh
Ghostty     -> ~/.config/ghostty/config                          # theme = Kanagawa Wave
Neovim      -> ~/.config/nvim/lua/plugins/modify.lua             # rebelot/kanagawa.nvim wave
            -> ~/.config/nvim/lua/plugins/custom.lua
Tmux        -> ~/.config/tmux/tmux.conf                          # sources ~/.theme/tmux/kanagawa-wave.conf
            -> ~/.config/tmux/morbid_year
Shell       -> ~/.shell
Prompt      -> ~/.theme/zsh/p10k.zsh
fzf         -> ~/.theme/zsh/fzf.sh
bat         -> ~/.config/bat/themes/Kanagawa.tmTheme
btop        -> ~/.config/btop/themes/kanagawa-wave.theme
Git         -> ~/.theme/git/delta.gitconfig
Lazygit     -> ~/.theme/git/lazygit.yml
Yazi        -> ~/.theme/yazi/theme.toml
lf          -> ~/.theme/lf/colors.sh                             # LF_COLORS (256-color Kanagawa)
            -> ~/.config/lf/lfrc                                 # preview via bat (BAT_THEME=Kanagawa)
Sketchybar  -> ~/.config/sketchybar/sketchybarrc                 # palette vars
            -> ~/.config/sketchybar/helpers/bar-daemon.swift      # k* constants (compiled)
            -> ~/.config/sketchybar/plugins/space.sh
            -> ~/.config/sketchybar/plugins/startup_cascade.sh
            -> ~/.config/sketchybar/plugins/internet_animate.sh
Claude SL   -> ~/.claude/statusline.sh                            # true-color ANSI escapes
```

## palette cross-reference

All hex values trace to the same Kanagawa Wave source (`rebelot/kanagawa.nvim`).

| Role         | Hex       | Kanagawa name  | Ghostty | Neovim | Sketchybar | Claude SL | tmux |
|--------------|-----------|----------------|---------|--------|------------|-----------|------|
| foreground   | `#dcd7ba` | fujiWhite      | fg      | fg     | kWhite     | default*  | fg   |
| background   | `#1f1f28` | sumiInk1       | bg      | bg     | black**    | n/a       | default |
| dim          | `#727169` | fujiGray       | p8      | yes    | kDim       | GRAY      | n/a  |
| red          | `#e82424` | samuraiRed     | p9      | yes    | kRed       | RED       | n/a  |
| green        | `#76946a` | autumnGreen    | p2      | yes    | n/a        | GREEN     | n/a  |
| orange       | `#ffa066` | surimiOrange   | —†      | yes    | kOrange    | ORANGE    | n/a  |
| gold         | `#e6c384` | carpYellow     | p11     | yes    | kGold      | B (icons) | bg accent |
| blue         | `#7e9cd8` | crystalBlue    | p4      | yes    | kBlue      | n/a       | n/a  |
| subdued      | `#c8c093` | oldWhite       | p7      | yes    | kOldWhite  | n/a       | n/a  |
| empty        | `#54546d` | sumiInk4       | —       | yes    | DIM_GRAY   | n/a       | n/a  |
| power mid    | `#ff5d62` | peachRed       | —       | yes    | kPeach     | n/a       | n/a  |

`*` Claude statusline inherits terminal fg (= fujiWhite via Ghostty).
`**` Sketchybar bar bg is pure black (`#000000`) for macOS notch blending.
`†` surimiOrange is from kanagawa.nvim extras, not the Ghostty 16-color palette.

Note: `palette.sh` exports `KANAGAWA_ORANGE=#ff9e3b` (roninYellow) for shell tools like fzf.
Sketchybar/statusline use `#ffa066` (surimiOrange) instead — it's the diagnostic/warning color in kanagawa.nvim, better suited for alert states. Both are valid kanagawa oranges for different roles.

## installed tools

```sh
delta    git pager / diff viewer
eza      modern ls replacement
lf       file manager TUI (replaced yazi — yazi has Ghostty+tmux DCS probe issues)
lazygit  git TUI
```

## quick checks

```sh
git config --global --includes --get core.pager
bat --list-themes | rg Kanagawa
tmux source-file ~/.config/tmux/tmux.conf
zsh -n ~/.shell
```

## tmux follow-up

A few tmux colors are still hard-coded in `~/.config/tmux/tmux.conf` even though the active Kanagawa palette is sourced from `~/.theme/tmux/kanagawa-wave.conf`.

Current concern:

- tmux behavior is correct now, but the file still has some theme debt
- examples include activity style, border fallback colors, and battery charging color
- if tmux styling starts drifting later, move those last literals into `~/.theme/tmux/kanagawa-wave.conf`

This is safe to leave as-is for now unless the visuals start to bother you again.
