" Settings -----------------------------------------

" Neovim {{{
" Leader --
" Unbind and Map Space as Leader (Else Leader is <\>.)
" noremap <SPACE> <Nop>
" let mapleader=" "

" Buffers
" <;> for Buffers
nmap ; :Buffers<CR>

" Disable arrow movement, resize splits instead.
" nnoremap <Up>    :resize +2<CR>
" nnoremap <Down>  :resize -2<CR>
" nnoremap <Left>  :vertical resize +2<CR>
" nnoremap <Right> :vertical resize -2<CR>


" Operators --
" Sort in Visual Mode
vnoremap <Leader>s :sort<CR>

" Escape Neovim Terminal
:tnoremap <Esc> <C-\><C-n>

" This rewires n and N to do the highlighing
nnoremap <silent> n   n:call HLNext(0.4)<cr>
nnoremap <silent> N   N:call HLNext(0.4)<cr>

" Buffers --
" Ctrl Arrow Buffer Navigation?
" nnoremap <silent> <C-Right> <c-w>l
" nnoremap <silent> <C-Left> <c-w>h
" nnoremap <silent> <C-Up> <c-w>k
" nnoremap <silent> <C-Down> <c-w>j

" Splits --
" Ctrl HJKL Split Navigation
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" Visual Mode --
" Sort (in Visual Mode)
vnoremap <Leader>s :sort<CR>

" Custom {{{
" Highlight Next
nnoremap <silent> n   n:call HLNext(0.4)<cr>
nnoremap <silent> N   N:call HLNext(0.4)<cr>
" }}}

" vim-easy-align {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}


" vim-airline {{{
" Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1

" choose which path formatter airline uses
let g:airline#extensions#tabline#formatter = 'unique_tail'
" }}}

" Dirvish {{{
"   Interact with Fugitive forGstatus
autocmd FileType dirvish call fugitive#detect(@%)
" }}}

" Ale {{{
" Lint Gutter Alwaus open
" let g:ale_sign_column_always = 1
" }}

" Neoformat {{{
" Try using &formatprg
let g:neoformat_try_formatprg = 1

" Enable alignment
let g:neoformat_basic_format_align = 1

" Enable tab to spaces conversion
let g:neoformat_basic_format_retab = 1

" Enable trimmming of trailing whitespace
let g:neoformat_basic_format_trim = 1
" }}

" FZF {{
" <Leader>t for FZF :Files
nmap <Leader>t :Files<CR>

" <Leader>t for FZF :Tags
nmap <Leader>r :Tags<CR>
" Brew based install
"set rtp+=/usr/local/bin/fzf

" Git based install
set rtp+=~/.fzf

" Customize fzf colors to match your color scheme
" let g:fzf_colors =
"             \ { 'fg':      ['fg', 'Normal'],
"             \ 'bg':      ['bg', 'Normal'],
"             \ 'hl':      ['fg', 'Comment'],
"             \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"             \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"             \ 'hl+':     ['fg', 'Statement'],
"             \ 'info':    ['fg', 'PreProc'],
"             \ 'prompt':  ['fg', 'Conditional'],
"             \ 'pointer': ['fg', 'Exception'],
"             \ 'marker':  ['fg', 'Keyword'],
"             \ 'spinner': ['fg', 'Label'],
"             \ 'header':  ['fg', 'Comment'] }
" }}}

" Dash {{
" Search with <Leader + d> for word under cursor
:nmap <silent> <leader>d <Plug>DashSearch
" }}

" vim-move {{{
"   Use escape key instead of Alt (which doesn't work on macOS
"   http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim " for he <F20> hack.
"    Needs iTerm2 set to Esc+ in Profile > Keys
" set <F20>=j
" set <F21>=k
" vmap <F20> <Plug>MoveBlockDown
" vmap <F21> <Plug>MoveBlockUp
" nmap <F20> <Plug>MoveLineDown
" nmap <F21> <Plug>MoveLineUp
" }}

" deoplete {{{
let g:deoplete#enable_at_startup = 1

" Trigger on Omnifuncs
if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif

" All Patterns
let g:deoplete#keyword_patterns = {}
" }}}

" SuperTab {{{
let g:SuperTabClosePreviewOnPopupClose = 1
let g:SuperTabContextDefaultCompletionType = "<c-n>"
" }}}

" LanguageClient - neovim {{{
" let g:LanguageClient_autoStart = 1
" let g:LanguageClient_serverCommands = {
"             \ 'typescript': ['typescript-language-server', '--stdio']
"             \ }
" }}}

" vim-autoformat {{{
" Autoformat on Save
" au BufWrite * :Autoformat

" But don't replace mismatches with tabs
" let g:autoformat_autoindent = 0
" let g:autoformat_retab = 0
" let g:autoformat_remove_trailing_spaces = 0
"}}}

" neomake {{{
" let g:neomake_logfile = '/tmp/neomake.log'
" let g:neomake_open_list = 2
" call neomake#configure#automake('w')
" }}}

" vim-autoswap {{{
set title titlestring=
" }}}

" tagbar {{{
" Auto Open (for Right Files)
" autocmd VimEnter * nested :call tagbar#autoopen(1)
" let g:tagbar_autofocus = 0
" let g:tagbar_foldlevel = 2
"
" let g:tagbar_type_typescript = {
"   \ 'ctagsbin' : 'tstags',
"   \ 'ctagsargs' : '-f-',
"   \ 'kinds': [
"     \ 'e:enums:0:1',
"     \ 'f:function:0:1',
"     \ 't:typealias:0:1',
"     \ 'M:Module:0:1',
"     \ 'I:import:0:1',
"     \ 'i:interface:0:1',
"     \ 'C:class:0:1',
"     \ 'm:method:0:1',
"     \ 'p:property:0:1',
"     \ 'v:variable:0:1',
"     \ 'c:const:0:1',
"   \ ],
"   \ 'sort' : 0
" \ }
" }}}

" vim-schlepp {{{
" Visual Arrow Keys
vmap <unique> <up>    <Plug>SchleppUp
vmap <unique> <down>  <Plug>SchleppDown
vmap <unique> <left>  <Plug>SchleppLeft
vmap <unique> <right> <Plug>SchleppRight
" }}}


" rainbow {{{
let g:rainbow_active = 1
"}}}

" NVIMUX {{{
" let g:nvimux_prefix='<C-Space>'
" let nvimux_open_term_by_default=1
" }}}
