" Bindings -----------------------------------------

function! bindings#leader() abort
    echom "[._.] Loading Leader bindings..."
    " Space as Leader
    let mapleader=" "

    " <;> as Buffer
    " nnoremap ; :Buffers<CR>
    " nnoremap <Leader>t :Files<CR>
    " nnoremap <Leader>r :Tags<CR>
endfunction

function! bindings#normal() abort
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


function! bindings#visual() abort
    echom "[._.] Loading Visual mode bindings..."

    " Sort in Visual Mode
    vnoremap <Leader>s :sort<CR> 
endfunction

function! bindings#terminal() abort
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

" Search Dash via < <leader>d{motion} >
nnoremap <silent> <leader>d <Plug>DashSearch

function! bindings#plugin() abort
    echom "[._.] Loading Plugin bindings..."

    " vim-easy-align {{{
    " Start interactive EasyAlign in visual mode (e.g. vipga) with <ga>
    xnoremap ga <Plug>(EasyAlign)

    " Start interactive EasyAlign for a motion/text object (e.g. <ga{motion}>)
    nnoremap ga <Plug>(EasyAlign)
    " }}}
endfunction
