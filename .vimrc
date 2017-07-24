" Vivek Menon - vvkmnn.xyz
" 
"  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
"  MMMMMMMMMMMMMMMMMMMMMMNNmmmmNNMMMMMMMMMMMMMMMMMMMM
"  MMMMMMMMMMMMMMMMNho:.`        `-:ohNMMMMMMMMMMMMMM
"  MMMMMMMMMMMMMd+.                    .+dMMMMMMMMMMM
"  MMMMMMMMMMNs.                .shs+:.   .sMMMMMMMMM
"  MMMMMMMMMs`                -yMMMMMy.     `sMMMMMMM
"  MMMMMMMm-                 `MMMMMs`         -mMMMMM
"  MMMMMMd`                  .MMMMm            `dMMMM
"  MMMMMd`                   :MMMMd             `mMMM
"  MMMMM-            `odyo:. +MMMMy              -MMM
"  MMMMy           .sNMMMMh: oMMMMo               yMM
"  MMMM/           oMMMMy.   :MMMM+               /MM
"  MMMM.            sMMMd`    /MMM:               .MM
"  MMMM-             sMMMd`    /MM-               -MM
"  MMMM+              sMMMd`    /M`               +MM
"  MMMMm               sMMMh`    :                mMM
"  MMMMMo               yMMMh`                   oMMM
"  MMMMMM/               yMMMh                  /MMMM
"  MMMMMMMo               yMMMh                oMMMMM
"  MMMMMMMMh.              yMMMh             .hMMMMMM
"  MMMMMMMMMMs.             oydMh          .sMMMMMMMM
"  MMMMMMMMMMMMh:               .`       :hMMMMMMMMMM
"  MMMMMMMMMMMMMMNh+-                -+hNMMMMMMMMMMMM
"  MMMMMMMMMMMMMMMMMMMmhso+////+oshmMMMMMMMMMMMMMMMMM
"  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM



" Plugins ---------------------

" Plugin Directory
call plug#begin('~/.vim/plugged')

" Autoformat for Vim
Plug 'chiel92/vim-autoformat'
let g:autoformat_remove_trailing_spaces = 0

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
