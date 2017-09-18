" Vivek Menon - vvkmnn.xyz

" ##################################################
" ##################################################
" ######################        ####################
" ################                    ##############
" #############                #######   ###########
" ###########                #########     #########
" #########                 ########         #######
" ########                  ######            ######
" #######                   ######             #####
" ######            ####### ######              ####
" #####           ######### ######               ###
" #####           #######   ######               ###
" #####            ######    #####               ###
" #####             ######    ####               ###
" #####              ######    ###               ###
" #####               ######    #                ###
" ######               ######                   ####
" #######               #####                  #####
" ########               #####                ######
" ##########              #####             ########
" ############             #####          ##########
" ##############               ##       ############
" ##################                ################
" ##################################################
" ##################################################
"
" -----------------------------
" Plugins ---------------------
" -----------------------------

" Vim-Plug Setup
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Vim Plugin Directory
call plug#begin('~/.vim/plugged')

" Sensible Defaults
Plug 'tpope/vim-sensible'

" Vim file navigation
Plug 'scrooloose/nerdtree'

"Tiling Window Manager
" Plug 'spolu/dwm.vim'

" Golden Ratio
Plug 'roman/golden-ratio'

" Vim Fuzzy Find
Plug 'kien/ctrlp.vim'

" Commenting Operator gcc{motion}
Plug 'tpope/vim-commentary'

" Dash integration
Plug 'rizzatti/dash.vim'

" Syntax Highlighter
Plug 'scrooloose/syntastic'

" Tab magic?
Plug 'tpope/vim-sleuth'

" Codi - interactive code scratchpads!
Plug 'metakirby5/codi.vim'

" Git management!
Plug 'tpope/vim-fugitive'

" Autoformat for Vim
Plug 'chiel92/vim-autoformat'

" Dracula for Vim
Plug 'dracula/vim'

" Vim Airline (Status Bar)
Plug 'bling/vim-airline'

" Vim Airline Themes (for Dracula)
Plug 'vim-airline/vim-airline-themes'

" Initialize/Install Plugin System
call plug#end()

" -----------------------------
"           Bindings
" -----------------------------

" Window Navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" CtrlP!
let g:ctrlp_map = '<c-p>'

" -----------------------------
"           Defaults
" -----------------------------

" Modern Vim
set nocompatible

" Follow Mouse Focus
set mousefocus

" Split Defaults
" set wmh=0
" set splitbelow
" set splitright
" 
" Increment <C-a> and Subtract <C-x> in Decimal
set nrformats=

" Plugin Support
filetype plugin on

" macOS clipboard 
set clipboard=unnamed

" Set background
set background=dark

" Set default indent to 4 spaces
set shiftwidth=4 softtabstop=4 expandtab

" Set Dracula color scheme
syntax on
color dracula
let g:airline_theme='dracula'

" Keep Nerdtree by default
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-Esc> :NERDTreeToggle<CR> " idk what toggle to use

" Snytastic glitter
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Codi
let g:codi#log = '/tmp/codi.log'

" CtrlP
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'

