" Packages  ------------------------------------------------------------------

" Setup
" Packages are downloaded and lazy loaded via Dein
" which is imported natively via pack/dein/start
" Additional logic is stored in pack/dein/config

" packadd dein " Automatically added via pack/
" Set Path
let s:dein_cache = expand('$HOME/.cache/nvim/')
let s:dein_dir      = expand(s:dein_cache . '/dein')
let s:dein_pack      = expand('$HOME/.config/nvim/pack/dein')
let s:dein_start     = expand(s:dein_pack .'/start')
let s:dein_config      = expand(s:dein_pack .'/config')
let s:dein_log      = expand(s:dein_pack .'/log')
let s:dein_repo      = expand(s:dein_start . '/dein.vim')
let s:lang_repo      = expand(s:dein_start . '/vim-polyglot')

" Configuration
" Local Dein parameters
let g:dein#install_max_processes = 32
let g:dein#install_progress_type = 'title'
let g:dein#enable_notification = 1
let g:dein#notification_icon = '$HOME/.config/nvim/signs'
let g:dein#install_log_filename = expand(s:dein_log.'/dein.log')

function packages#setup() abort
    echom "[._.] Setting up packages..."

    if dein#load_state(s:dein_dir)
        call dein#begin(s:dein_dir, $MYVIMRC)
        call dein#add(s:dein_repo)
        call dein#add(s:lang_repo)

        let s:toml_list = split(glob(s:dein_config.'/*.toml'), '\n')
        " Recursively load every *.toml into Dein
        for s:toml in s:toml_list
            " echom "[._.] Installing package list" s:toml
            call dein#load_toml(s:toml)
        endfor

        call dein#end()
        call dein#save_state()
        "
        " Run source hooks for non-lazy plugins
        call dein#call_hook('source')
        call dein#call_hook('post_source')
    endif
endfunction

" call dein#load_toml(expand(s:dein_config . 'aesthetic.toml'))

" dracula/vim -- A Dark Colorscheme {{{
"call dein#add('dracula/vim')
"" }}}

"" andreasvc/vim-256noir -- Red numbers, white strings {{{
"call dein#add('andreasvc/vim-256noir')
"" }}}

"" thiagoalessio/rainbow -- Color by depth! {{{
"" call dein#add('thiagoalessio/rainbow_levels.vim', {
""             \ 'merged': 0,
""             \ 'on_cmd' : 'RainbowLevelsOn'
""             \ })


"" }}}

"" tpope/sensible.vim -- Sensible Defaults {{{
"call dein#add('tpope/vim-sensible')
"" }}}

"" farmergreg/vim-lastplace -- Start where you ended in Vim!
"call dein#add('farmergreg/vim-lastplace')
"" }}}

"" kana/vim-textobj-user -- https://github.com/kana/vim-textobj-user/wiki {{{
"call dein#add('kana/vim-textobj-user')
"" }}}

"" bronson/vim-visual-star-search -- Search with * in Character Block {{{
"call dein#add('bronson/vim-visual-star-search', {
"            \ 'on_map': { 'x' : ['*'] }
"            \ })
"" }}}

"" unblevable/quick-scope -- Character match highlighting {{{
"" call dein#add('unblevable/quick-scope', {
""             \'on_map': ['f', 'F', 't', 'T']
"" \ })
"" }}}

"" tpope/repeat.vim -- Dot commands on steroids {{{
"call dein#add('tpope/vim-repeat', {
"            \ 'on_map' : '.'
"            \ })
"" }}}

"" sheerun/vim-polyglot -- language packs for Vim {{{
"call dein#add('sheerun/vim-polyglot')
"" }}}

"" vim-vyper -- (My attempt at) Vyper support {{{
"call dein#add('vvkmnn/vim-vyper')
"" \ { 'on_ft': 'vyper' })
"" }}}

