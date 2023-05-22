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
" mail@vvkmnn.xyz 

" -----------------------------
" Plugins 
" -----------------------------

" Vim-Jetpack Autosetup
" TODO Fix this, does nothing - added file to dotfiles
" let s:jetpackdir = expand('<sfile>:p:h') .. '/pack/jetpack/opt/vim-jetpack'
" let s:jetpackfile = s:jetpackdir .. '/plugin/jetpack.vim'
" let s:jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
" if !isdirectory(s:jetpackdir) || !filereadable(s:jetpackfile)
"       call system(printf('curl -fsSLo %s --create-dirs %s', s:jetpackfile, s:jetpackurl))
" endif

" TODO does work, just wrong urls and path
" let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
" if empty(glob(data_dir . '/autoload/pack.vim'))
"   silent execute '!curl -fLo '.data_dir.'/autoload/jetpack.vim --create-dirs  https://raw.githubusercontent.com/tani/vim-jetpack/master/autoload/jetpack.vim'
"     autocmd VimEnter * JetpackSync | source $MYVIMRC
" endif

" Adjusting the packadd command
packadd vim-jetpack

call jetpack#begin()
Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap

Jetpack 'https://github.com/dense-analysis/ale'

Jetpack 'ctrlpvim/ctrlp.vim'
" Jetpack 'junegunn/fzf.vim'
" Jetpack 'junegunn/fzf', { 'do': {-> fzf#install()} }

" Jetpack 'neoclide/coc.nvim', { 'branch': 'release' }
" Jetpack 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }

" Jetpack 'vlime/vlime', { 'rtp': 'vim' }

Jetpack 'dracula/vim', { 'as': 'dracula' }
" Jetpack 'dracula/vim', { 'as': 'dracula' }

" Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }
" Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }

" Sensible Defaults
Jetpack 'tpope/vim-sensible'

" Language Support
Jetpack 'sheerun/vim-polyglot'

" Copilot
" Jetpack 'github/copilot.vim'

" Vim tree navigation
" Plug 'scrooloose/nerdtree'

" " Vim split navigation
Jetpack 'tpope/vim-vinegar'

" Vim Tiling Window Manager
" Jetpack 'spolu/dwm.vim'

" Golden Ratio
" Jetpack 'roman/golden-ratio'

" Vim Fuzzy Find
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Plug 'junegunn/fzf.vim'

" Tmux Navigator
" Plug 'christoomey/vim-tmux-navigator'

" Commenting Operator gcc{motion}
Jetpack 'tpope/vim-commentary'

" Dash integration
Jetpack 'rizzatti/dash.vim'

" Syntax Highlighter
" Plug 'scrooloose/syntastic'

" Tab magic?
Jetpack 'tpope/vim-sleuth'

" Codi - interactive code scratchpads!
" Plug 'metakirby5/codi.vim'

" Git management!
" Jetpack 'tpope/vim-fugitive'

" Autoformat for Vim
Jetpack 'chiel92/vim-autoformat'

" Dracula for Vim
" Plug 'dracula/vim'

" OneDark Vim
Jetpack 'rakr/vim-one'

" Markdown Preview from Vi
" Plug 'kannokanno/previm'

" Matchit 
Jetpack 'adelarsq/vim-matchit'

" Vim Rainbow
Jetpack 'frazrepo/vim-rainbow'

" Open Default Browser
Jetpack 'tyru/open-browser.vim'

" Vim Airline (Status Bar)
Jetpack 'bling/vim-airline'

" Vim Airline Themes (for Dracula)
" Jetpack 'vim-airline/vim-airline-themes'

" Vim Lightline
" Jetpack 'itchyny/lightline.vim'
call jetpack#end()

" Vim-Jetpack Autoinstall
for name in jetpack#names()
    if !jetpack#tap(name)
          call jetpack#sync()
          break
    endif
endfor

" Vim-Plug Setup
" if empty(glob('~/.vim/autoload/plug.vim'))
"   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
"     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif

" Vim Plugin Directory
" call plug#begin('~/.vim/plugged')

" Sensible Defaults
" Jetpack 'tpope/vim-sensible'

