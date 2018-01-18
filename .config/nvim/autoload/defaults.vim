" Defaults -----------------------------------------

if &compatible
    set nocompatible                   " Be iMproved
endif
set autoread                           " Autoread Files
set encoding=utf-8                     " UTF Encoding
filetype indent plugin on              " Plugins & Filetypes
syntax enable                          " Enable Syntax
colorscheme dracula                    " Dracula!
set mousefocus " Follow Mouse Focus

function! defaults#splits() abort
    set wmh=0 " Split Vertically
    set splitright " Split to the right

    " Relative numbers
    set relativenumber

    " Smarter Regex
    set hlsearch
    set incsearch
    set ignorecase
    set smartcase

    " History
    set history=700
    set undolevels=700

    " Spellcheck
    set spelllang=en
    " set spell

    " Wild Menu! (Tab stuff)
    set wildmenu
    set wildmode=full

    " Increment <C-a> and Subtract <C-x> in Decimal
    set nrformats=

    " macOS clipboard
    set clipboard+=unnamedplus

    " Set default indent to 4 spaces
    set shiftwidth=4 softtabstop=4 expandtab

    " Fast Keys
    set ttimeoutlen=0

    " Multiple Buffer Operations
    set hidden

    " Set Fold Level
    set foldlevel=99

    " Hide Separators
    set fillchars+=vert:\