"" tpope/vim-dispatch -- Async making via <Dispatch!> or <Make!>{{{
"call dein#add('tpope/vim-dispatch', {
"            \ 'on_cmd': ['Make', 'Make!', 'Dispatch', 'Dispatch!']
"            \ })

"" }}}


"" justinmk/vim-dirvish -- Minimal Navigator via <-> {{{
"" call dein#add('justinmk/vim-dirvish', {
""             \ 'on_cmd' : 'Dirivish',
""             \ 'on_map' : '-' })
"" }}}

"" tpope/vim-eunech -- Unix helpers via <:Delete>, <:Move>, ... {{{
"call dein#add('tpope/vim-eunuch')
"" }}}

"" tyru/open-browser.vim -- Additional Text Objects {{{
"call dein#add('tyru/open-browser.vim', {
"            \ 'on_map': { 'n': '<Plug>(openbrowser_smart_search)'}
"            \})

"if dein#tap('open-browser.vim') && has('nvim')
"    let g:netrw_nogx = 1 " disable netrw's gx mapping.
"    nnoremap gx <Plug>(openbrowser-smart-search)
"    vnoremap gx <Plug>(openbrowser-smart-search)
"endif
"" }}}


"" call dein#add('godlygeek/tabular', {
""             \ 'on_cmd' : [ 'Tab', 'Tabularize' ]
""             \ })

"" tpope/surround.vim -- Wrap objects with stuff using <cs[input][output], cst[input]> and remove with <ds[input]>
"call dein#add('tpope/vim-surround', {
"            \ 'on_map': {
"            \'n' : ['cs', 'ds', 'ys'],
"            \'x' : ['S']
"            \ },
"            \ 'depends' : 'vim-repeat'
"            \ })
"" }}}

