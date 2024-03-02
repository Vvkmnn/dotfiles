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

" " Vim-Jetpack Autosetup
" " TODO Fix this, does nothing - added file to dotfiles
" " let s:jetpackdir = expand('<sfile>:p:h') .. '/pack/jetpack/opt/vim-jetpack'
" " let s:jetpackfile = s:jetpackdir .. '/plugin/jetpack.vim'
" " let s:jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
" " if !isdirectory(s:jetpackdir) || !filereadable(s:jetpackfile)
" "       call system(printf('curl -fsSLo %s --create-dirs %s', s:jetpackfile, s:jetpackurl))
" " endif
" 
" " Adjusting the packadd command
" packadd vim-jetpack
" 
" call jetpack#begin()
" Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap
" 
" Jetpack 'https://github.com/dense-analysis/ale'
" 
" Jetpack 'ctrlpvim/ctrlp.vim'
" " Jetpack 'junegunn/fzf.vim'
" " Jetpack 'junegunn/fzf', { 'do': {-> fzf#install()} }
" 
" " Jetpack 'neoclide/coc.nvim', { 'branch': 'release' }
" " Jetpack 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }
" 
" " Jetpack 'vlime/vlime', { 'rtp': 'vim' }
" 
" " Jetpack 'dracula/vim', { 'as': 'dracula' }
" " Jetpack 'dracula/vim', { 'as': 'dracula' }
" 
" " Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }
" " Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }
" 
" " Sensible Defaults
" Jetpack 'tpope/vim-sensible'
" 
" " Language Support
" Jetpack 'sheerun/vim-polyglot'
" 
" " Copilot
" " Jetpack 'github/copilot.vim'
" 
" " Vim tree navigation
" " Plug 'scrooloose/nerdtree'
" 
" " " Vim split navigation
" Jetpack 'tpope/vim-vinegar'
" 
" " Vim Tiling Window Manager
" Jetpack 'spolu/dwm.vim'
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
" Jetpack 'tpope/vim-commentary'
" 
" " Dash integration
" Jetpack 'rizzatti/dash.vim'
" 
" " Syntax Highlighter
" " Plug 'scrooloose/syntastic'
" 
" " Tab magic?
" Jetpack 'tpope/vim-sleuth'
" 
" " Codi - interactive code scratchpads!
" " Plug 'metakirby5/codi.vim'
" 
" " Git management!
" " Jetpack 'tpope/vim-fugitive'
" 
" " Autoformat for Vim
" Jetpack 'chiel92/vim-autoformat'
" 
" " Dracula for Vim
" " Plug 'dracula/vim'
" 
" " OneDark Vim
" Jetpack 'rakr/vim-one'
" 
" " Markdown Preview from Vi
" " Plug 'kannokanno/previm'
" 
" " Matchit 
" Jetpack 'adelarsq/vim-matchit'
" 
" " Vim Rainbow
" Jetpack 'frazrepo/vim-rainbow'
" 
" " Open Default Browser
" Jetpack 'tyru/open-browser.vim'
" 
" " Vim Airline (Status Bar)
" " Plug 'bling/vim-airline'
" 
" " Vim Airline Themes (for Dracula)
" " Plug 'vim-airline/vim-airline-themes'
" 
" " Vim Lightline
" " Jetpack 'itchyny/lightline.vim'
" call jetpack#end()
" 
" " Vim-Jetpack Autoinstall
" for name in jetpack#names()
"     if !jetpack#tap(name)
"           call jetpack#sync()
"           break
"     endif
" endfor
" 
" " Vim-Plug Setup
" " if empty(glob('~/.vim/autoload/plug.vim'))
" "   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
" "     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" "   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" " endif
" 
" " Vim Plugin Directory
" " call plug#begin('~/.vim/plugged')
" 
" " Sensible Defaults
" " Jetpack 'tpope/vim-sensible'
" 
" Normally this if-block is not needed, because `:set nocp` is done
" automatically when .vimrc is found. However, this might be useful
" when you execute `vim -u .vimrc` from the command line.
if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

" if exists('+packpath')
"       set packpath^=$XDG_CONFIG_HOME/vim,$XDG_CACHE_HOME/vim
" endif

set packpath^=~/.vim


