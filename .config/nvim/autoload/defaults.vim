" Defaults -----------------------------------------

" Functions --------------------------------------------------------------------
function! defaults#settings() abort
    echom "[._.] Loading default settings..."

    "if &compatible
    "   set nocompatible                     " Be iMproved
    "endif
    set autoread                             " Autoread Files
    set encoding=utf-8                       " UTF Encoding
    set mousefocus			         " Follow Mouse Focus
    set wmh=0			         " Split Vertically
    set fillchars=""                             " Window Characters
    set splitright			         " Split to the right
    set relativenumber		         " Relative line numbers
    set hlsearch			         " Highlight search matches
    set incsearch			         " Keep searching as we type
    " set ignorecase		         " Case insensitive matching
    set smartcase			         " Automatically match Case
    set history=700			         " History memory
    set undolevels=700		         " Undo memory
    set spelllang=en		         " Spellcheck Language
    set wildmode=longest:full,full           " First is longest, best match
    set wildmenu 			         " Second is full match & opens menu
    set nrformats=                           " Increment in Decimal, not binary
    set clipboard^=unnamedplus 	         " Prepend to clipboard
    set tabstop=8				 " Always insert spaces
    set softtabstop=4                        " instead of tabs
    set shiftwidth=4                         " In blocks of 4
    set expandtab                            " Safe spaces
    set ttimeoutlen=0                        " Fast key repeat
    set foldlevel=99                         " Set fold level
    set termguicolors                        " Use Truecolor Vim
    filetype indent plugin on                " Plugins & Filetypes
    syntax enable                            " Enable Syntax

endfunction


" Bindings ---------------------------------------------------------------------
function! defaults#bindings()
    echom "[._.] Loading default bindings..."
    " Space as Leader
    " let mapleader=" "

    " Disable arrow movement, resize splits instead.
    nnoremap <Up>    :resize +2<CR>
    nnoremap <Down>  :resize -2<CR>
    nnoremap <Left>  :vertical resize +2<CR>
    nnoremap <Right> :vertical resize -2<CR>

    " <;> as Buffer
    " nnoremap ; :Buffers<CR>
    " nnoremap <Leader>t :Files<CR>
    " nnoremap <Leader>r :Tags<CR>

    " Operators -- 
    " Sort in Visual Mode
    vnoremap <Leader>s :sort<CR> 

    " Escape Neovim Terminal
    "tnoremap <Esc> <C-\><C-n>

    " Ctrl Arrow Buffer Navigation
    " nnoremap <silent> <C-Right> <c-w>l
    " nnoremap <silent> <C-Left> <c-w>h
    " nnoremap <silent> <C-Up> <c-w>k
    " nnoremap <silent> <C-Down> <c-w>j

    " <Ctrl-hjkl> Split Navigation
    nnoremap <C-J> <C-W><C-J>
    nnoremap <C-K> <C-W><C-K>
    nnoremap <C-L> <C-W><C-L>
    nnoremap <C-H> <C-W><C-H>

    " Sort (in Visual Mode)
    " vnoremap <Leader>s :sort<CR> 

    " Highlight Next rewires n and N to do the highlighing
    nnoremap <silent> n   n:call functions#HLNext(0.4)<cr>
    nnoremap <silent> N   N:call functions#HLNext(0.4)<cr>
endfunction
