" Packages  --------------------------------------------------------------------

" import Dein if in pack/*/opt (Automatically added via pack/*/start)
" packadd dein

" Set Path
let s:dein_dir        = expand('$HOME/.config/nvim/dein')
let s:dein_repo_dir   = expand('$HOME/.config/nvim/pack/custom/start/dein.vim')
execute 'set runtimepath^=' . s:dein_repo_dir

function packages#setup() abort
    echom "[._.] Setting up aesthetic packages..."

    " Start Adding Packages
    if dein#load_state(s:dein_dir)
        call dein#begin(s:dein_dir)

        " Shougo/dein -- A Dark  Package Manager {{{
        call dein#add(s:dein_repo_dir)

        if dein#tap('dein.vim') && has('nvim')
            let g:dein#install_progress_type = 'title'
            " let g:dein#enable_notification = 1
        endif

        " dracula/vim -- A Dark Colorscheme {{{
        call dein#add('dracula/vim')
        " }}}

        " andreasvc/vim-256noir -- Red numbers, white strings {{{
        call dein#add('andreasvc/vim-256noir')
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

        " tpope/sensible.vim -- Sensible Defaults {{{
        call dein#add('tpope/vim-sensible')
        " }}}

        " tpope/repeat.vim -- Dot commands on steroids {{{
        call dein#add('tpope/vim-repeat', {'on_map' : '.'})
        " }}}

        " sheerun/vim-polyglot -- language packs for Vim {{{
        call dein#add('sheerun/vim-polyglot')
        " }}}
        
        " romainl/vim-qf -- Quickfix modifiers {{{
        call dein#add('romainl/vim-qf', {
                     \ 'on_cmd': ['cnext','copen']
                     \ })

        if dein#tap('romainl/vim-qf') && has('nvim')
            let g:qf_auto_open_quickfix = 0
        endif
        

        " justinmk/vim-dirvish -- Minimal Navigator via <-> {{{
        call dein#add('justinmk/vim-dirvish', {
                    \ 'merged': 0,
                    \ 'on_cmd' : 'Dirivish',
                    \ 'on_map' : '-' })
        " }}}

        " tpope/vim-eunech -- Unix helpers via <:Delete>, <:Move>, ... {{{
        call dein#add('tpope/vim-eunuch')
        " }}}

        " wellle/targets.vim -- Additional Text Objects {{{
        call dein#add('wellle/targets.vim')
        " }}}

        " tpope/surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
        call dein#add('tpope/vim-surround',
                    \ {'on_map': {'n' : ['cs', 'ds', 'ys'], 'x' : 'S'},
                    \ 'depends' : 'vim-repeat'
                    \ })
        " }}}

        call dein#add('godlygeek/tabular',
                    \ { 'on_cmd' :
                    \ [ 'Tab', 'Tabularize' ]
                    \ })

        " tpope/unimpaired.vim -- Handy [] maps <]q> / <:cnext>, <[b> / <:bprevious>, etc.> {{{
        call dein#add('tpope/vim-unimpaired')
        " }}}


        " airblade/vim-gitgutter -- Git status next to line numbers {{{
        call dein#add('airblade/vim-gitgutter')
        " }}}


        " tpope/vim-fugitive -- A Vim Git Wrapper {{{
        call dein#add('tpope/vim-fugitive',
                    \ { 'on_cmd': [ 'Git',
                    \ 'Gstatus',
                    \ 'Gwrite',
                    \ 'Glog',
                    \'Gcommit',
                    \ 'Gblame',
                    \ 'Ggrep',
                    \ 'Gdiff']})
        " }}}

        " tomtom/tcomment_vim -- Commenting with motions {{{
        call dein#add('tomtom/tcomment_vim', {'on_map': 'gc', 'on_cmd' : 'TComment'})
        " }}}

        " reedes/vim-lexical -- Vim Spellcheck++ {{{
        call dein#add('reedes/vim-lexical', {
                    \   'on_ft': ['markdown', 'text']
                    \ })
        " }}}

        " giole/vim-autoswap -- No swap messages; just switch or recover {{{
        call dein#add('gioele/vim-autoswap')
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
            let g:ale_open_list = 0 " Open Quickfix window with ale
        endif
        " }}}

        " Dash -- Dash Support <Dash:> {{{
        call dein#add('rizzatti/dash.vim', {
                    \ 'on_cmd': 'Dash'
                    \ })

        if dein#tap('dash.vim') && has('nvim')
            "
            " Search for word under cursor with <leader>d
            nnoremap <silent> <leader>d <Plug>DashSearch
        endif
        " }}}

        " Shougo/deoplete -- dark powered neo-completion {{{
        call dein#add('Shougo/deoplete.nvim')

        if dein#tap('deoplete.nvim') && has('nvim')
            let g:deoplete#enable_at_startup = 1 " Enable deoplete at startup


            " Shougo/neco-syntax - Syntax Deoplete Source {{{
            call dein#add('Shougo/neco-syntax', {
                        \ 'depends': 'deoplete.nvim'
                        \ })
            " }}}

            " fszymanski/deoplete-emoji -- Emoji Deoplete Source {{{
            call dein#add('fszymanski/deoplete-emoji', {
                        \ 'depends': 'deoplete.nvim'
                        \ })
            " }}}
        endif
        " }}}

        " autozimu/LanguageClient-neovim - LSP Integration for Vim {{{
        call dein#add('autozimu/LanguageClient-neovim', {
                    \ 'rev': 'next',
                    \ 'build': 'bash install.sh',
                    \ 'on_ft': ['typescript', 'javascript', 'python'],
                    \ 'depends': 'deoplete.nvim'
                    \ }) " Language Server Protocol support

        if dein#tap('LanguageClient-neovim') && has('nvim')
            let g:LanguageClient_serverCommands = {
                        \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
                        \ 'javascript': ['javascript-typescript-stdio'],
                        \ 'typescript': ['tsserver'],
                        \ 'python': ['python-language-server'],
                        \ } " Language Server Protocol paths
        endif
        " }}}

        " Shougo/neosnippet -- Plug-in support in Deoplete {{{
        call dein#add('Shougo/neosnippet')
        call dein#add('Shougo/neosnippet-snippets')

        if dein#tap('neosnippet') && dein#tap('deoplete.nvim') && has('nvim')
            " Plugin key-mappings.
            " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
            " imap <C-k>     <Plug>(neosnippet_expand_or_jump)
            " smap <C-k>     <Plug>(neosnippet_expand_or_jump)
            " xmap <C-k>     <Plug>(neosnippet_expand_target)

            " Insert Mode previews via Ctrl - N, Tab to complete
            imap <expr><TAB>
                        \ neosnippet#expandable_or_jumpable() ?
                        \    "\<Plug>(neosnippet_expand_or_jump)" :
                        \     pumvisible() ? "\<C-n>" : "\<TAB>"

            " imap <expr><TAB> pumvisible() ? "\<C-n>" : neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
            " imap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
            " inoremap <expr><CR> pumvisible() ? deoplete#mappings#close_popup() : "\<CR>"

            " SuperTab like snippets behavior.
            "" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
            ""imap <expr><TAB>
            "" \ pumvisible() ? "\<C-n>" :
            "" \ neosnippet#expandable_or_jumpable() ?
            "" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
            "smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            "            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

            " For conceal markers.
            " if has('conceal')
            "     set conceallevel=2 concealcursor=niv
            " endif
        endif
        " }}}

        " Shougo/echodoc.vim -- Prints documentation in the echo area {{{
        call dein#add('Shougo/echodoc.vim')
        " }}}

        " Shougo/denite.vim -- Emacs Helm for Vim {{{
        call dein#add('Shougo/denite.nvim', {
                    \ 'on_cmd':'Denite'
                    \ })

        if dein#tap('denite.nvim') && has('nvim')
            call denite#custom#option('_', {
                        \ 'prompt': 'π:',
                        \ 'empty': 0,
                        \ 'winheight': 16,
                        \ 'source_names': 'short',
                        \ 'vertical_preview': 1,
                        \ 'auto-accel': 1,
                        \ 'auto-resume': 1,
                        \ }) " Denite Options

            " The Silver Searcher
            if executable('ag')
                call denite#custom#var('file_rec', 'command',
                            \ ['ag', '-U', '--hidden', '--follow', '--nocolor', '--nogroup', '-g', ''])

                " Setup ignore patterns in your .agignore file!
                " https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage

                call denite#custom#var('grep', 'command', ['ag'])
                call denite#custom#var('grep', 'recursive_opts', [])
                call denite#custom#var('grep', 'pattern_opt', [])
                call denite#custom#var('grep', 'separator', ['--'])
                call denite#custom#var('grep', 'final_opts', [])
                call denite#custom#var('grep', 'default_opts',
                            \ [ '--skip-vcs-ignores', '--vimgrep', '--smart-case', '--hidden' ])

            elseif executable('ack')
                " Ack command
                call denite#custom#var('grep', 'command', ['ack'])
                call denite#custom#var('grep', 'recursive_opts', [])
                call denite#custom#var('grep', 'pattern_opt', ['--match'])
                call denite#custom#var('grep', 'separator', ['--'])
                call denite#custom#var('grep', 'final_opts', [])
                call denite#custom#var('grep', 'default_opts',
                            \ ['--ackrc', $HOME.'/.config/ackrc', '-H',
                            \ '--nopager', '--nocolor', '--nogroup', '--column'])
            endif
        endif
        " }}}

        " ap/vim-templates -- Filetype dependent templates {{{
        call dein#add('ap/vim-templates')

        if dein#tap('vim-template') && has('nvim')
            let g:templates_empty_files = 1
        endif
        " }}}


        " sbdchd/vim-neoformat -- Script formatting {{{
        call dein#add('sbdchd/neoformat')

        if dein#tap('neoformat') && has('nvim')
            let g:neoformat_run_all_formatters = 1
            let g:neoformat_only_msg_on_error = 0
            let g:neoformat_basic_format_align = 1 " Enable alignment without FileType
            let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion FileType
            let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace FileType
            let g:neoformat_try_formatprg = 1 " Look for &formatprg
            let g:neoformat_basic_format_align = 1 " Enable alignment
            let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion
            let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace
        endif
        " }}}

        " haya14busa/dein-command.vim -- Dein commands (<:Dein> vs <call dein#x()> {{{
        call dein#add('haya14busa/dein-command.vim')
        " }}}

        call dein#end() " End Package Adds
        call dein#save_state() " Save Dein State
    endif
