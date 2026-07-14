#!/usr/bin/env sh
# Vivek Menon - vvkmnn.xyz

# Kanagawa Wave prompt overrides for Powerlevel10k.
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#e6c384'
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#7e9cd8'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7e9cd8'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#7fb4ca'
typeset -g POWERLEVEL9K_VCS_FOREGROUND='#7aa89f'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#e6c384'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#727169'
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='#727169'
typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%F{#dcd7ba}%n%f%F{#727169}@%m%f'
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%F{#727169}%n@%m%f'

function prompt_face() {
  p10k segment -t '%(?,%F{#76946a}[-_-]%f,%F{#e82424}[ಠ_ಠ]%f)'
}
