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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Maintainer:
""       Amir Salihefendic - @amix3k
""
"" Awesome_version:
""       Get this config, nice color schemes and lots of plugins!
""
""       Install the awesome version from:
""
""           https://github.com/amix/vimrc
""
"" Sections:
""    -> General
""    -> VIM user interface
""    -> Colors and Fonts
""    -> Files and backups
""    -> Text, tab and indent related
""    -> Visual mode related
""    -> Moving around, tabs and buffers
""    -> Status line
""    -> Editing mappings
""    -> vimgrep searching and cope displaying
""    -> Spell checking
""    -> Misc
""    -> Helper functions
""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Sets how many lines of history VIM has to remember
"set history=500
"
"" Enable filetype plugins
"filetype plugin on
"filetype indent on
"
"" Set to auto read when a file is changed from the outside
"set autoread
"au FocusGained,BufEnter * silent! checktime
"
"" With a map leader it's possible to do extra key combinations
"" like <leader>w saves the current file
"let mapleader = ","
"
"" Fast saving
"nmap <leader>w :w!<cr>
"
"" :W sudo saves the file
"" (useful for handling the permission-denied error)
"command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => VIM user interface
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Set 7 lines to the cursor - when moving vertically using j/k
"set so=7
"
"" Avoid garbled characters in Chinese language windows OS
"let $LANG='en'
"set langmenu=en
"source $VIMRUNTIME/delmenu.vim
"source $VIMRUNTIME/menu.vim
"
"" Turn on the Wild menu
"set wildmenu
"
"" Ignore compiled files
"set wildignore=*.o,*~,*.pyc
"if has("win16") || has("win32")
"    set wildignore+=.git\*,.hg\*,.svn\*
"else
"    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
"endif
"
"" Always show current position
"set ruler
"
"" Height of the command bar
"set cmdheight=1
"
"" A buffer becomes hidden when it is abandoned
"set hid
"
"" Configure backspace so it acts as it should act
"set backspace=eol,start,indent
"set whichwrap+=<,>,h,l
"
"" Ignore case when searching
"set ignorecase
"
"" When searching try to be smart about cases
"set smartcase
"
"" Highlight search results
"set hlsearch
"
"" Makes search act like search in modern browsers
"set incsearch
"
"" Don't redraw while executing macros (good performance config)
"set lazyredraw
"
"" For regular expressions turn magic on
"set magic
"
"" Show matching brackets when text indicator is over them
"set showmatch
"
"" How many tenths of a second to blink when matching brackets
"set mat=2
"
"" No annoying sound on errors
"set noerrorbells
"set novisualbell
"set t_vb=
"set tm=500
"
"" Properly disable sound on errors on MacVim
"if has("gui_macvim")
"    autocmd GUIEnter * set vb t_vb=
"endif
"
"" Add a bit extra margin to the left
"set foldcolumn=1
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Colors and Fonts
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Enable syntax highlighting
"syntax enable
"
"" Set regular expression engine automatically
"set regexpengine=0
"
"" Enable 256 colors palette in Gnome Terminal
"if $COLORTERM == 'gnome-terminal'
"    set t_Co=256
"endif
"
"try
"    colorscheme desert
"catch
"endtry
"
"set background=dark
"
"" Set extra options when running in GUI mode
"if has("gui_running")
"    set guioptions-=T
"    set guioptions-=e
"    set t_Co=256
"    set guitablabel=%M\ %t
"endif
"
"" Set utf8 as standard encoding and en_US as the standard language
"set encoding=utf8
"
"" Use Unix as the standard file type
"set ffs=unix,dos,mac
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Files, backups and undo
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Turn backup off, since most stuff is in SVN, git etc. anyway...
"set nobackup
"set nowb
"set noswapfile
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Text, tab and indent related
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Use spaces instead of tabs
"set expandtab
"
"" Be smart when using tabs ;)
"set smarttab
"
"" 1 tab == 4 spaces
"set shiftwidth=4
"set tabstop=4
"
"" Linebreak on 500 characters
"set lbr
"set tw=500
"
"set ai "Auto indent
"set si "Smart indent
"set wrap "Wrap lines
"
"
"""""""""""""""""""""""""""""""
"" => Visual mode related
"""""""""""""""""""""""""""""""
"" Visual mode pressing * or # searches for the current selection
"" Super useful! From an idea by Michael Naumann
"vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
"vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Moving around, tabs, windows and buffers
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
"map <space> /
"map <C-space> ?
"
"" Disable highlight when <leader><cr> is pressed
"map <silent> <leader><cr> :noh<cr>
"
"" Smart way to move between windows
"map <C-j> <C-W>j
"map <C-k> <C-W>k
"map <C-h> <C-W>h
"map <C-l> <C-W>l
"
"" Close the current buffer
"map <leader>bd :Bclose<cr>:tabclose<cr>gT
"
"" Close all the buffers
"map <leader>ba :bufdo bd<cr>
"
"map <leader>l :bnext<cr>
"map <leader>h :bprevious<cr>
"
"" Useful mappings for managing tabs
"map <leader>tn :tabnew<cr>
"map <leader>to :tabonly<cr>
"map <leader>tc :tabclose<cr>
"map <leader>tm :tabmove
"map <leader>t<leader> :tabnext<cr>
"
"" Let 'tl' toggle between this and the last accessed tab
"let g:lasttab = 1
"nmap <leader>tl :exe "tabn ".g:lasttab<CR>
"au TabLeave * let g:lasttab = tabpagenr()
"
"
"" Opens a new tab with the current buffer's path
"" Super useful when editing files in the same directory
"map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/
"
"" Switch CWD to the directory of the open buffer
"map <leader>cd :cd %:p:h<cr>:pwd<cr>
"
"" Specify the behavior when switching between buffers
"try
"  set switchbuf=useopen,usetab,newtab
"  set stal=2
"catch
"endtry
"
"" Return to last edit position when opening files (You want this!)
"au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"
"
"""""""""""""""""""""""""""""""
"" => Status line
"""""""""""""""""""""""""""""""
"" Always show the status line
"set laststatus=2
"
"" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Editing mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Remap VIM 0 to first non-blank character
"map 0 ^
"
"" Move a line of text using ALT+[jk] or Command+[jk] on mac
"nmap <M-j> mz:m+<cr>`z
"nmap <M-k> mz:m-2<cr>`z
"vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
"vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z
"
"if has("mac") || has("macunix")
"  nmap <D-j> <M-j>
"  nmap <D-k> <M-k>
"  vmap <D-j> <M-j>
"  vmap <D-k> <M-k>
"endif
"
"" Delete trailing white space on save, useful for some filetypes ;)
"fun! CleanExtraSpaces()
"    let save_cursor = getpos(".")
"    let old_query = getreg('/')
"    silent! %s/\s\+$//e
"    call setpos('.', save_cursor)
"    call setreg('/', old_query)
"endfun
"
"if has("autocmd")
"    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
"endif
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Spell checking
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Pressing ,ss will toggle and untoggle spell checking
"map <leader>ss :setlocal spell!<cr>
"
"" Shortcuts using <leader>
"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>s? z=
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Misc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Remove the Windows ^M - when the encodings gets messed up
"noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
"
"" Quickly open a buffer for scribble
"map <leader>q :e ~/buffer<cr>
"
"" Quickly open a markdown buffer for scribble
"map <leader>x :e ~/buffer.md<cr>
"
"" Toggle paste mode on and off
"map <leader>pp :setlocal paste!<cr>
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" => Helper functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Returns true if paste mode is enabled
"function! HasPaste()
"    if &paste
"        return 'PASTE MODE  '
"    endif
"    return ''
"endfunction
"
"" Don't close window, when deleting a buffer
"command! Bclose call <SID>BufcloseCloseIt()
"function! <SID>BufcloseCloseIt()
"    let l:currentBufNum = bufnr("%")
"    let l:alternateBufNum = bufnr("#")
"
"    if buflisted(l:alternateBufNum)
"        buffer #
"    else
"        bnext
"    endif
"
"    if bufnr("%") == l:currentBufNum
"        new
"    endif
"
"    if buflisted(l:currentBufNum)
"        execute("bdelete! ".l:currentBufNum)
"    endif
"endfunction
"
"function! CmdLine(str)
"    call feedkeys(":" . a:str)
"endfunction
"
"function! VisualSelection(direction, extra_filter) range
"    let l:saved_reg = @"
"    execute "normal! vgvy"
"
"    let l:pattern = escape(@", "\\/.*'$^~[]")
"    let l:pattern = substitute(l:pattern, "\n$", "", "")
"
"    if a:direction == 'gv'
"        call CmdLine("Ack '" . l:pattern . "' " )
"    elseif a:direction == 'replace'
"        call CmdLine("%s" . '/'. l:pattern . '/')
"    endif
"
"    let @/ = l:pattern
"    let @" = l:saved_reg
"endfunction  