endfunction

" tpope/vim-vinegar -- netrw upgrade {{{
" call dein#add('tpope/vim-vinegar')
" }}}

" osyo-manga/vim-over -- Preview substitutions with <OverCommandLine>
" call dein#add('osyo-manga/vim-over', { 'on_cmd' : 'OverCommandLine' })
" }}}

" tmhedberg/matchit -- extended % matching
" call dein#add('tmhedberg/matchit', { 'on_ft' : 'html' })
" }}}

" tpope/commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc> {{{
" call dein#add('tpope/vim-commentary')
" }}}

" ap/vim-buftabline -- Vim Buffer Tabs {{{
" call dein#add('ap/vim-buftabline')
" }}}

" roman/golden-ratio -- Golden Ratio windows {{{
" call dein#add('roman/golden-ratio')
" }}}

" thaerkh/vim-workspace -- Automated Session Management with <:ToggleWorkplace> {{{
" call dein#add('thaerkh/vim-workspace')
" }}}

" Vimagit -- Emacs style Git management via <:Magit>, <C-n>, S[tage], and CC[omit] {{{
" call dein#add('jreybert/vimagit')
" }}}

" iron.vim -- Interactive Repls Over Neovim {{{
" call dein#add('hkupty/iron.nvim')
"
" if dein#tap('iron.vim') && has('nvim')
"     let g:iron_repl_open_cmd = "vsplit"
" endif
" }}}

