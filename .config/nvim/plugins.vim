" Plugins ------------------------------------------

" Required
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('~/.dein')
    call dein#begin('~/.dein')

    " Package Plugins {{{
    call dein#add('Shougo/dein.vim')                        " Dein -- A Dark  Package Manager
    "}}}

    " Editing Plugins {{{
    call dein#add('tpope/vim-sensible')                     " sensible.vim -- Sensible Defaults
    call dein#add('tpope/vim-repeat')                       " repeat.vim -- Dot commands on steroids
    call dein#add('tpope/vim-repeat')                       " unimpaired.vim -- Handy [] maps <]q / :cnext, [q / :cprevious, ]a / :next. [b / :bprevious, etc.>
    call dein#add('sheerun/vim-polyglot')                   " vim-polyglot -- language packs for Vim
    call dein#add('rizzatti/dash.vim')                      " Dash -- Dash Support <Dash:>
    call dein#add('reedes/vim-lexical')                     " vim-lexical -- Vim Spellcheck++
    " call dein#add('autozimu/LanguageClient-neovim')       " LanguageClient-neovim -- Language Server Protocol support for neovim.
    " }}}

    " Visual Plugins {{{
    call dein#add('vim-airline/vim-airline')                " vim-airline -- A lean & mean vim statusline
    call dein#add('dracula/vim')                            " Dracula -- A Dark Colorscheme
    " call dein#add('majutsushi/tagbar')                    " Tagbar -- a class outline viewer for Vim
    " call dein#add('ryanoasis/vim-devicons')               " VimDevIcons -- Icons in Vim
    call dein#add('airblade/vim-gitgutter')                 " vim-gitgutter -- Git status next to line numbers
    " call dein#add('christoomey/vim-tmux-navigator')       " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
    " call dein#add('hkupty/nvimux')                        " NVIMUX -- mimic tmux on neovim
    " call dein#add('wesQ3/vim-windowswap')                 " WindowSwap.vim -- Swap any windows with <leader>ww
    " }}}

    " Navigation Plugins {{{
    " call dein#add('mhinz/vim-startify')                   " vim-startify -- Vim start page!
    call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' }) " FZF -- Fuzzy File Finder!
    call dein#add('justinmk/vim-dirvish')                   " Vim Dirvish -- Inline Vim File Navigation
    call dein#add('tpope/vim-eunuch')                       " Vim Eunech -- Unix helpers via <:Delete>, <:Move>, ..
    call dein#add('gioele/vim-autoswap')                    " vim-autoswap -- No swap messages; just switch or recover
    " call dein#add('matze/vim-move')                       " vim-move -- Alt-kj for moving lines up and down
    " call dein#add('scrooloose/nerdtree')                  " NERDTree -- Tree File System Explorer
    " }}}

    " Development Plugins {{{
    " call dein#add('Shougo/deoplete.nvim')                 " Deoplete -- dark powered neo-completion
    call dein#add('sbdchd/neoformat')                       " vim-neoformat -- Script formatting
    call dein#add('SirVer/ultisnips')                       " ultisnips -- Vim Snippet Framework
    call dein#add('honza/vim-snippets')                     " vim-snippets -- snipMate & UltiSnip Snippets
    call dein#add('w0rp/ale')                               " Ale -- Asynchrous Linting Engine
    " call dein#add('Shougo/echodoc.vim')                   " echodoc.vim -- Displays docs in the function area
    call dein#add('ervandew/supertab')                      " Supertab -- Use <Tab> for all your insert completion needs
    call dein#add('ludovicchabant/vim-gutentags')           " Gutentags -- The Vim .tags manager
    " call dein#add('neomake/neomake')                        " Neomake -- Asynchronously run programs
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
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
    call dein#install()
endif

