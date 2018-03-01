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
    set autoindent                 " Autoindent new lines
    set backspace=indent,eol,start " Make backspace always backspace
    set complete-=i                " Insert mode completions
    set smarttab                   " Adopt <Tab> setup
    set tabstop=8                  " Always insert spaces
    set softtabstop=4              " instead of tabs
    set shiftwidth=4               " In blocks of 4
    set expandtab                  " Safe spaces
    set hlsearch                   " Highlight search matches
    set incsearch                  " Keep searching as we type
    set ignorecase                 " Case insensitive matching
    set smartcase                  " Automatically match Case
    set history=777                " History memory
    set undolevels=777             " Undo memory
    set spelllang=en               " Spellcheck Language
    set wildmode=longest:full,full " First autocomplete <Tab> is longest best match
    set wildmenu                   " Second autocomplete <Tab> opens menu
    set laststatus=2               " Always show status
    set ruler                      " Show x,y cursor position
    set nrformats-=octal           " Increment in Decimal, not binary
    set clipboard^=unnamedplus     " Prepend to clipboard
    set tabpagemax=50              " Maximum initial tabs
    set ttimeout                   " Let terminal keys timeout
    set ttimeoutlen=100            " Set that timeout duration
    set display+=lastline          " No @; show last line
    set tabstop=8                  " Always insert spaces
    set softtabstop=4              " instead of tabs
    set shiftwidth=4               " In blocks of 4
    set expandtab                  " Safe spaces
    set formatoptions+=j " Delete comment character when joining commented lines
    set foldlevel=99               " Set fold level
    set hidden                     " Required for multiple buffer ops
    set showtabline=2              " Always show Tabline
    set termguicolors              " Use Truecolor Vim
    set title titlestring=         " Enable Buffer Titles?
    set guioptions=M               " Skip loading menus
    set cursorline                 " Highlight Current Line
    set so=999                     " Keep cursorline in center 
    set sidescrolloff=5            " Mimimum side scrolling area
    set shell=/bin/zsh " Use Zsh
    colorscheme dracula            " Dracula!
    filetype indent plugin on      " Plugins & Filetypes
    syntax enable                  " Enable Syntax
endfunction
