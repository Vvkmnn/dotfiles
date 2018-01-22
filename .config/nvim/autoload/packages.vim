" Packages 

" Functions --------------------------------------------------------------------
function! packages#setup() abort
    echom "[._.] Setting up packages..."
    
    " import Dein if in pack/*/opt
    " Moved to pack/*/start
    " packadd dein
    
    " Start
    if dein#load_state('~/.config/nvim/dein')
        call dein#begin('~/.config/nvim/dein')

        " Package Plugins {{{
        call dein#add('Shougo/dein.vim')                        " Dein -- A Dark  Package Manager
        "}}}

        " nvim {{{
        call dein#add('tpope/vim-sensible')                     " sensible.vim -- Sensible Defaults
        call dein#add('tpope/vim-repeat')                       " repeat.vim -- Dot commands on steroids
        call dein#add('sheerun/vim-polyglot')                   " vim-polyglot -- language packs for Vim
        call dein#add('tpope/vim-unimpaired')                   " unimpaired.vim -- Handy [] maps <]q / :cnext, [q / :cprevious, ]a / :next. [b / :bprevious, etc.>
        " call dein#add('vim-airline/vim-airline')                " vim-airline -- A lean & mean vim statusline
        call dein#add('dracula/vim')                            " Dracula -- A Dark Colorscheme
        " call dein#add('majutsushi/tagbar')                    " Tagbar -- a class outline viewer for Vim
        " call dein#add('ryanoasis/vim-devicons')               " VimDevIcons -- Icons in Vim
        call dein#add('airblade/vim-gitgutter')                 " vim-gitgutter -- Git status next to line numbers
        " call dein#add('christoomey/vim-tmux-navigator')       " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
        " call dein#add('hkupty/nvimux')                        " NVIMUX -- mimic tmux on neovim
        " call dein#add('wesQ3/vim-windowswap')                 " WindowSwap.vim -- Swap any windows with <leader>ww
        " call dein#add('junegunn/vim-easy-align')                " vim-easy-align -- Vim Alignment with <ga:>
        " call dein#add('autozimu/LanguageClient-neovim')       " LanguageClient-neovim 

        " autozimu/LanguageClient-neovim {{{
        " Language Server Protocol support for neovim.
        call dein#add('autozimu/LanguageClient-neovim', {
            \ 'rev': 'next',
            \ 'build': 'bash install.sh',
            \ })

        let g:LanguageClient_serverCommands = {
            \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
            \ 'javascript': ['javascript-typescript-stdio'],
            \ 'typescript': ['javascript-typescript-stdio'],
            \ }
        " }}}

        " dash {{{
        " Dash -- Dash Support <Dash:>
        call dein#add('rizzatti/dash.vim')                      
        " }}}
        
        " markdown {{{
        call dein#add('reedes/vim-lexical')                     " vim-lexical -- Vim Spellcheck++
        " }}}
        " Visual Plugins {{{
        " }}}

        " Navigation Plugins {{{
        " call dein#add('mhinz/vim-startify')                   " vim-startify -- Vim start page!
        " call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' }) " FZF -- Fuzzy File Finder!
        call dein#add('justinmk/vim-dirvish')                   " Vim Dirvish -- Inline Vim File Navigation
        call dein#add('tpope/vim-eunuch')                       " Vim Eunech -- Unix helpers via <:Delete>, <:Move>, ..
        call dein#add('gioele/vim-autoswap')                    " vim-autoswap -- No swap messages; just switch or recover
        " call dein#add('matze/vim-move')                       " vim-move -- Alt-kj for moving lines up and down
        " call dein#add('scrooloose/nerdtree')                  " NERDTree -- Tree File System Explorer
        " }}}

        " Development Plugins {{{

        " Shougo/deoplete {{{
        call dein#add('Shougo/deoplete.nvim')                   " Deoplete -- dark powered neo-completion

        " Enable deoplete at startup
        let g:deoplete#enable_at_startup = 1
        " }}}
        

        call dein#add('aperezdc/vim-template')                  " vim-template -- Prebuilt templates for certain filetypes via <:Template>, or <$ vim foo.x>
        call dein#add('sbdchd/neoformat')                       " vim-neoformat -- Script formatting
        call dein#add('SirVer/ultisnips')                       " ultisnips -- Vim Snippet Framework
        call dein#add('honza/vim-snippets')                     " vim-snippets -- snipMate & UltiSnip Snippets

        " w0rp/ale {{{
        call dein#add('w0rp/ale')                               " Ale -- Asynchrous Linting Engine
        
        " Set this setting in vimrc if you want to fix files automatically on save.
        let g:ale_fix_on_save = 1

        " Enable completion where available.
        let g:ale_completion_enabled = 1
        " }}}

        " call dein#add('Shougo/echodoc.vim')                   " echodoc.vim -- Displays docs in the function area
        " call dein#add('ervandew/supertab')                      " Supertab -- Use <Tab> for all your insert completion needs
        call dein#add('ludovicchabant/vim-gutentags')           " Gutentags -- The Vim .tags manager
        " call dein#add('neomake/neomake')                      " Neomake -- Asynchronously run programs
        call dein#add('tpope/vim-commentary')                   " commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc>
        call dein#add('tpope/vim-surround')                     " surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
        " call dein#add('svermeulen/vim-easyclip')              " vim-easyclip -- Better thought out yanking, cutting, and pasting.
        call dein#add('tpope/vim-fugitive')                     " Fugitive -- Git management for Vim
        " call dein#add('neomake/neomake')                      " Neomake -- Asynchronously run Programs <:Neomake>
        call dein#add('zirrostig/vim-schlepp')                  " vim-schlepp -- Allow the movement of lines (or blocks) of text around easily
        call dein#add('luochen1990/rainbow')                    " Rainbow Parentheses Improved -- Color code by depth
        call dein#add('kassio/neoterm')                         " neoterm -- one terminal for everything!
        " call dein#add('hkupty/iron.nvim')                     " iron.vim -- Interactive Repls Over Neovim
        " }}}

        " GUI Plugins {{{
        "if has('gui_running')
        "endif
        " }}}

        " Save
        call dein#end()
        call dein#save_state()
        call packages#check()
    endif
endfunction


function! packages#check() abort
    echom "[._.] Checking packages..."

    call dein#load_state('~/.config/nvim/dein')

    if dein#check_install()
        call dein#install()
    endif
    
endfunction

" Setings ----------------------------------------------------------------------
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle

" Bindings ---------------------------------------------------------------------

" Commands ---------------------------------------------------------------------
" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
" command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
" command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