" Neomake -- Asynchronously run programs {{{
" call dein#add('neomake/neomake')
" }}}

" aperezdc/vim-template -- Prebuilt templates for certain filetypes via <:Template>, or <$ vim foo.x>
" call dein#add('aperezdc/vim-template')

" vim-easyclip -- Better thought out yanking, cutting, and pasting.
" call dein#add('svermeulen/vim-easyclip')
" }}}


" TODO: Tbd. {{{
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

" kien/rainbow_parentheses.vim -- Better Rainbow Parenthesis {{{
" call dein#add('kien/rainbow_parentheses.vim')
" }}}

" if dein#tap('rainbow_parentheses.vim') && has('nvim')
"     " let g:rbpt_loadcmd_toggle = 0
" endif
" }}}

" luochen1990/rainbow -- Rainbow Parentheses Improved -- Color code by depth {{{
" call dein#add('luochen1990/rainbow')

" if dein#tap('rainbow.vim') && has('nvim')
" let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
" endif
" }}}

" TODO: Gui?
" if has("gui_running")
" endif


function! packages#update() abort
    echom "[._.] Check for package updates..."

    if dein#check_update()
        dein#update()
    endif
endfunction

function packages#deload() abort
    " Disable some default plugins.
    let g:loaded_gzip              = 1
    let g:loaded_tar               = 1
    let g:loaded_tarPlugin         = 1
    let g:loaded_zip               = 1
    let g:loaded_zipPlugin         = 1
    let g:loaded_rrhelper          = 1
    let g:loaded_2html_plugin      = 1
    let g:loaded_vimball           = 1
    let g:loaded_vimballPlugin     = 1
    let g:loaded_getscript         = 1
    let g:loaded_getscriptPlugin   = 1
    let g:loaded_netrw             = 0
    let g:loaded_netrwPlugin       = 1
    let g:loaded_netrwSettings     = 1
    let g:loaded_netrwFileHandlers = 1
    let g:loaded_logipat           = 1
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

    if dein#check_install()
        call dein#install()
    endif
endfunction

" Commands ---------------------------------------------------------------------
" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
command! PackSetup packadd minpac | source $MYVIMRC | call packages#setup()
command! PackUpdate packadd minpac | source $MYVIMRC | call packages#check()
