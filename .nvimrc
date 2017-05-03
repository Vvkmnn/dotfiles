" Vivek Menon - vkmn.xyz

" Plugins
" -------

" Vundle
set nocompatible                               " be iMproved, required
filetype off                                   " required

" Set the runtime path for  Vundle set the runtime path to Vundle 
set rtp+=~/.vim/bundle/Vundle.vim                

call vundle#begin() 														 
" Alternatively, to use another path for Vundle should install plugins call 
" vundle#begin('~/some/path/here')

Plugin 'jpalardy/vim-slime'                    " Vime Slime: terminal eulator
Plugin 'dracula/vim'                           " Dracula:  colorscheme
Plugin 'VundleVim/Vundle.vim'                  " Vundle: Vundle must manage Vundle itself
"Plugin 'scrooloose/syntastic'									 " Syntastic: Syntax checker 
Plugin 'vim-airline/vim-airline'							 " Airline: Statusbar for Vim
Plugin 'paranoida/vim-airlineish'				       " Airline Theme: Dark statusbar
Plugin 'scrooloose/nerdtree'                   " Nerdtree: Directory walking in Vim
Plugin 'ervandew/screen'                       " Screen: Generate screens in Vim
Plugin 'airblade/vim-gitgutter'                " GitGutter: Gitt Diff in Vim
Plugin 'junegunn/goyo.vim'                     " Goyo: Distraction free Vim

" The following are examples of  different formats supported:
Plugin 'tpope/vim-fugitive'                    " plugin on Github repo
Plugin 'L9'                                    " plugin from vim-scripts.org
Plugin 'git://git.wincent.com/command-t.git'   " Git plugin not on Github
"Plugin 'file:///home/gmarik/path/to/plugin'	 " Local git repos
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}		 " The sparkup vim script is
																							 " in a subdirectory of this 
																							 " repo called vim.
																							 " Pass the path to set the 
																							 " runtimepath properl 
"Plugin 'ascenator/L9', {'name': 'newL9'}			 " Install L9 and avoid a 
																							 " Naming conflict if you' ve 
																							 " already installed different 
																							 " version somewhere else.


" Keep Plugin commands between vundle#begin/end
" All of your Plugins must be added before the following line

call vundle#end()                              " required
filetype plugin indent on                      " required
 " To ignore plugin indent changes, instead use:
"filetype plugin on


"
" Help
" -------

"
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" Make Vim more useful
"
" Settings
" -------
"
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif
set backupskip=/tmp/*,/private/tmp/*
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Make tabs as wide as two spaces
set tabstop=2
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
if exists("&relativenumber")
    set relativenumber
    au BufReadPost * set relativenumber
endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3
" Strip trailing whitespace (,ss)
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Plugin Settings
" -------

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Keystrokes
" -------
" REPL for Vim - https://coderwall.com/p/k-in2g/vim-slime-iterm2#comment_27790
" Set up an equivalent for VimR

" Commands
" -------

"
" Automatic commands
if has("autocmd")
    " Enable file type detection
    filetype on
    " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
    " Treat .md files as Markdown
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
    " Treat .py files as Python
    autocmd BufNewFile,BufRead *.md setlocal filetype=python
		" Treat .r files as R
    autocmd BufNewFile,BufRead *.md setlocal filetype=r
endif


" Themes
" -------

set background=dark														 " Dark background
color dracula					 												 " Dracula color scheme
:let g:airline_theme='dracula'				 				 " Dracula color airline theme