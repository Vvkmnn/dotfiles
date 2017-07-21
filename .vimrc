" Vivek Menon - vvkmnn.xyz


" Plugins ---------------------

" Plugin Directory
call plug#begin('~/.vim/plugged')

" Dracula for Vim
Plug 'dracula/vim'

" Vim Airline (Status Bar)
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='dracula' 

" Initialize plugin system
call plug#end()

" Defaults --------------------

" VIm, not VI 
set nocompatible

" macOS clipboard by default
set clipboard=unnamed

" Themes ---------------------

" Set background
set background=dark

" Dracula color scheme
syntax on
color dracula
