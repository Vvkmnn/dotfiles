" Packages  --------------------------------------------------------------------

" import Dein if in pack/*/opt (Automatically added via pack/*/start)
" packadd dein


" Set Path
let s:dein_dir        = expand('$HOME/.config/nvim/dein')
let s:dein_repo_dir   = expand('$HOME/.config/nvim/pack/custom/start/dein.vim')
execute 'set runtimepath^=' . s:dein_repo_dir

function packages#setup() abort
    echom "[._.] Setting up packages..."

    " Start Adding Packages
    if dein#load_state(s:dein_dir)
        call dein#begin(s:dein_dir)


        " Shougo/dein -- A Dark  Package Manager {{{
        call dein#add(s:dein_repo_dir)

        if dein#tap('dein.vim') && has('nvim')
            let g:dein#install_progress_type = 'title'
            " let g:dein#enable_notification = 1
        endif

        " Themes {{{
        call dein#add('dracula/vim') " dracula/vim -- A Dark Colorscheme

        call dein#add('andreasvc/vim-256noir') " andreasvc/vim-256noir -- Red numbers, white strings
        " }}}


        " thiagoalessio/rainbow -- Color by depth! {{{
        call dein#add('thiagoalessio/rainbow_levels.vim', {
                    \ 'merged': 0,
                    \ 'on_cmd' : 'RainbowLevelsOn',
                    \ })


        if dein#tap('rainbow_levels.vim') && has('nvim')
            " dracula
            let g:rainbow_levels = [
                        \{'ctermfg': 84,  'guifg': '#50fa7b'},
                        \{'ctermfg': 117, 'guifg': '#8be9fd'},
                        \{'ctermfg': 61,  'guifg': '#6272a4'},
                        \{'ctermfg': 212, 'guifg': '#ff79c6'},
                        \{'ctermfg': 203, 'guifg': '#ffb86c'},
                        \{'ctermfg': 228, 'guifg': '#f1fa8c'},
                        \{'ctermfg': 15,  'guifg': '#f8f8f2'},
                        \{'ctermfg': 231, 'guifg': '#525563'}]

            " 256_noir
            " let g:rainbow_levels = [
            " \{'ctermbg': 232, 'guibg': '#080808'},
            " \{'ctermbg': 233, 'guibg': '#121212'},
            " \{'ctermbg': 234, 'guibg': '#1c1c1c'},
            " \{'ctermbg': 235, 'guibg': '#262626'},
            " \{'ctermbg': 236, 'guibg': '#303030'},
            " \{'ctermbg': 237, 'guibg': '#3a3a3a'},
            " \{'ctermbg': 238, 'guibg': '#444444'},
            " \{'ctermbg': 239, 'guibg': '#4e4e4e'},
            " \{'ctermbg': 240, 'guibg': '#585858'}]
            " endif
        endif
        " }}}

        " kien/rainbow_parentheses.vim -- Better Rainbow Parenthesis
        " call dein#add('kien/rainbow_parentheses.vim')

        " if dein#tap('rainbow_parentheses.vim') && has('nvim')
        "     " let g:rbpt_loadcmd_toggle = 0
        " endif
        " }}}

        " luochen1990/rainbow -- Rainbow Parentheses Improved -- Color code by depth {{{
        " call dein#add('luochen1990/rainbow')

        " if dein#tap('rainbow.vim') && has('nvim')
        "     " let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
        " endif
        " }}}

        "itchyny/lightline.vim -- A leaner vim statusline {{{
        call dein#add('itchyny/lightline.vim')

        if dein#tap('lightline.vim') && has('nvim')
            let g:lightline = {
                        \ 'colorscheme': 'Dracula'}
        endif
        " }}}


        " maximbaz/lightline-ale -- Ale Component for lightline {{{
        call dein#add('maximbaz/lightline-ale')

        if dein#tap('lightline.vim') && dein#tap('lightline-ale') && dein#tap('ale') && has('nvim')
            let g:lightline.component_expand = {
                        \  'linter_warnings': 'lightline#ale#warnings',
                        \  'linter_errors': 'lightline#ale#errors',
                        \  'linter_ok': 'lightline#ale#ok',
                        \ }
            let g:lightline.component_type = {
                        \     'linter_warnings': 'warning',
                        \     'linter_errors': 'error',
                        \     'linter_ok': 'left',
                        \ }
            let g:lightline.active = { 'right': [[ 'linter_errors', 'linter_warnings', 'linter_ok' ]] }
            let g:lightline#ale#indicator_warnings = "\uf071"
            let g:lightline#ale#indicator_errors = "\uf05e"
            let g:lightline#ale#indicator_ok = "\uf00c"
        endif
        " }}}

        " taohex/lightline-buffer -- Buffer component for lightline {{{
        call dein#add('taohex/lightline-buffer')

        if dein#tap('lightline.vim') && dein#tap('lightline-buffer') && has('nvim')
            let g:lightline.component_expand = {
                        \ 'tabline': {
                        \   'left': [ [ 'bufferinfo' ],
                        \             [ 'separator' ],
                        \             [ 'bufferbefore', 'buffercurrent', 'bufferafter' ], ],
                        \   'right': [ [ 'close' ], ],
                        \ },
                        \ 'component_expand': {
                        \   'buffercurrent': 'lightline#buffer#buffercurrent',
                        \   'bufferbefore': 'lightline#buffer#bufferbefore',
                        \   'bufferafter': 'lightline#buffer#bufferafter',
                        \ },
                        \ 'component_type': {
                        \   'buffercurrent': 'tabsel',
                        \   'bufferbefore': 'raw',
                        \   'bufferafter': 'raw',
                        \ },
                        \ 'component_function': {
                        \   'bufferinfo': 'lightline#buffer#bufferinfo',
                        \ },
                        \ 'component': {
                        \   'separator': '',
                        \ },
                        \ }
        endif
        " }}}

        " vim-airline/vim-airline -- A lean & mean vim statusline {{{
        " call dein#add('vim-airline/vim-airline')

        " if dein#tap('vim-airline/vim-airline') && has('nvim')
        "     let g:airline#extensions#tabline#enabled = 1 " Automatically displays all buffers when there's only one tab open.
        "     let g:airline#extensions#tabline#formatter = 'unique_tail_improved' " More informative titles
        " endif
        " }}}



        " tpope/sensible.vim -- Sensible Defaults {{{
        " TODO: Check if this conflicts with defaults#settings()
        call dein#add('tpope/vim-sensible')
        " }}}

        " tpope/repeat.vim -- Dot commands on steroids {{{
        call dein#add('tpope/vim-repeat')
        " }}}

        " sheerun/vim-polyglot -- language packs for Vim {{{
        call dein#add('sheerun/vim-polyglot')
        " }}}

        " tpope/vim-vinegar -- netrw upgrade {{{
        call dein#add('tpope/vim-vinegar')
        " }}}

        " tpope/surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
        call dein#add('tpope/vim-surround')
        " }}}

        " tpope/commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc> {{{
        call dein#add('tpope/vim-commentary')
        " }}}

        " tpope/unimpaired.vim -- Handy [] maps <]q> / <:cnext>, <[b> / <:bprevious>, etc.> {{{
        call dein#add('tpope/vim-unimpaired')
        " }}}

        " tpope/vim-eunech -- Unix helpers via <:Delete>, <:Move>, ... {{{
        call dein#add('tpope/vim-eunuch')
        " }}}

        " tpope/vim-fugitive -- A Vim Git Wrapper {{{
        call dein#add('tpope/vim-fugitive')
        " }}}

        " reedes/vim-lexical -- Vim Spellcheck++ {{{
        " call dein#add('reedes/vim-lexical')
        " }}}

        " ap/vim-buftabline -- Vim Buffer Tabs {{{
        " call dein#add('ap/vim-buftabline')
        " }}}

        " airblade/vim-gitgutter -- Git status next to line numbers {{{
        " call dein#add('airblade/vim-gitgutter')
        " }}}

        " roman/golden-ratio -- Golden Ratio windows {{{
        " call dein#add('roman/golden-ratio')
        " }}}

        " thaerkh/vim-workspace -- Automated Session Management with <:ToggleWorkplace> {{{
        " call dein#add('thaerkh/vim-workspace')
        " }}}

        " thaerkh/vim-workspace -- Automated Session Management with <:ToggleWorkplace> {{{
        " call dein#add('thaerkh/vim-workspace')
        " }}}

        " giole/vim-autoswap -- No swap messages; just switch or recover {{{
        " call dein#add('gioele/vim-autoswap')
        " }}}

        " autozimu/LanguageClient-neovim - LSP Integration for Vim {{{
        " call dein#add('autozimu/LanguageClient-neovim', {
        "            \ 'rev': 'next',
        "            \ 'build': 'bash install.sh',
        "            \ }) " Language Server Protocol support

        " if dein#tap('LanguageClient-neovim') && has('nvim')
        "     let g:LanguageClient_serverCommands = {
        "                 \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
        "                 \ 'javascript': ['javascript-typescript-stdio'],
        "                 \ 'typescript': ['tsserver'],
        "                 \ } " Language Server Protocol paths
        "     endif
        " " }}}

        " Dash -- Dash Support <Dash:> {{{
        " call dein#add('rizzatti/dash.vim')
        " }}}

        " Vimagit -- Emacs style Git management via <:Magit>, <C-n>, S[tage], and CC[omit] {{{
        " call dein#add('jreybert/vimagit')
        " }}}

        " Shougo/deoplete -- dark powered neo-completion {{{
        " call dein#add('Shougo/deoplete.nvim')

        " if dein#tap('Shougo/deoplete.nvim') && has('nvim')
        "     let g:deoplete#enable_at_startup = 1 " Enable deoplete at startup
        " endif
        " }}}

        " Shougo/denite.vim -- Emacs Helm for Vim {{{
        " call dein#add('Shougo/denite.nvim')

        " if dein#tap('Shougo/denite.nvim') && has('nvim')
        "         call denite#custom#option('_', {
        "                 \ 'prompt': 'π:',
        "                 \ 'empty': 0,
        "                 \ 'winheight': 16,
        "                 \ 'source_names': 'short',
        "                 \ 'vertical_preview': 1,
        "                 \ 'auto-accel': 1,
        "                 \ 'auto-resume': 1,
        "                 \ }) " Denite Options

        "         " The Silver Searcher
        "         if executable('ag')
        "                 call denite#custom#var('file_rec', 'command',
        "                         \ ['ag', '-U', '--hidden', '--follow', '--nocolor', '--nogroup', '-g', ''])

        "                 " Setup ignore patterns in your .agignore file!
        "                 " https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage

        "                 call denite#custom#var('grep', 'command', ['ag'])
        "                 call denite#custom#var('grep', 'recursive_opts', [])
        "                 call denite#custom#var('grep', 'pattern_opt', [])
        "                 call denite#custom#var('grep', 'separator', ['--'])
        "                 call denite#custom#var('grep', 'final_opts', [])
        "                 call denite#custom#var('grep', 'default_opts',
        "                         \ [ '--skip-vcs-ignores', '--vimgrep', '--smart-case', '--hidden' ])

        "         " elseif executable('ack')
        "         "     " Ack command
        "         "     call denite#custom#var('grep', 'command', ['ack'])
        "         "     call denite#custom#var('grep', 'recursive_opts', [])
        "         "     call denite#custom#var('grep', 'pattern_opt', ['--match'])
        "         "     call denite#custom#var('grep', 'separator', ['--'])
        "         "     call denite#custom#var('grep', 'final_opts', [])
        "         "     call denite#custom#var('grep', 'default_opts',
        "         "                     \ ['--ackrc', $HOME.'/.config/ackrc', '-H',
        "         "                     \ '--nopager', '--nocolor', '--nogroup', '--column'])
        "         endif
        "     endif
        " }}}

        " w0rp/ale -- Asynchrous Linting Engine {{{
        call dein#add('w0rp/ale')

        if dein#tap('ale') && has('nvim')
            let g:ale_fix_on_save = 1 " Set this setting in vimrc if you want to fix files automatically on save
            let g:ale_sign_error = '>>'
            let g:ale_sign_warning = '__'
            let g:ale_echo_msg_error_str = 'E'
            let g:ale_echo_msg_warning_str = 'W'
            let g:ale_echo_msg_format = '[%severity%] %s [%linter%]' " Standard format
            let g:ale_set_quickfix = 1 " Use quickfix Window
            let g:ale_open_list = 1 " Open Quickfix window with ale
        endif
        " }}}

        " Neomake -- Asynchronously run programs {{{
        " call dein#add('neomake/neomake')
        " }}}

        " aperezdc/vim-template -- Prebuilt templates for certain filetypes via <:Template>, or <$ vim foo.x>
        call dein#add('aperezdc/vim-template')

        " if dein#tap('aperezdc/vim-template') && has('nvim')
        "     let g:templates_debug = 1
        " endif
        " }}}

        " vim-easyclip -- Better thought out yanking, cutting, and pasting.
        " call dein#add('svermeulen/vim-easyclip')
        " }}}

        " sbdchd/vim-neoformat -- Script formatting {{{
        call dein#add('sbdchd/neoformat')

        if dein#tap('neoformat') && has('nvim')
            let g:neoformat_run_all_formatters = 1
            let g:neoformat_only_msg_on_error = 1
            let g:neoformat_basic_format_align = 1 " Enable alignment without FileType
            let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion FileType
            let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace FileType
            let g:neoformat_try_formatprg = 1 " Look for &formatprg
            let g:neoformat_basic_format_align = 1 " Enable alignment
            let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion
            let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace
        endif
        " }}}

        " SirVer/ultisnips -- Vim Snippet Framework {{{
        " call dein#add('SirVer/ultisnips')
        " }}}

        " honza/vim-snippets -- snipMate & UltiSnip Snippet Source {{{
        " call dein#add('honza/vim-snippets')
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
        call dein#add('hkupty/iron.nvim')

        if dein#tap('hkupty/iron') && has('nvim')
            let g:iron_repl_open_cmd = "vsplit"
        endif
        " }}}

        " haya14busa/dein-command.vim -- Dein commands (<:Dein> vs <call dein#x()> {{{
        call dein#add('haya14busa/dein-command.vim')
        " }}}

        call dein#end() " End Package Adds
        call dein#save_state() " Save Dein State


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
    echom "[._.] Check for package updates..."

    " call dein#load_state('~/.config/nvim/dein')

    " Update if Available
    if dein#check_update()
        silent dein#update()
    endif

endfunction


function packages#source(plugin) abort
    echom "[._.] Sourcing plugin..."
    " Argument scope via <a:>
    echom a:plugin

    if dein#load_state(s:dein_dir) " Script Scope via <s:>
        if dein#is_sourced(a:plugin)
            call dein#source(a:plugin)
        endif
    endif

endfunction


function! packages#check() abort
    echom "[._.] Checking packages..."

    " call dein#load_state('~/.config/nvim/dein')

    " Install if required
    " TODO: Doesn't do much; update seems to work though.
    if dein#check_install()
        call dein#check_clean()
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
