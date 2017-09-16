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

" Commenting Operator gcc{motion}
Plug 'tpope/vim-commentary'

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
"           Defaults
" -----------------------------
 
" Increment <C-a> and Subtract <C-x> in Decimal
set nrformats=

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
" map <C-Esc> :NERDTreeToggle<CR> " idk what toggle to use

