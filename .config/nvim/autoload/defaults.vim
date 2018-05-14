" Defaults -----------------------------------------

function! defaults#core() abort
    echom "[._.] Loading core defaults..."
    " set nocompatible           " Be iMproved
    filetype on
    filetype indent on "Filetype Indent
    filetype plugin on " Plugins
    syntax on " Force Syntax
    set shell=/bin/zsh " Use Zsh
endfunction

function! defaults#aesthetic() abort
    echom "[._.] Loading aesthetic defaults..."
    set mousefocus                 " Follow Mouse Focus
    set wmh=0                      " Split Vertically
    set fillchars=                 " Window Characters
    set ttyfast                " Faster redrawing.
    set lazyredraw             " Only redraw when necessary.
    set splitright                 " Split to the right
    set number " Show currenrt line number
    set relativenumber             " Relative line numbers
    set laststatus=2               " Always show status
    set ruler                      " Show x,y cursor position
    set nrformats-=octal           " Increment in Decimal, not binary
    set clipboard^=unnamedplus     " Prepend to clipboard
    set foldlevel=99               " Set fold level
    set hidden                     " Required for multiple buffer ops
    set showtabline=0              " Never show Tabline
    set termguicolors              " Use Truecolor Vim
    set guioptions=M               " Skip loading menus
    set cursorline                 " Highlight Current Line
    set so=999                     " Keep cursorline in center
    set sidescrolloff=5            " Mimimum side scrolling area
    set title titlestring=         " Enable Buffer Titles?
    set synmaxcol   =200       " Only highlight the first 200 columns.
    " if !has('gui_running')
    "     set t_Co=256
    " endif
endfunction

function! defaults#edit() abort
    echom "[._.] Loading editing defaults..."
    set backspace=indent,eol,start " Make backspace always backspace
    set complete-=i                " Insert mode completions
    set history=777                " Command History
    set undolevels=777             " Undo History
    set spelllang=en               " Spellcheck Language
    set wildmode=longest:full,full " First autocomplete <Tab> is longest best match
    set wildmenu                   " Second autocomplete <Tab> opens menu
    set ttimeout                   " Let terminal keys timeout
    set ttimeoutlen=100            " Set that timeout duration
    set nrformats-=octal           " Increment in Decimal, not binary
    set clipboard^=unnamedplus     " Prepend to clipboard
    set formatoptions+=j " Delete comment character when joining commented lines
    set report      =0         " Always report changed lines.
    set noshowmode               " Don't show current mode in command-line.
    set showcmd                " Show already typed keys when more are expected.
endfunction

function! defaults#search() abort
    echom "[._.] Loading search defaults..."
    set hlsearch                   " Highlight search matches
    set incsearch                  " Keep searching as we type
    set shortmess+=c            " Don't show match count
    set wrapscan               " Searches wrap around end-of-file.
    set ignorecase                 " Case insensitive matching
    " set smartcase                  " Automatically match Case
endfunction

function! defaults#indent() abort
    echom "[._.] Loading editing defaults..."
    set autoindent                 " Autoindent new lines
    set smartindent
    set smarttab                   " Adopt <Tab> setup
    set tabstop=8                  " Always insert spaces
    set softtabstop=4              " instead of tabs
    set shiftwidth=4               " In blocks of 4
    set expandtab                  " Safe spaces
endfunction

function! defaults#files() abort
    echom "[._.] Loading file defaults..."
    set autoread                   " Autoread Files
    set encoding=utf-8             " UTF Encoding
    if !isdirectory($VIM_PATH.'/files') && exists('*mkdir')
        call mkdir($VIM_PATH.'/files') " create directory if needed
    endif
    set backup " backup files
    set backupdir   =$VIM_PATH/files/backup/
    set backupext   =-vimbackup
    set backupskip  =
    set directory   =$VIM_PATH/files/swap// " swap files
    set updatecount =100
    set undofile " undo files
    set undodir     =$VIM_PATH/files/undo/
    set viminfo     ='100,n$VIM_PATH/files/info/viminfo " viminfo files
endfunction
