" Bindings -----------------------------------------

" Keys --
" Space as Leader
let mapleader=" "

" Operators -- 
" Sort in Visual Mode
vnoremap <Leader>s :sort<CR> 

" Escape Neovim Terminal
:tnoremap <Esc> <C-\><C-n>


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
" FZF Completion
imap <c-x><c-l> <plug>(fzf-complete-line)


" This rewires n and N to do the highlighing...
nnoremap <silent> n   n:call HLNext(0.4)<cr>
nnoremap <silent> N   N:call HLNext(0.4)<cr>
