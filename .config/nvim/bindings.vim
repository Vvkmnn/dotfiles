" Bindings -----------------------------------------

" Keys --
" Space as Leader
let mapleader=" "

" Disable arrow movement, resize splits instead.
nnoremap <Up>    :resize +2<CR>
nnoremap <Down>  :resize -2<CR>
nnoremap <Left>  :vertical resize +2<CR>
nnoremap <Right> :vertical resize -2<CR>

" Swap : ; in Normal Mode and for easy command access
" nnoremap  :  ;

" Operators -- 
" Sort in Visual Mode
vnoremap <Leader>s :sort<CR> 

" Escape Neovim Terminal
:tnoremap <Esc> <C-\><C-n>

" This rewires n and N to do the highlighing
nnoremap <silent> n   n:call HLNext(0.4)<cr>
nnoremap <silent> N   N:call HLNext(0.4)<cr>


" Windows --
" Ctrl Arrow Buffer Navigation
nnoremap <silent> <C-Right> <c-w>l
nnoremap <silent> <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j

" Ctrl HJKL Split Navigation
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" Plugins --

" FZF -- 
"   Completion
imap <c-x><c-l> <plug>(fzf-complete-line)

" Dash -- 
"   with Leader + d for word under cursor
:nmap <silent> <leader>d <Plug>DashSearch

" Vim Move -- 
"   Use escape key instead of Alt (which doesn't work on macOS
"   http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim " for he <F20> hack. 
"    Needs iTerm2 set to Esc+ in Profile > Keys
set <F20>=j
set <F21>=k
vmap <F20> <Plug>MoveBlockDown
vmap <F21> <Plug>MoveBlockUp
nmap <F20> <Plug>MoveLineDown
nmap <F21> <Plug>MoveLineUp

" Plugins ------------------------------------------

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



