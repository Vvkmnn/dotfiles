" Packages 

" Functions --------------------------------------------------------------------
function! packages#setup() abort
    echom "[._.] Setting up packages..."
    
    " Load the optional package; or just leave it available
    packadd minpac

    " Initialize
    call minpac#init() 

    " nvim {{{
     call minpac#add('tpope/vim-sensible', {'type': 'start'})      " sensible.vim -- Sensible Defaults
     call minpac#add('sheerun/vim-polyglot', {'type': 'start'})    " vim-polyglot -- language packs for Vim
     call minpac#add('tpope/vim-repeat', {'type': 'start'})    " repeat.vim -- Dot commands on steroids
     call minpac#add('tpope/vim-unimpaired', {'type': 'start'})    " unimpaired.vim -- Handy [] maps <]q / :cnext, [q / :cprevious, ]a / :next. [b / :bprevious, etc.>
     call minpac#add('tpope/vim-commentary', {'type': 'start'})  " commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc>
     call minpac#add('tpope/vim-surround', {'type': 'start' })  " surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
     call minpac#add('junegunn/fzf.vim', {'type': 'start' }) " FZF -- Fuzzy File Finder!
     call minpac#add('justinmk/vim-dirvish', {'type': 'start' }) " vim-dirvish -- netrw upgrade!
     call minpac#add('tpope/vim-eunuch', {'type': 'opt'})                       " Vim Eunech -- Unix helpers via <:Delete>, <:Move>, ..
     call minpac#add('gioele/vim-autoswap', {'type': 'start' }) " vim-autoswap -- No swap messages; just switch or recover
     call minpac#add('sbdchd/neoformat', {'type': 'start' })  " vim-neoformat -- Script formatting
     call minpac#add('dracula/vim', {'type': 'start'})  " Dracula -- A dark colorscheme
 
     call minpac#add('k-takata/minpac', {'type': 'opt'}) " Minpac -- A minimal package manager
     call minpac#add('SirVer/ultisnips', {'type': 'opt'})                       " ultisnips -- Vim Snippet Framework
     call minpac#add('honza/vim-snippets', {'type': 'opt'})                     " vim-snippets -- snipMate & UltiSnip Snippets
     call minpac#add('w0rp/ale', {'type': 'opt'})                               " Ale -- Asynchrous Linting Engine
     call minpac#add('Shougo/deoplete.nvim', {'type' : 'opt'})                 " Deoplete -- dark powered neo-completion
     call minpac#add('sbdchd/neoformat', {'type' : 'opt'})                       " vim-neoformat -- Script formatting
     call minpac#add('SirVer/ultisnips', {'type' : 'opt'})                       " ultisnips -- Vim Snippet Framework
     call minpac#add('honza/vim-snippets', {'type' : 'opt'})                     " vim-snippets -- snipMate & UltiSnip Snippets
     call minpac#add('w0rp/ale', {'type' : 'opt'})                               " Ale -- Asynchrous Linting Engine
     call minpac#add('ludovicchabant/vim-gutentags', {'type' : 'opt'})           " Gutentags -- The Vim .tags manager
     call minpac#add('luochen1990/rainbow', {'type' : 'start'})                    " Rainbow Parentheses Improved -- Color code by depth
     call minpac#add('kassio/neoterm', {'type' : 'opt'})                         " neoterm -- one terminal for everything!
     " }}}
 
     " }}}
     
     " git {{{
     call minpac#add('airblade/vim-gitgutter', {'type': 'start' }) " vim-gitgutter -- Git status next to line numbers
     call minpac#add('tpope/vim-fugitive', {'type' : 'opt'})                     " Fugitive -- Git management for Vim
     " }}}
 
 
     " Development {{{
     " call dein#add('Shougo/echodoc.vim')                   " echodoc.vim -- Displays docs in the function area
     " call dein#add('ervandew/supertab')                    " Supertab -- Use <Tab> for all your insert completion needs
     " call dein#add('neomake/neomake')                        " Neomake -- Asynchronously run programs
     " call dein#add('svermeulen/vim-easyclip')              " vim-easyclip -- Better thought out yanking, cutting, and pasting.
     " call dein#add('neomake/neomake')                      " Neomake -- Asynchronously run Programs <:Neomake>
     " call minpac#add('zirrostig/vim-schlepp', {'type' : 'opt'})                  " vim-schlepp -- Allow the movement of lines (or blocks) of text around easily
     " call dein#add('hkupty/iron.nvim')                     " iron.vim -- Interactive Repls Over Neovim
     " call dein#add('majutsushi/tagbar')                    " Tagbar -- a class outline viewer for Vim
     " call dein#add('ryanoasis/vim-devicons')               " VimDevIcons -- Icons in Vim
     " call dein#add('christoomey/vim-tmux-navigator')       " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
     " call dein#add('hkupty/nvimux')                        " NVIMUX -- mimic tmux on neovim
     " call dein#add('wesQ3/vim-windowswap')                 " WindowSwap.vim -- Swap any windows with <leader>ww
     "
     " call minpac#add('rizzatti/dash.vim', {'type': 'opt'})   " Dash -- Dash Support <Dash:>
     " }}}
 
     " Markdown {{{
     call minpac#add('reedes/vim-lexical', {'type': 'opt'})      " vim-lexical -- Vim Spellcheck++
     "
     " call dein#add('autozimu/LanguageClient-neovim')       " LanguageClient-neovim -- Language Server Protocol support for neovim.
     " }}}
          " }}}
  
          " Visual Plugins {{{
 "         " }}}
 " 
 "         " Navigation Plugins {{{
          " call dein#add('mhinz/vim-startify')                   " vim-startify -- Vim start page!
          " call dein#add('matze/vim-move')                       " vim-move -- Alt-kj for moving lines up and down
          " call dein#add('scrooloose/nerdtree')                  " NERDTree -- Tree File System Explorer
 "         " }}}
 " 
 "         " Development Plugins {{{
 "         " }}}
 
     " Update
    call minpac#update()

    " Clean
    " call minpac#clean()
    "
    "
let g:rainbow_active = 1
endfunction

function! packages#check() abort
    echom "[._.] Checking packages..."
    
    " Load the optional package; or just leave it available
    packadd minpac

    " Update
    call minpac#update()

    " Clean
    " call minpac#clean()
endfunction

" 
"         " GUI Plugins {{{
"         "if has('gui_running')
"         "endif
"         " }}}
" 
"         " Save
"         call dein#end()
"         call dein#save_state()
"     endif
" endfunction

" Bindings ---------------------------------------------------------------------

" Commands ---------------------------------------------------------------------
" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
