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

        " dracula/vim -- A Dark Colorscheme {{{
        call dein#add('dracula/vim')
        " }}}

        " tpope/sensible.vim -- Sensible Defaults {{{
        call dein#add('tpope/vim-sensible')
        " }}}

        " tpope/repeat.vim -- Dot commands on steroids {{{
        call dein#add('tpope/vim-repeat')
        " }}}

        " sheerun/vim-polyglot -- language packs for Vim {{{
        call dein#add('sheerun/vim-polyglot')
        " }}}

        " tpope/commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc> {{{
        call dein#add('tpope/vim-commentary')
        " }}}

        " tpope/unimpaired.vim -- Handy [] maps <]q> / <:cnext>, <[b> / <:bprevious>, etc.> {{{
        call dein#add('tpope/vim-unimpaired')
        " }}}

        " vim-airline/vim-airline -- A lean & mean vim statusline {{{
        call dein#add('vim-airline/vim-airline')
        call dein#add('vim-airline/vim-airline-themes')
        let g:airline#extensions#tabline#enabled = 1 " Automatically displays all buffers when there's only one tab open.
        let g:airline#extensions#tabline#formatter = 'unique_tail_improved' " More informative titles
        " }}}

        " airblade/vim-gitgutter -- Git status next to line numbers {{{
        call dein#add('airblade/vim-gitgutter')
        " }}}

        " junegunn/vim-easy-align -- Vim Alignment with <ga:> {{{
        call dein#add('junegunn/vim-easy-align')
        " }}}

        " giole/vim-autoswap -- No swap messages; just switch or recover {{{
        call dein#add('gioele/vim-autoswap')
        " }}}

        " autozimu/LanguageClient-neovim - LSP Integration for Vim {{{
        call dein#add('autozimu/LanguageClient-neovim', {
                    \ 'rev': 'next',
                    \ 'build': 'bash install.sh',
                    \ }) " Language Server Protocol support

        let g:LanguageClient_serverCommands = {
                    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
                    \ 'javascript': ['javascript-typescript-stdio'],
                    \ 'typescript': ['tsserver'],
                    \ } " Language Server Protocol paths
        " }}}

        " Dash -- Dash Support <Dash:> {{{
        call dein#add('rizzatti/dash.vim')
        " }}}

        " vim-lexical -- Vim Spellcheck++ {{{
        call dein#add('reedes/vim-lexical')
        " }}}

        " Vim Dirvish -- Inline Vim File Navigation
        " call dein#add('justinmk/vim-dirvish')
        " }}}

        " surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
        call dein#add('tpope/vim-surround')
        " }}}

        " tpope/vim-eunech -- Unix helpers via <:Delete>, <:Move>, ... {{{
        call dein#add('tpope/vim-eunuch')
        " }}}

        " Vimagit -- Emacs style Git management via <:Magit>, <C-n>, S[tage], and CC[omit] {{{
        call dein#add('jreybert/vimagit')
        " }}}

        " Rainbow Parentheses Improved -- Color code by depth
        call dein#add('luochen1990/rainbow')
        let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
        " }}}

        " Shougo/deoplete -- dark powered neo-completion {{{
        call dein#add('Shougo/deoplete.nvim')
        let g:deoplete#enable_at_startup = 1 " Enable deoplete at startup
        " }}}

        " Shougo/denite.vim -- Emacs Helm for Vim {{{
        call dein#add('Shougo/denite.nvim')
        " }}}

        " w0rp/ale -- Asynchrous Linting Engine {{{
        call dein#add('w0rp/ale')
        let g:ale_fix_on_save = 1 " Set this setting in vimrc if you want to fix files automatically on save.
        let g:ale_completion_enabled = 1 " Enable completion where available.
        " }}}

        " Neomake -- Asynchronously run programs {{{
        " call dein#add('neomake/neomake')
        " }}}

        " aperezdc/vim-template -- Prebuilt templates for certain filetypes via <:Template>, or <$ vim foo.x>
        call dein#add('aperezdc/vim-template')
        " }}}

        " vim-easyclip -- Better thought out yanking, cutting, and pasting.
        " call dein#add('svermeulen/vim-easyclip')
        " }}}

        " sbdchd/vim-neoformat -- Script formatting
        call dein#add('sbdchd/neoformat')
        let g:neoformat_only_msg_on_error = 1
        let g:neoformat_basic_format_align = 1 " Enable alignment without FileType
        let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion FileType
        let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace FileType
        " }}}

        " SirVer/ultisnips -- Vim Snippet Framework {{{
        call dein#add('SirVer/ultisnips')
        " }}}

        " honza/vim-snippets -- snipMate & UltiSnip Snippet Source {{{
        call dein#add('honza/vim-snippets')
        " }}}

        " echodoc.vim -- Displays docs in the function area
        " call dein#add('Shougo/echodoc.vim')
        " }}}

        " Gutentags -- The Vim .tags manager  " Supertab -- Use <Tab> for all your insert completion needs
        " call dein#add('ludovicchabant/vim-gutentags')
        " }}}

        " Neomake -- Asynchronously run Programs <:Neomake>
        " call dein#add('neomake/neomake')
        " }}}


        " vim-schlepp -- Allow the movement of lines (or blocks) of text around easily
        " call dein#add('zirrostig/vim-schlepp')
        " }}}


        " neoterm -- one terminal for everything!
        " call dein#add('kassio/neoterm')
        " }}}

        " iron.vim -- Interactive Repls Over Neovim {{{
        " call dein#add('hkupty/iron.nvim')
        " }}}

        " Shougo/dein -- A Dark  Package Manager {{{
        call dein#add('~/.config/nvim/autoload/dein.vim')
        call dein#end() " End Package Adds
        call dein#save_state() " Save Dein State
        "}}}


        " TODO: Tbd. {{{
        " call dein#add('ervandew/supertab')
        " call dein#add('majutsushi/tagbar')                    " Tagbar -- a class outline viewer for Vim
        " call dein#add('ryanoasis/vim-devicons')               " VimDevIcons -- Icons in Vim
        " call dein#add('mhinz/vim-startify')                   " vim-startify -- Vim start page!
        " call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' }) " FZF -- Fuzzy File Finder!
        " call dein#add('matze/vim-move')                       " vim-move -- Alt-kj for moving lines up and down
        " call dein#add('scrooloose/nerdtree')                  " NERDTree -- Tree File System Explorer
        " vimlab/split-term.vim -- Utilities for nvim's <:terminal> {{{
        " call dein#add('mklabs/split-term.vim')
        " call dein#add('Shougo/deol.nvim')
        " }}}
    endif
endfunction

function! packages#update() abort
    echom "[._.] Updating packages..."
    call dein#load_state('~/.config/nvim/dein')
    call dein#update()
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

" Bindings ---------------------------------------------------------------------

" Commands ---------------------------------------------------------------------
" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
" command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
" command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
