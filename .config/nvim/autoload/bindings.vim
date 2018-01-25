" Bindings -----------------------------------------

function! bindings#leader()
    echom "[._.] Loading Leader bindings..."
    " Space as Leader
    " let mapleader=" "

    " <;> as Buffer
    " nnoremap ; :Buffers<CR>
    " nnoremap <Leader>t :Files<CR>
    " nnoremap <Leader>r :Tags<CR>
endfunction

function! bindings#normal()
    echom "[._.] Loading Normal mode bindings..."

    " Disable arrow movement, resize splits instead.
    nnoremap <Up>    :resize +2<CR>
    nnoremap <Down>  :resize -2<CR>
    nnoremap <Left>  :vertical resize +2<CR>
    nnoremap <Right> :vertical resize -2<CR>
    
    " Split Navigation using Control
    nnoremap <C-h> <c-w>h
    nnoremap <C-j> <c-w>j
    nnoremap <C-k> <c-w>k
    nnoremap <C-l> <c-w>l


    " Ctrl Arrow Buffer Navigation
    " nnoremap <silent> <C-Right> <c-w>l
    " nnoremap <silent> <C-Left> <c-w>h
    " nnoremap <silent> <C-Up> <c-w>k
    " nnoremap <silent> <C-Down> <c-w>j

    " <Ctrl-hjkl> Split Navigation
    " nnoremap <C-J> <C-W><C-J>
    " nnoremap <C-K> <C-W><C-K>
    " nnoremap <C-L> <C-W><C-L>
    " nnoremap <C-H> <C-W><C-H>

    " Highlight Next rewires n and N to do the highlighing
    nnoremap <silent> n   n:call functions#HLNext(0.4)<cr>
    nnoremap <silent> N   N:call functions#HLNext(0.4)<cr>
endfunction


function! bindings#visual()
    echom "[._.] Loading Visual mode bindings..."

    " Sort in Visual Mode
    vnoremap <Leader>s :sort<CR> 
endfunction

function! bindings#terminal()
    echom "[._.] Loading Terminal mode bindings..."

    " Esc to leave Terminal Mode
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-v><Esc> <Esc>

    " Terminal Split Navigation using Meta
    tnoremap <C-h> <c-\><c-n><c-w>h
    tnoremap <C-j> <c-\><c-n><c-w>j
    tnoremap <C-k> <c-\><c-n><c-w>k
    tnoremap <C-l> <c-\><c-n><c-w>l

endfunction

