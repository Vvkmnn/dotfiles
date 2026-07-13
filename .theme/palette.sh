#!/usr/bin/env sh
# Vivek Menon - vvkmnn.xyz

# Shared Kanagawa Wave palette for shell-driven tools.
export DOT_THEME="kanagawa-wave"
export KANAGAWA_BG="#1f1f28"
export KANAGAWA_FG="#dcd7ba"
export KANAGAWA_MUTED="#727169"
export KANAGAWA_BORDER="#54546d"
export KANAGAWA_BLUE="#7e9cd8"
export KANAGAWA_AQUA="#7aa89f"
export KANAGAWA_GREEN="#76946a"
export KANAGAWA_YELLOW="#e6c384"
export KANAGAWA_ORANGE="#ff9e3b"
export KANAGAWA_RED="#e82424"
export KANAGAWA_PURPLE="#957fb8"
export BAT_THEME="Kanagawa"

# zsh-autosuggestions: pin explicit muted fg (was falling back to ANSI-8, only
# readable under a Kanagawa terminal — this makes it self-contained/portable).
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${KANAGAWA_MUTED}"

# eza: map file-type/permission/git/size colors to the Kanagawa palette (eza used
# its built-in defaults otherwise — the one off-palette CLI tool). Truecolor SGR.
# di=blue ex=green fi=fg ln=aqua or/w=red device=orange pipe=yellow socket/git-rename=purple date/other=muted punct=border
export EZA_COLORS="di=38;2;126;156;216:ex=38;2;118;148;106:fi=38;2;220;215;186:ln=38;2;122;168;159:or=38;2;232;36;36:bd=38;2;255;158;59:cd=38;2;255;158;59:pi=38;2;230;195;132:so=38;2;149;127;184:ur=38;2;230;195;132:uw=38;2;232;36;36:ux=38;2;118;148;106:ue=38;2;118;148;106:gr=38;2;230;195;132:gw=38;2;232;36;36:gx=38;2;118;148;106:tr=38;2;230;195;132:tw=38;2;232;36;36:tx=38;2;118;148;106:sn=38;2;118;148;106:sb=38;2;118;148;106:uu=38;2;230;195;132:un=38;2;114;113;105:gu=38;2;122;168;159:gn=38;2;114;113;105:da=38;2;114;113;105:ga=38;2;118;148;106:gm=38;2;255;158;59:gd=38;2;232;36;36:gv=38;2;149;127;184:gt=38;2;122;168;159:xx=38;2;84;84;109"