" " Language Support
" Jetpack 'sheerun/vim-polyglot'
" 
" " Copilot
" " Plug 'github/copilot.vim'
" 
" " Vim tree navigation
" " Plug 'scrooloose/nerdtree'
" 
" " " Vim split navigation
" Plug 'tpope/vim-vinegar'
" 
" " Vim Tiling Window Manager
" Plug 'spolu/dwm.vim'
" 
" " Golden Ratio
" " Plug 'roman/golden-ratio'
" 
" " Vim Fuzzy Find
" " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" " Plug 'junegunn/fzf.vim'
" 
" " Tmux Navigator
" " Plug 'christoomey/vim-tmux-navigator'
" 
" " Commenting Operator gcc{motion}
" Plug 'tpope/vim-commentary'
" 
" " Dash integration
" Plug 'rizzatti/dash.vim'
" 
" " Syntax Highlighter
" " Plug 'scrooloose/syntastic'
" 
" " Tab magic?
" Plug 'tpope/vim-sleuth'
" 
" " Codi - interactive code scratchpads!
" " Plug 'metakirby5/codi.vim'
" 
" " Git management!
" Plug 'tpope/vim-fugitive'
" 
" " Autoformat for Vim
" Plug 'chiel92/vim-autoformat'
" 
" " Dracula for Vim
" " Plug 'dracula/vim'
" 
" " OneDark Vim
" Plug 'rakr/vim-one'
" 
" " Markdown Preview from Vi
" " Plug 'kannokanno/previm'
" 
" " Matchit 
" Plug 'adelarsq/vim-matchit'
" 
" " Vim Rainbow
" Plug 'frazrepo/vim-rainbow'
" 
" " Open Default Browser
" Plug 'tyru/open-browser.vim'
" 
" " Vim Airline (Status Bar)
" " Plug 'bling/vim-airline'
" 
" " Vim Airline Themes (for Dracula)
" " Plug 'vim-airline/vim-airline-themes'
" 
" " Vim Lightline
" Plug 'itchyny/lightline.vim'

" Initialize/Install Plugin System
" call plug#end()

" Statusline -----

" TODO Slow as hell for some reason
" function! GitBranch()
"     return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
" endfunction
" 
" function! StatuslineGit()
"   let l:branchname = GitBranch()
"   return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
" endfunction
" 
" set laststatus=2
" set statusline=
" set statusline+=%#PmenuSel#
" set statusline+=%{StatuslineGit()}
" set statusline+=%#LineNr#
" set statusline+=\ %f
" set statusline+=%#CursorColumn#
" set statusline+=\ %y
" set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
" set statusline+=\[%{&fileformat}\]
" set statusline+=\ %p%%
" set statusline+=\ %l:%c
" set statusline+=\

" -----------------------------
" Autoload
" -----------------------------

" VimPlug
" autocmd VimEnter *
"   \  if len(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
"   \|   PlugInstall --sync | q
"   \| endif

" vim-commentary
autocmd FileType apache setlocal commentstring=#\ %s

" vim-rainbow
au FileType c,cpp,objc,objcpp call rainbow#load()

" -----------------------------
" Keybinds
" -----------------------------

" Space as Leader
let mapleader=" "

" Escape via jj
inoremap jj <ESC>

" Ctrl+S to Save
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>

" Ctrl+Q to Save
noremap <silent> <C-Q>          :exit<CR>
vnoremap <silent> <C-Q>         <C-C>:exit<CR>
inoremap <silent> <C-Q>         <C-O>:exit<CR>


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
" set relativenumber

" Hybrid numbers
" set number relativenumber
" set nu rnu

" https://jeffkreeftmeijer.com/vim-number/
set number

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

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
" set statusline=%=%P\ %f\ %m
" set fillchars=vert:\ ,stl:\ ,stlnc:\ 
" set laststatus=2
" set noshowmode

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
" set background=dark

" Set default indent to 4 spaces
set shiftwidth=4 softtabstop=4 expandtab

" Set Dracula color scheme
" color dracula
" let g:airline_theme='dracula'

" Vim Onedark
let g:airline_theme='one'
set background=dark " for the dark version
colorscheme one
" set background=light " for the light version

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
