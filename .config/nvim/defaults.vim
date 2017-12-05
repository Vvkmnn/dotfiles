" Defaults -----------------------------------------

" Be iMproved
if &compatible
  set nocompatible 
endif

" UTF Encoding
set encoding=utf-8

" Plugins & Filetypes
filetype plugin indent on

" Enable Syntax
syntax enable

" Term Colors (remove `no` if nested)
set notermguicolors

" Follow Mouse Focus
set mousefocus

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

" Hide Seperators
set fillchars+=vert:\ 
