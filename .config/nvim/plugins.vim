" Plugins ------------------------------------------

" Required
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('~/.dein')
    call dein#begin('~/.dein')

    " Package Plugins {{{
    " Dein -- A Dark  Package Manager
    call dein#add('Shougo/dein.vim')
    "}}}

    " Editing Plugins {{{
    " vim-polyglot -- language packs for Vim
    call dein#add('sheerun/vim-polyglot')

    " vim-neoformat -- Script formatting
    call dein#add('sbdchd/neoformat')

    " Dash -- Dash Support <Dash:>
    call dein#add('rizzatti/dash.vim')

    " ultisnips -- Vim Snippet Framework
    call dein#add('SirVer/ultisnips')

    " vim-snippets -- snipMate & UltiSnip Snippets
    call dein#add('honza/vim-snippets')

    " Ale -- Asynchrous Linting Engine
    call dein#add('w0rp/ale')

    " echodoc.vim -- Displays docs in the function area
    " call dein#add('Shougo/echodoc.vim')

    " Supertab -- Use <Tab> for all your insert completion needs
    " call dein#add('ervandew/supertab')

    " Gutentags -- The Vim .tags manager
    call dein#add('ludovicchabant/vim-gutentags')

    " Tagbar -- a class outline viewer for Vim
    " call dein#add('majutsushi/tagbar')

    " Deoplete -- dark powered neo-completion
    " call dein#add('Shougo/deoplete.nvim')

    " LanguageClient-neovim -- Language Server Protocol support for neovim.
    " call dein#add('autozimu/LanguageClient-neovim')

    " vim-lexical -- Vim Spellcheck++
    call dein#add('reedes/vim-lexical')
    " }}}

    " Visual Plugins {{{
    " Dracula -- A Dark Colorscheme
    call dein#add('dracula/vim')

    " VimDevIcons -- Icons in Vim
    " call dein#add('ryanoasis/vim-devicons')

    " vim-gitgutter -- Git status next to line numbers
    call dein#add('airblade/vim-gitgutter')

    " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
    " call dein#add('christoomey/vim-tmux-navigator')

    " NVIMUX -- mimic tmux on neovim
    " call dein#add('hkupty/nvimux')

    " WindowSwap.vim -- Swap any windows with <leader>ww
    " call dein#add('wesQ3/vim-windowswap')

    " vim-airline -- A lean & mean vim statusline
    call dein#add('vim-airline/vim-airline')
    " }}}

    " Navigation Plugins {{{
    " vim-startify -- Vim start page!
    " call dein#add('mhinz/vim-startify')

    " FZF -- Fuzzy File Finder!
    call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

    " Vim Dirvish -- Inline Vim File Navigation
    call dein#add('justinmk/vim-dirvish')

    " Vim Eunech -- Unix helpers via <:Delete>, <:Move>, ..
    call dein#add('tpope/vim-eunuch')

    " vim-autoswap -- No swap messages; just switch or recover
    call dein#add('gioele/vim-autoswap')

    " vim-move -- Alt-kj for moving lines up and down
    " call dein#add('matze/vim-move')

    " NERDTree -- Tree File System Explorer
    " call dein#add('scrooloose/nerdtree')
    " }}}

    " Development Plugins {{{
    " sensible.vim -- Sensible Defaults
    call dein#add('tpope/vim-sensible')

    " repeat.vim -- Dot commands on steroids
    call dein#add('tpope/vim-repeat')

    " unimpaired.vim -- Handy [] maps <]q / :cnext, [q / :cprevious, ]a / :next. [b / :bprevious, etc.>
    call dein#add('tpope/vim-repeat')

    " commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc>
    call dein#add('tpope/vim-commentary')

    " surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
    call dein#add('tpope/vim-surround')

    " vim-easyclip -- Better thought out yanking, cutting, and pasting.
    " call dein#add('svermeulen/vim-easyclip')

    " Fugitive -- Git management for Vim
    call dein#add('tpope/vim-fugitive')

    " Neomake -- Asynchronously run Programs <:Neomake>
    " call dein#add('neomake/neomake')

    " vim-schlepp -- Allow the movement of lines (or blocks) of text around easily
    call dein#add('zirrostig/vim-schlepp')

    " Rainbow Parentheses Improved -- Color code by depth
    call dein#add('luochen1990/rainbow')

    " neoterm -- one terminal for everything!
    call dein#add('kassio/neoterm')

    " iron.vim -- Interactive Repls Over Neovim
    " call dein#add('hkupty/iron.nvim')
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