"" tpope/unimpaired.vim -- Handy [] maps <]q> / <:cnext>, <[b> / <:bprevious>, etc.> {{{
"call dein#add('tpope/vim-unimpaired')
"" }}}


"" airblade/vim-gitgutter -- Git status next to line numbers {{{
"call dein#add('airblade/vim-gitgutter')
"" }}}


"" tpope/vim-fugitive -- A Vim Git Wrapper {{{
"call dein#add('tpope/vim-fugitive', {
"            \ 'on_cmd': [ 'Git', 'Gstatus', 'Gwrite', 'Glog', 'Gcommit', 'Gblame', 'Ggrep', 'Gdiff']
"            \ })

"" Vimagit -- Emacs style Git management via <:Magit>, <C-n>, S[tage], and CC[omit] {{{
"call dein#add('jreybert/vimagit', {
"            \ 'on_cmd': 'Magit'
"            \ })
"" }}}

"" }}}

"" tomtom/tcomment_vim -- Commenting with motions {{{
"" call dein#add('tomtom/tcomment_vim', {'on_map': 'gc', 'on_cmd' : 'TComment'})
"" }}}

"" tpope/commentary.vim -- Comment stuff out with <:gc[motion]>, uncomment with <:gcgc> {{{
"call dein#add('tpope/vim-commentary', {
"            \ 'on_map': { 'n':'gc' , 'x':'gc'}
"            \ })
"" }}}

"" junegunn/vim-easy-altign -- Vim Spellcheck++ {{{
"call dein#add('junegunn/vim-easy-align', {
"             \ 'on_cmd':   ['EasyAlign'],
"             \ 'on_map':   { 'n': '<Plug>(EasyAlign)', 'x': '<Plug>(EasyAlign)'},
"            \ 'hook_add': join(
"             \   ['nmap ga <Plug>(EasyAlign)',
"\    'xmap ga <Plug>(EasyAlign)'], "\n")
"\ })
"" }}}

"" reedes/vim-lexical -- Vim Spellcheck++ {{{
"call dein#add('reedes/vim-lexical', {
"            \   'on_ft':['markdown','text','textile']
"            \ })

"if dein#tap('vim-lexical') && has('nvim')
"    let g:lexical#spell = 1
"endif
"" }}}

"" kien/rainbow_parentheses.vim -- Better Rainbow Parenthesis {{{
"call dein#add('kien/rainbow_parentheses.vim')
"" }}}

"" giole/vim-autoswap -- No swap messages; just switch or recover {{{
"call dein#add('gioele/vim-autoswap')
"" }}}

"" w0rp/ale -- Asynchrous Linting Engine {{{
"call dein#add('w0rp/ale')

"if dein#tap('ale') && has('nvim')
"    let g:ale_fix_on_save = 1 " Set this setting in vimrc if you want to fix files automatically on save
"    " let g:ale_sign_error = '>>'
"    " let g:ale_sign_warning = '__'
"    " let g:ale_echo_msg_error_str = 'E'
"    " let g:ale_echo_msg_warning_str = 'W'
"    let g:ale_echo_msg_format = '[%severity%] %s [%linter%]' " Standard format
"    let g:ale_set_quickfix = 1 " Use quickfix Window
"    let g:ale_open_list = 0 " Open Quickfix window with ale
"    " let g:ale_keep_list_window_open = 1 " Set this if you want to.
"endif
"" }}}

"" Dash -- Dash Support <Dash:> {{{
"call dein#add('rizzatti/dash.vim', {
"            \ 'on_cmd': ['Dash', 'DashSearch'],
"            \ 'on_map': '<Plug>DashSearch'
"            \ })

"if dein#tap('dash.vim') && has('nvim')
"    " Search for word under cursor with <leader>d
"    nmap <leader>d <Plug>DashSearch
"endif
"" }}}

"" Shougo/deoplete -- dark powered neo-completion {{{
"call dein#add('Shougo/deoplete.nvim')

"if dein#tap('deoplete.nvim') && has('nvim')
"    let g:deoplete#enable_at_startup = 1 " Enable deoplete at startup
"endif

"if dein#tap('neosnippet.vim') && dein#tap('deoplete.nvim')

"    " Insert Mode previews via Ctrl - N, Tab to complete
"    " inoremap <expr><TAB>
"    "             \ neosnippet#expandable_or_jumpable() ?
"    "             \    "\<Plug>(neosnippet_expand_or_jump)" :
"    "             \          \ pumvisible() ? "\<C-n>" : "\<TAB>"

"    " inoremap <expr><S-TAB>
"    "             \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

"    " inoremap <expr><CR>
"    "             \ pumvisible() ? deoplete#mappings#close_popup() : "\<CR>"
"    "

"    " Select Mode Completions into Snippets
"    smap <expr><TAB>
"                \ neosnippet#expandable_or_jumpable() ?
"                \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
"    "     " For conceal markers.
"    "     " if has('conceal')
"    "     "     set conceallevel=2 concealcursor=niv
"    "     " endif
"endif
"" }}}

"" Shougo/neco-syntax - Syntax Deoplete Source {{{
"call dein#add('Shougo/neco-syntax', {
"            \ 'depends': 'deoplete.nvim'
"            \ })
"" }}}

"" fszymanski/deoplete-emoji -- Emoji Deoplete Source {{{
"call dein#add('fszymanski/deoplete-emoji', {
"            \ 'depends': 'deoplete.nvim'
"            \ })
"" }}}

"" zchee/deoplete-zsh -- ZSH Deoplete Source {{{
"call dein#add('zchee/deoplete-zsh', {
"            \ 'depends': 'deoplete.nvim'
"            \ })
"" }}}

"" autozimu/LanguageClient-neovim - LSP Integration for Vim {{{
"call dein#add('autozimu/LanguageClient-neovim', {
"            \ 'rev': 'next',
"            \ 'build': 'bash install.sh',
"            \ 'on_ft': ['typescript', 'javascript', 'python'],
"            \ 'depends': 'deoplete.nvim'
"            \ }) " Language Server Protocol support

"if dein#tap('LanguageClient-neovim') && has('nvim')
"    let g:LanguageClient_serverCommands = {
"                \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
"                \ 'javascript': ['javascript-typescript-stdio'],
"                \ 'typescript': ['tsserver'],
"                \ 'python': ['python-language-server'],
"                \ } " Language Server Protocol paths
"endif
"" }}}

"" SirVer/ultisnips - Ultisnips! {{{
"" call dein#add('SirVer/ultisnips', {
""             \ 'depends':'deoplete.nvim'
""             \ })

"" if dein#tap('deoplete.nvim') && dein#tap('ultisnips') && has('nvim')
""     call deoplete#custom#set('ultisnips', 'matchers', ['matcher_fuzzy'])
"" endif

""
"" honza/vim-snippets -- Ultisnip Snippets {{{
"" call dein#add('honza/vim-snippets', {
""             \ 'depends':['ultisnips','deoplete.nvim']
""             \ })
"" }}}

