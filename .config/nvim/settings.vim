" Bindings -----------------------------------------

" FZF {{
"   Completion
" imap <c-x><c-l> <plug>(fzf-complete-line)
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


" vim-autoformat {{{
" Autoformat on Save
au BufWrite * :Autoformat

" But don't replace mismatches with tabs
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

"}}
"
" rainbow {{{
let g:rainbow_active = 1

" }}}
