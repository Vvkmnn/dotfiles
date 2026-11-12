#!/usr/bin/env sh
# Vivek Menon - vvkmnn.xyz

# Kanagawa Wave LS_COLORS for lf.
# lf inherits LS_COLORS for file coloring — this sets directory, symlink,
# executable, and file-type colors to match the Kanagawa palette.
#
# Reference: ~/.theme/palette.sh for hex values, ~/.theme/README.md for wiring.

# Kanagawa palette mapped to 256-color approximations:
#   blue    (#7e9cd8) -> 110    directories
#   aqua    (#7aa89f) -> 109    symlinks
#   green   (#76946a) -> 107    executables
#   gold    (#e6c384) -> 186    archives
#   orange  (#ff9e3b) -> 214    media
#   purple  (#957fb8) -> 140    images
#   red     (#e82424) -> 196    broken symlinks
#   dim     (#727169) -> 245    backup/temp files

export LF_COLORS="\
di=38;5;110:\
ln=38;5;109:\
ex=38;5;107:\
or=38;5;196:\
mi=38;5;196:\
*.tar=38;5;186:\
*.gz=38;5;186:\
*.zip=38;5;186:\
*.7z=38;5;186:\
*.bz2=38;5;186:\
*.xz=38;5;186:\
*.rar=38;5;186:\
*.jpg=38;5;140:\
*.jpeg=38;5;140:\
*.png=38;5;140:\
*.gif=38;5;140:\
*.svg=38;5;140:\
*.webp=38;5;140:\
*.mp4=38;5;214:\
*.mkv=38;5;214:\
*.mov=38;5;214:\
*.mp3=38;5;214:\
*.flac=38;5;214:\
*.wav=38;5;214:\
*.pdf=38;5;186:\
*.md=38;5;109:\
*.json=38;5;186:\
*.toml=38;5;186:\
*.yaml=38;5;186:\
*.yml=38;5;186:\
*.conf=38;5;186:\
*.log=38;5;245:\
*.bak=38;5;245:\
*.tmp=38;5;245:\
*.swp=38;5;245:\
*.lock=38;5;245:\
"
