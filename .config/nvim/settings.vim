" Settings -----------------------------------------

" FZF {{
set rtp+=/usr/local/opt/fzf
" }}

" Dash {{ 
"   with Leader + d for word under cursor
:nmap <silent> <leader>d <Plug>DashSearch
" }}

" Vim Move {{ 
"   Use escape key instead of Alt (which doesn't work on macOS
"   http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim " for he <F20> hack. 
"    Needs iTerm2 set to Esc+ in Profile > Keys
set <F20>=j
set <F21>=k
vmap <F20> <Plug>MoveBlockDown
vmap <F21> <Plug>MoveBlockUp
nmap <F20> <Plug>MoveLineDown
nmap <F21> <Plug>MoveLineUp
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
" }}}

" LanguageClient - neovim {{{
let g:LanguageClient_autoStart = 1

let g:LanguageClient_serverCommands = {
      \ 'typescript': ['typescript-language-server', '--stdio']
      \ }
" }}}

" vim-autoformat {{{
" Autoformat on Save
au BufWrite * :Autoformat

" But don't replace mismatches with tabs
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0
"}}}

" neomake {{{
let g:neomake_logfile = '/tmp/neomake.log'
let g:neomake_open_list = 2
call neomake#configure#automake('w')
" }}}

" vim-autoswap {{{
set title titlestring=
" }}}

" tagbar {{{
" Auto Open (for Right Files)
autocmd VimEnter * nested :call tagbar#autoopen(1)

let g:tagbar_type_typescript = {                                                  
  \ 'ctagsbin' : 'tstags',                                                        
  \ 'ctagsargs' : '-f-',                                                           
  \ 'kinds': [                                                                     
    \ 'e:enums:0:1',                                                               
    \ 'f:function:0:1',                                                            
    \ 't:typealias:0:1',                                                           
    \ 'M:Module:0:1',                                                              
    \ 'I:import:0:1',                                                              
    \ 'i:interface:0:1',                                                           
    \ 'C:class:0:1',                                                               
    \ 'm:method:0:1',                                                              
    \ 'p:property:0:1',                                                            
    \ 'v:variable:0:1',                                                            
    \ 'c:const:0:1',                                                              
  \ ],                                                                            
  \ 'sort' : 0                                                                    
\ }                                                                               
" }}}

" vim-schlepp {{{
" Visual Arrow Keys
vmap <unique> <up>    <Plug>SchleppUp
vmap <unique> <down>  <Plug>SchleppDown
vmap <unique> <left>  <Plug>SchleppLeft
vmap <unique> <right> <Plug>SchleppRight
" }}}


<<<<<<< HEAD
"}}
"
" rainbow {{{
let g:rainbow_active = 1

=======
" NVIMUX {{{
let g:nvimux_prefix='<C-Space>'
let nvimux_open_term_by_default=1
>>>>>>> 4372ebb48ef9193987bc5ed7e43baf2e081a5c2f
" }}}