function! PackInit() abort
  packadd minpac

  call minpac#init() " {'verbose':3})
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  
  " call minpac#add('vim-jp/syntax-vim-ex')
  " call minpac#add('tyru/open-browser.vim')
  call minpac#add('ctrlpvim/ctrlp.vim') " fzf built in vim
  call minpac#add('w0rp/ale') " Async Lint Engine

  call minpac#add('tpope/vim-sensible') " Sensible Defaults
  call minpac#add('sheerun/vim-polyglot') " Language Support
  " call minpac#add('puremourning/vimspector') " Graphical debugger for Vim
  
  " call minpac#add('github/copilot.vim') " Copilot
  " call minpac#add('scrooloose/nerdtree') " Vim tree navigation
  call minpac#add('tpope/vim-vinegar') " Vim split navigation
  " call minpac#add('spolu/dwm.vim') " Vim Tiling Window Manager
  " call minpac#add('roman/golden-ratio') " Golden Ratio
  " call minpac#add('christoomey/vim-tmux-navigator') " Tmux Navigator

  call minpac#add('tpope/vim-commentary') " Commenting Operator gcc{motion}
  call minpac#add('ervandew/supertab') " Completion with tab in insert
  call minpac#add('machakann/vim-highlightedyank') " Highlight yanked text
  call minpac#add('machakann/vim-highlightedundo') " Highlight the undo
      call minpac#add('markonm/traces.vim') " Preview Ex commands like substite

  " call minpac#add('rizzatti/dash.vim') " Dash integration
  " call minpac#add('scrooloose/syntastic') " Syntax Highlighter
  call minpac#add('tpope/vim-sleuth') " Adjusts spacing and tabs 
  call minpac#add('tpope/vim-surround') " Swap surrounding with ease
  call minpac#add('tpope/vim-repeat') " Make . even stronger
  call minpac#add('tpope/vim-eunuch') " :Rename, :Delete, and more
  " call minpac#add('metakirby5/codi.vim') " Codi - interactive code scratchpads!
  " call minpac#add('tpope/vim-fugitive') " Git management!
  call minpac#add('chiel92/vim-autoformat') " Autoformat for Vim
  " call minpac#add('dracula/vim') " Dracula for Vim
  call minpac#add('rakr/vim-one') " OneDark Vim
  " call minpac#add('kannokanno/previm') " Markdown Preview from Vi
  call minpac#add('adelarsq/vim-matchit') " Matchit 
  call minpac#add('frazrepo/vim-rainbow') " Vim Rainbow
  call minpac#add('tyru/open-browser.vim') " Open Default Browser
  " call minpac#add('bling/vim-airline') " Vim Airline (Status Bar)
  " call minpac#add('vim-airline/vim-airline-themes') " Vim Airline Themes (for Dracula)
  call minpac#add('itchyny/lightline.vim') " Vim Lightline

endfunction

command! PacUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PacClean  source $MYVIMRC | call PackInit() | call minpac#clean()
command! PacStatus packadd minpac | call minpac#status()

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
" packadd vim-jetpack
" 
" call jetpack#begin()
" Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap
" 
" " Commenting Operator gcc{motion
" Jetpack 'tpope/vim-commentary'
" " , {'opt': 1}
" 
" Jetpack 'https://github.com/dense-analysis/ale'
" 
" Jetpack 'ctrlpvim/ctrlp.vim'
" " Jetpack 'junegunn/fzf.vim'
" " Jetpack 'junegunn/fzf', { 'do': {-> fzf#install()} }
" 
" " Jetpack 'neoclide/coc.nvim', { 'branch': 'release' }
" " Jetpack 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }
" 
" " Jetpack 'vlime/vlime', { 'rtp': 'vim' }
" 
" " Jetpack 'dracula/vim', { 'as': 'dracula' }
" " Jetpack 'dracula/vim', { 'as': 'dracula' }
" 
" " Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }
" " Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }
" 
" " Sensible Defaults
" Jetpack 'tpope/vim-sensible'
" 
" " Language Support
" Jetpack 'sheerun/vim-polyglot'
" 
" " Copilot
" " Jetpack 'github/copilot.vim'
" 
" " Vim tree navigation
" " Plug 'scrooloose/nerdtree'
" 
" " " Vim split navigation
" Jetpack 'tpope/vim-vinegar'
" 
" " Vim Tiling Window Manager
" Jetpack 'spolu/dwm.vim'
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
" 
" " Current Context Commentstring
" " Jetpack 'suy/vim-context-commentstring'
" 
" " Dash integration
" Jetpack 'rizzatti/dash.vim'
" 
" " Syntax Highlighter
" Jetpack 'dense-analysis/ale'
" 
" " Tab magic?
" Jetpack 'tpope/vim-sleuth'
" 
" " Codi - interactive code scratchpads!
" Jetpack 'metakirby5/codi.vim'
" 
" " Git management!
" Jetpack 'tpope/vim-fugitive'
" 
" " Autoformat for Vim
" Jetpack 'chiel92/vim-autoformat'
" 
" " Dracula for Vim
" " Plug 'dracula/vim'
" 
" " OneDark Vim
" Jetpack 'rakr/vim-one'
" 
" " Markdown Preview from Vi
" " Plug 'kannokanno/previm'
" 
" " Matchit 
" Jetpack 'adelarsq/vim-matchit'
" 
" " Vim Rainbow
" Jetpack 'frazrepo/vim-rainbow'
" 
" " Open Default Browser
" Jetpack 'tyru/open-browser.vim'
" 
" " Vim Airline (Status Bar)
" Jetpack 'bling/vim-airline'
" 
" " Vim Airline Themes (for Dracula)
" " Plug 'vim-airline/vim-airline-themes'
" 
" " Vim Lightline
" " Jetpack 'itchyny/lightline.vim'
" 
" call jetpack#end()
" 
" " Vim-Jetpack Autoinstall
" for name in jetpack#names()
"     if !jetpack#tap(name)
"           call jetpack#sync()
"           break
"     endif
" endfor
" 
" " Vim-Plug Setup
" " if empty(glob('~/.vim/autoload/plug.vim'))
" "   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
" "     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" "   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" " endif
" " 
" " " Vim Plugin Directory
" " call plug#begin('~/.vim/plugged')
" " 
" " " Sensible Defaults
" " Plug 'tpope/vim-sensible'
" " 
" " " Language Support
" " Plug 'sheerun/vim-polyglot'
" "  
" " " " Copilot
" " " " Plug 'github/copilot.vim'
" " " 
" " " " Vim tree navigation
" " " " Plug 'scrooloose/nerdtree'
" " " 
" " " Vim split navigation
" " Plug 'tpope/vim-vinegar'
" "  
" " " " Vim Tiling Window Manager
" " " Plug 'spolu/dwm.vim'
" " " 
" " " " Golden Ratio
" " " " Plug 'roman/golden-ratio'
" " " 
" " " " Vim Fuzzy Find
" " " " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" " " " Plug 'junegunn/fzf.vim'
" " " 
" " " " Tmux Navigator
" " " " Plug 'christoomey/vim-tmux-navigator'
" " " 
" " " Commenting Operator gcc{motion}
" " Plug 'tpope/vim-commentary'
" " " 
" " " " Dash integration
" " " Plug 'rizzatti/dash.vim'
" " " 
" " " Syntax Highlighter
" " Plug 'scrooloose/syntastic'
" " " 
" " " Tab magic?
" " Plug 'tpope/vim-sleuth'
" " " 
" " " " Codi - interactive code scratchpads!
" " " " Plug 'metakirby5/codi.vim'
" " " 
" " " " Git management!
" " " Plug 'tpope/vim-fugitive'
" " " 
" " " Autoformat for Vim
" " Plug 'chiel92/vim-autoformat'
" " " 
" " " " Dracula for Vim
" " " " Plug 'dracula/vim'
" " " 
" " " OneDark Vim
" " Plug 'rakr/vim-one'
" " " 
" " " " Markdown Preview from Vi
" " " " Plug 'kannokanno/previm'
" " " 
" " " Matchit 
" " Plug 'adelarsq/vim-matchit'
" "  
" " " Vim Rainbow
" " Plug 'frazrepo/vim-rainbow'
" " " 
" " " Open Default Browser
" " Plug 'tyru/open-browser.vim'
" " " 
" " " Vim Airline (Status Bar)
" " Plug 'bling/vim-airline'
" " " 
" " " " Vim Airline Themes (for Dracula)
" " " " Plug 'vim-airline/vim-airline-themes'
" " " 
" " " " Vim Lightline
" " " Plug 'itchyny/lightline.vim'
" " 
" " " Initialize/Install Plugin System
" " call plug#end()

