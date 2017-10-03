" Defaults -----------------------------------------

" Be iMproved
if &compatible
  set nocompatible 
endif

" Plugins & Filetypes
filetype plugin indent on

" Enable Syntax
syntax enable

" Term Colors
set termguicolors

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

" Bindings -----------------------------------------

" Keys --
" Space as Leader
let mapleader=" "

" Disable arrow movement, resize splits instead.
nnoremap <Up>    :resize +2<CR>
nnoremap <Down>  :resize -2<CR>
nnoremap <Left>  :vertical resize +2<CR>
nnoremap <Right> :vertical resize -2<CR>

" Swap : ; in Normal Mode and for easy command access
" nnoremap  :  ;
" Operators -- 
" Sort in Visual Mode
vnoremap <Leader>s :sort<CR> 

" Escape Neovim Terminal
:tnoremap <Esc> <C-\><C-n>

" This rewires n and N to do the highlighing
nnoremap <silent> n   n:call HLNext(0.4)<cr>
nnoremap <silent> N   N:call HLNext(0.4)<cr>

" Swap : ; in Normal Mode and for easy command access
"nnoremap  :  ;

" Windows --

" Ctrl HJKL Split Navigation
nnoremap <C-h> <C-W><C-H>
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>


" Functions ----------------------------------------

" Blink link with match
function! HLNext (blinktime)
       set invcursorline
       redraw
       exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
       set invcursorline
       redraw
   endfunction