"" Shougo/neosnippet -- Plug-in support in Deoplete {{{
"call dein#add('Shougo/neosnippet.vim', {
"            \ 'depends': 'deoplete.nvim'})

"call dein#add('Shougo/neosnippet-snippets', {
"            \ 'depends': ['deoplete.nvim','neosnippet.vim']
"            \ })
"" }}}

"" Shougo/echodoc.vim -- Prints documentation in the echo area {{{
"call dein#add('Shougo/echodoc.vim', {
"            \ 'depends': 'deoplete.nvim'
"            \ })

"" Shougo/deol.nvim -- Dark / Async powered Shell {{{
"call dein#add('Shougo/deol.nvim', {
"            \ 'on_cmd':['Deol','DeolCd','DeloEdit']
"            \ })

"if dein#tap('deol.nvim') && has('nvim')

"    let g:deol#prompt_pattern = '% \|%$' " Sets the pattern which matches the shell prompt.

"endif

"" Shougo/denite.vim -- Emacs Helm for Vim {{{
"call dein#add('Shougo/denite.nvim', {
"            \ 'on_cmd':'Denite'
"            \ })

"if dein#tap('denite.nvim') && has('nvim')
"    call denite#custom#option('_', {
"                \ 'prompt': 'π:',
"                \ 'empty': 0,
"                \ 'winheight': 16,
"                \ 'source_names': 'short',
"                \ 'vertical_preview': 1,
"                \ 'auto-accel': 1,
"                \ 'auto-resume': 1,
"                \ }) " Denite Options

"    " The Silver Searcher
"    if executable('ag')
"        call denite#custom#var('file_rec', 'command',
"                    \ ['ag', '-U', '--hidden', '--follow', '--nocolor', '--nogroup', '-g', ''])

"        " Setup ignore patterns in your .agignore file!
"        " https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage

"        call denite#custom#var('grep', 'command', ['ag'])
"        call denite#custom#var('grep', 'recursive_opts', [])
"        call denite#custom#var('grep', 'pattern_opt', [])
"        call denite#custom#var('grep', 'separator', ['--'])
"        call denite#custom#var('grep', 'final_opts', [])
"        call denite#custom#var('grep', 'default_opts',
"                    \ [ '--skip-vcs-ignores', '--vimgrep', '--smart-case', '--hidden' ])

"    elseif executable('ack')
"        " Ack command
"        call denite#custom#var('grep', 'command', ['ack'])
"        call denite#custom#var('grep', 'recursive_opts', [])
"        call denite#custom#var('grep', 'pattern_opt', ['--match'])
"        call denite#custom#var('grep', 'separator', ['--'])
"        call denite#custom#var('grep', 'final_opts', [])
"        call denite#custom#var('grep', 'default_opts',
"                    \ ['--ackrc', $HOME.'/.config/ackrc', '-H',
"                    \ '--nopager', '--nocolor', '--nogroup', '--column'])
"    endif
"endif
"" }}}

"" sbdchd/vim-neoformat -- Script formatting {{{
"call dein#add('sbdchd/neoformat')

"if dein#tap('neoformat') && has('nvim')
"    let g:neoformat_run_all_formatters = 1
"    let g:neoformat_only_msg_on_error = 0
"    let g:neoformat_basic_format_align = 1 " Enable alignment without FileType
"    let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion FileType
"    let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace FileType
"    let g:neoformat_try_formatprg = 1 " Look for &formatprg
"    let g:neoformat_basic_format_align = 1 " Enable alignment
"    let g:neoformat_basic_format_retab = 1 " Enable tab to spaces conversion
"    let g:neoformat_basic_format_trim = 1 " Enable trimmming of trailing whitespace
"endif
"" }}}

"" haya14busa/dein-command.vim -- Dein commands (<:Dein> vs <call dein#x()> {{{
"call dein#add('haya14busa/dein-command.vim', {
"            \ 'on_cmd': 'Dein',
"            \ 'depends': 'dein.vim'})
" }}}

" ap/vim-templates -- Filetype dependent templates {{{
" call dein#add('ap/vim-templates')
"
" if dein#tap('vim-templates') && has('nvim')
"     let g:templates_empty_files = 1
" endif
" }}}

" tpope/vim-vinegar -- netrw upgrade {{{
" call dein#add('tpope/vim-vinegar')
" }}}


" osyo-manga/vim-over -- Preview substitutions with <OverCommandLine>
" call dein#add('osyo-manga/vim-over', { 'on_cmd' : 'OverCommandLine' })
" }}}

" tmhedberg/matchit -- extended % matching
" call dein#add('tmhedberg/matchit', { 'on_ft' : 'html' })
" }}}


" ap/vim-buftabline -- Vim Buffer Tabs {{{
" call dein#add('ap/vim-buftabline')
" }}}

" roman/golden-ratio -- Golden Ratio windows {{{
" call dein#add('roman/golden-ratio')
" }}}

" goerz/ipynb_notedown.vim -- ipynb edit {{{
" call dein#add('goerz/ipynb_notedown.vim')
" }}}

" thaerkh/vim-workspace -- Automated Session Management with <:ToggleWorkplace> {{{
" call dein#add('thaerkh/vim-workspace')
" }}}

" iron.vim -- Interactive Repls Over Neovim {{{
" call dein#add('hkupty/iron.nvim')
"
" if dein#tap('iron.vim') && has('nvim')
"     let g:iron_repl_open_cmd = "vsplit"
" endif
" }}}

" Neomake -- Asynchronously run programs {{{
" call dein#add('neomake/neomake', {
"             \ 'on_cmd' : '})
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


function packages#clean() abort
    echom "[._.] Cleaning packages..."

    call dein#recache_runtimepath()
endfunction

function packages#update() abort
    echom "[._.] Check for package updates..."

    if dein#check_update()
        dein#update()
    endif
endfunction

function packages#deload() abort
    echom "[._.] Deloading default packages..."

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
    " let g:loaded_netrw             = 0
    " let g:loaded_netrwPlugin       = 0
    " let g:loaded_netrwSettings     = 0
    " let g:loaded_netrwFileHandlers = 0
    let g:loaded_logipat           = 1
endfunction

"
" function packages#source(plugin) abort
"     echom "[._.] Sourcing plugin..."
"     " Argument scope via <a:>
"     echom a:plugin
"
"     if dein#load_state(s:dein_dir) " Script Scope via <s:>
"         if dein#is_sourced(a:plugin)
"             call dein#source(a:plugin)
"         endif
"     endif
"
" endfunction

function packages#install() abort
    echom "[._.] Installing packages..."

    if dein#check_install()
        call dein#install()
    endif
endfunction

" Commands ---------------------------------------------------------------------
" User commands for updating/cleaning the plugins.
" command! Deload call packages#deload()
" command! PackageSetup call packages#setup() | nested call packages#install()
" command! PackageClose call packages#clean()