" Statusline -----

" Show Status
set laststatus=2

" Lightline
let g:lightline = {
        \ 'component_function': {
        \   'fileformat': 'LightlineFileformat',
        \   'filetype': 'LightlineFiletype',
        \   'colorscheme': 'one' 
        \ },
        \ }

function! LightlineFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
    return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

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

" Minpac
" autocmd VimEnter * PacUpdate 

" VimPlug
" 
" " -----------------------------
" " Autoload
" " -----------------------------
" 
" " VimPlug
" autocmd VimEnter *
"   \  if len(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
"   \|   PlugInstall --sync | q
"   \| endif

" vim-commentary
autocmd FileType apache setlocal commentstring=#\ %s
" autocmd FileType vim,vimscript setlocal commentstring=\"%s
" autocmd FileType xml,html setlocal commentstring=<!--%s--> # here %s is the content wrapped by comment strings
" autocmd FileType sh,python,text setlocal commentstring=#%s

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
noremap <silent> <C-S>          :update!<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>


" Ctrl+Q to Save
noremap <silent> <C-Q>          :exit<CR>
vnoremap <silent> <C-Q>         <C-C>:exit<CR>
inoremap <silent> <C-Q>         <C-O>:exit<CR>

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

" Fix for Vim on WSL
" https://stackoverflow.com/questions/51388353/vim-changes-into-replace-mode-on-startup
nnoremap <esc>^[ <esc>^[

" -----------------------------
" Commands
" -----------------------------

" W for sudo :w
" NOTE https://www.cyberciti.biz/faq/vim-vi-text-editor-save-file-without-root-permission/
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

" -----------------------------
" Defaults
" -----------------------------

" No Jetpack Tricks
" let g:pack#optimization=0

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
filetype on
filetype plugin indent on
syntax on

" Clipboard
set clipboard=unnamed,unnamedplus
set mouse=a

"" wsl
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif

" Set background
" set background=dark

" Set default indent to 4 spaces
set shiftwidth=4 softtabstop=4 expandtab

" Set Dracula color scheme
" color dracula
" let g:airline_theme='dracula'

" Vim Onedark
let g:airline_theme='one'
" let g:airline_theme='one'
" let g:lightline = { 'colorscheme': 'one' }
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
" let g:airline#extensions#tabline#enabled = 1

" Show just the filename
" let g:airline#extensions#tabline#fnamemod = ':t'
