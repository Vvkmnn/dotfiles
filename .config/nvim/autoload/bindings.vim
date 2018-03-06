" Bindings -----------------------------------------

function! bindings#leader() abort
    echom "[._.] Loading Leader bindings..."
    " let mapleader="\Space"
    " let mapleader=" "

    " Leader split navigation
    " map <leader>h :wincmd h<CR>
    " map <leader>j :wincmd j<CR>
    " map <leader>k :wincmd k<CR>
    " map <leader>l :wincmd l<CR>

    " <;> as Buffer
    " nnoremap ; :Buffers<CR>
    " nnoremap <Leader>t :Files<CR>
    " nnoremap <Leader>r :Tags<CR>


    nnoremap <leader>q <Plug>qf_qf_toggle
    " Leader<z> to search for character under cursor
    nnoremap <leader>z xhp/<C-R>-<CR>
endfunction

function! bindings#normal() abort
    echom "[._.] Loading Normal mode bindings..."

    " Hardmode!
    " noremap h <NOP>
    " noremap j <NOP>
    " noremap k <NOP>
    " noremap l <NOP>

    " Remap Space to <Nop>?
    nnoremap <Space> <Nop>

    " Disable arrow movement, resize splits instead.
    " nnoremap <Up>    :resize +2<CR>
    " nnoremap <Down>  :resize -2<CR>
    nnoremap <Left>  :vertical resize +2<CR>
    nnoremap <Right> :vertical resize -2<CR>

    " Normal mode split navigation
    nnoremap <C-h> <c-w>h
    nnoremap <C-j> <c-w>j
    nnoremap <C-k> <c-w>k
    nnoremap <C-l> <c-w>l

    " Ctrl Arrow Buffer Navigation
    " nnoremap <silent> <C-Right> <c-w>l
    " nnoremap <silent> <C-Left> <c-w>h
    " nnoremap <silent> <C-Up> <c-w>k
    " nnoremap <silent> <C-Down> <c-w>j

    " <C-hjkl> Split Navigation
    " nnoremap <C-J> <C-W><C-J>
    " nnoremap <C-K> <C-W><C-K>
    " nnoremap <C-L> <C-W><C-L>
    " nnoremap <C-H> <C-W><C-H>

    " Highlight Next rewires n and N to do the highlighing
    " nnoremap <silent> n   n:call functions#HLNext(0.4)<cr>
    " nnoremap <silent> N   N:call functions#HLNext(0.4)<cr>

endfunction

function bindings#insert() abort
    echom "[._.] Loading Insert mode bindings..."

    " Insert mode:split navigation
    inoremap <C-h> <Esc><c-w>h
    inoremap <C-j> <Esc><c-w>j
    inoremap <C-k> <Esc><c-w>k
    inoremap <C-l> <Esc><c-w>l
endfunction

function! bindings#visual() abort
    echom "[._.] Loading Visual mode bindings..."

    " Sort in Visual Mode
    vnoremap <Leader>s :sort<CR>

    " Visual mode split navigation
    vnoremap <C-h> <Esc><c-w>h
    vnoremap <C-j> <Esc><c-w>j
    vnoremap <C-k> <Esc><c-w>k
    vnoremap <C-l> <Esc><c-w>l
endfunction

function! bindings#terminal() abort
    echom "[._.] Loading Terminal mode bindings..."

    " Terminal mode:
    tnoremap <C-h> <c-\><c-n><c-w>h
    tnoremap <C-j> <c-\><c-n><c-w>j
    tnoremap <C-k> <c-\><c-n><c-w>k
    tnoremap <C-l> <c-\><c-n><c-w>l

    " Esc to leave Terminal Mode
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-v><Esc> <Esc>
endfunction

" command Bindings call bindings#leader() | \ call bindings#normal()
