"                       
"                       `......`                    
"                 ./shmMMMMMMMMMNmho:`              
"              :smMMMMMMMMMMMMMMMMMMMMms-           
"           `omMMMMMMMMMMMMMMMMm+:+shmMMMm+`        
"          oNMMMMMMMMMMMMMMMMd:     /mMMMMMN+       
"        -mMMMMMMMMMMMMMMMMMN     oNMMMMMMMMMd.     
"       /MMMMMMMMMMMMMMMMMMMd    -MMMMMMMMMMMMN-    
"      :MMMMMMMMMMMMMMMMMMMMy    :MMMMMMMMMMMMMN-   
"     `NMMMMMMMMMMMMNo:+shmMo    +MMMMMMMMMMMMMMm   
"     oMMMMMMMMMMMm/     :hM+    oMMMMMMMMMMMMMMM/  
"     mMMMMMMMMMMM/    /mMMMs    yMMMMMMMMMMMMMMMh  
"    `MMMMMMMMMMMMM/   :MMMMMs   hMMMMMMMMMMMMMMMm  
"    `MMMMMMMMMMMMMM:   /MMMMMs  mMMMMMMMMMMMMMMMd  
"     hMMMMMMMMMMMMMM:   /MMMMMs NMMMMMMMMMMMMMMMs  
"     :MMMMMMMMMMMMMMM:   /MMMMMyMMMMMMMMMMMMMMMM-  
"      hMMMMMMMMMMMMMMN:   /MMMMMMMMMMMMMMMMMMMMs   
"      `dMMMMMMMMMMMMMMN-   /MMMMMMMMMMMMMMMMMMh    
"       `hMMMMMMMMMMMMMMN-   /MMMMMMMMMMMMMMMMy     
"         +NMMMMMMMMMMMMMN-   +MMMMMMMMMMMMMN/      
"          `sNMMMMMMMMMMMMN+:` +MMMMMMMMMMNo`       
"            `+dMMMMMMMMMMMMMMNdNMMMMMMMd/`         
"               .+hNMMMMMMMMMMMMMMMMmy/`            
"                   `:+oyyhhhhyso/-`                
"                                                    
" © Vivek Menon
" v@vvkmnn.xyz 

" -----------------------------
" Plugins 
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

" Language Support
Plug 'sheerun/vim-polyglot'

" Vim tree navigation
" Plug 'scrooloose/nerdtree'

" Vim split navigation
Plug 'tpope/vim-vinegar'

" Vim Tiling Window Manager
Plug 'spolu/dwm.vim'

" Golden Ratio
" Plug 'roman/golden-ratio'

" Vim Fuzzy Find
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Plug 'junegunn/fzf.vim'

" Tmux Navigator
" Plug 'christoomey/vim-tmux-navigator'

" Commenting Operator gcc{motion}
Plug 'tpope/vim-commentary'

" Dash integration
Plug 'rizzatti/dash.vim'

" Syntax Highlighter
" Plug 'scrooloose/syntastic'

" Tab magic?
Plug 'tpope/vim-sleuth'

" Codi - interactive code scratchpads!
" Plug 'metakirby5/codi.vim'

" Git management!
Plug 'tpope/vim-fugitive'

" Autoformat for Vim
Plug 'chiel92/vim-autoformat'

" Dracula for Vim
Plug 'dracula/vim'

" Markdown Preview from Vi
" Plug 'kannokanno/previm'

" Matchit 
Plug 'adelarsq/vim-matchit'

" Vim Rainbow
Plug 'frazrepo/vim-rainbow'

" Open Default Browser
Plug 'tyru/open-browser.vim'

" Vim Airline (Status Bar)
Plug 'bling/vim-airline'

" Vim Airline Themes (for Dracula)
Plug 'vim-airline/vim-airline-themes'

" Vim Lightline
" Plug 'itchyny/lightline.vim'
 
" Initialize/Install Plugin System
call plug#end()

" -----------------------------
" Autoload
" -----------------------------

" VimPlug
autocmd VimEnter *
  \  if len(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" vim-commentary
autocmd FileType apache setlocal commentstring=#\ %s

" vim-rainbow
au FileType c,cpp,objc,objcpp call rainbow#load()

" -----------------------------
" Keybinds
" -----------------------------

" Space as Leader
let mapleader=" "

" Ctrl Arrow Buffer Navigation
nnoremap <silent> <C-Right> <c-w>l
nnoremap <silent> <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j

" Ctrl HJKL Split Navigation
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" FZF Completion
" imap <c-x><c-l> <plug>(fzf-complete-line)

" Sort in Visual Mode
vnoremap <Leader>s :sort<CR>

" -----------------------------
" Commands
" -----------------------------

" W for sudo :w
" NOTE https://www.cyberciti.biz/faq/vim-vi-text-editor-save-file-without-root-permission/
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

" -----------------------------
" Defaults
" -----------------------------

" Modern Vim
set nocompatible

" Follow Mouse Focus
set mousefocus

" Map Leader <Space>
let mapleader=" "

" Relative numbers
set relativenumber

" No swapfile
set noswapfile
set directory^=$HOME/.vim/tmp//

" Local Buffer Folder
set browsedir=buffer

" Manage Swaps and Backups
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//

" Smarter Regex
set hlsearch
set incsearch
set ignorecase
set smartcase

" History 
set history=700
set undolevels=700

" Sytnax Highlight Limiter
set synmaxcol=200

" Wild Menu! (Tab stuff)
set wildmenu
set wildmode=full

" Fonts & Powerline
set guifont=Inconsolata\ for\ Powerline:h15
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8

" Document Length
set tw=79
set nowrap
set fo-=t
"set colorcolumn=80
"highlight ColorColumn ctermfg=238 ctermbg=235

" Split Formatting
hi vertsplit ctermfg=238 ctermbg=235
hi LineNr ctermfg=237
hi StatusLine ctermfg=235 ctermbg=245
hi StatusLineNC ctermfg=235 ctermbg=237
hi Search ctermbg=58 ctermfg=15
hi Default ctermfg=1
hi clear SignColumn
hi SignColumn ctermbg=235

" Git Gutter formatting
hi GitGutterAdd ctermbg=235 ctermfg=245
hi GitGutterChange ctermbg=235 ctermfg=245
hi GitGutterDelete ctermbg=235 ctermfg=245
hi GitGutterChangeDelete ctermbg=235 ctermfg=245
hi EndOfBuffer ctermfg=237 ctermbg=235

" Statusline 
set statusline=%=%P\ %f\ %m
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2
set noshowmode

" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe = 'npm run lint --'

" Split Defaults
set wmh=0
set splitright
 
" Increment <C-a> and Subtract <C-x> in Decimal
set nrformats=

" Filetype Support
filetype off
filetype plugin indent on
syntax on

" Clipboard
set clipboard=unnamed,unnamedplus
set mouse=a

" Set background
set background=dark

" Set default indent to 4 spaces
set shiftwidth=4 softtabstop=4 expandtab

" Set Dracula color scheme
color dracula
let g:airline_theme='dracula'

" Snytastic glitter
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Codi
let g:codi#log = '/tmp/codi.log'

" Previm
augroup PrevimSettings
    autocmd!
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
augroup END

" MacVim
if has("gui_running")
   let s:uname = system("uname")
   if s:uname == "Darwin\n"
      set guifont=Inconsolata\ for\ Powerline:h15
   endif
endif

" Airline
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'
