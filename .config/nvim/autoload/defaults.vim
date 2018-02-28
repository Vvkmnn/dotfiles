" Defaults -----------------------------------------

function! defaults#settings() abort
    echom "[._.] Loading default settings..."
    " if &compatible
    "   set nocompatible           " Be iMproved
    " endif
    set autoread                   " Autoread Files
    set encoding=utf-8             " UTF Encoding
    set mousefocus                 " Follow Mouse Focus
    set wmh=0                      " Split Vertically
    set fillchars=                 " Window Characters
    set splitright                 " Split to the right
    set relativenumber             " Relative line numbers
    set hlsearch                   " Highlight search matches
    set incsearch                  " Keep searching as we type
    set ignorecase                 " Case insensitive matching
    set smartcase                  " Automatically match Case
    set history=700                " History memory
    set undolevels=700             " Undo memory
    set spelllang=en               " Spellcheck Language
    set wildmode=longest:full,full " First is longest, best match
    set wildmenu                   " Second is full match & opens menu
    set nrformats=                 " Increment in Decimal, not binary
    set clipboard^=unnamedplus     " Prepend to clipboard
    set tabstop=8                  " Always insert spaces
    set softtabstop=4              " instead of tabs
    set shiftwidth=4               " In blocks of 4
    set expandtab                  " Safe spaces
    set ttimeoutlen=0              " Fast key repeat
    set foldlevel=99               " Set fold level
    set hidden                     " Required for multiple buffer ops
    set showtabline=2              " Always show Tabline
    set termguicolors              " Use Truecolor Vim
    set title titlestring=         " Enable Buffer Titles?
    set guioptions=M               " Skip loading menus
    set cursorline                 " Highlight Current Line
    set shell=/bin/zsh             " Use Zsh
    colorscheme dracula            " Dracula!
    filetype indent plugin on      " Plugins & Filetypes
    syntax enable                  " Enable Syntax
endfunction
