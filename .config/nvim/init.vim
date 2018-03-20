" Vivek Menon - mail@vvkmnn.xyz

" ##################################################
" ##################################################
" ######################        ####################
" ################                    ##############
" #############                #######   ###########
" ###########                #########     #########
" #########                 ########         #######
" ########                  ######            ######
" #######                   ######             #####
" ######            ####### ######              ####
" #####           ######### ######               ###
" #####           #######   ######               ###
" #####            ######    #####               ###
" #####             ######    ####               ###
" #####              ######    ###               ###
" ######               ######                   ####
" #######               #####                  #####
" ########               #####                ######
" ##########              #####             ########
" ############             #####          ##########
" ##############               ##       ############
" ##################                ################
" ##################################################
" ##################################################

" Path ---------------------------------------------
" set runtimepath^='~/.config/nvim/dein'
" set packpath^=~/.config/nvim/pack/*/start
let $VIM_PATH = expand('~/.config/nvim')
let $MYVIMRC = expand('~/.config/nvim/init.vim')

" Setup --------------------------------------------
augroup Setup
    autocmd!
    autocmd VimEnter * call packages#deload()
                \ | call packages#setup()
                \ | call packages#install()
augroup END

" Startup ------------------------------------------
augroup Startup
    autocmd!
    autocmd VimEnter * call bindings#leader()
                \ | call bindings#normal()
                \ | call bindings#insert()
                \ | call bindings#visual()
                \ | call bindings#terminal()
augroup END

" Paint --------------------------------------------
augroup Paint
    autocmd!
    autocmd VimEnter * call aesthetic#core()
                \ | call aesthetic#highlights()
augroup END


" Defaults -----------------------------------------
augroup Defaults
    autocmd VimEnter * call defaults#files()
                \ | call defaults#aesthetic()
                \ | call defaults#edit()
                \ | call defaults#search()
                \ | call defaults#indent()
                \ | call defaults#core()
augroup END

" Read ------------------------|BufNewFile, BufRead|
augroup Read
    autocmd!
    autocmd BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line("$") |
                \   execute "normal! g`\"" |
                \ endif " Jump to last known position in buffer
    " autocmd BufEnter * syntax sync fromstart
    " autocmd BufNewFile, BufRead *.md,*.txt
    "             \ call lexical#init()
    " autocmd BufNewFile, BufRead *.ts,*.js,*.json
    "             \ call rainbow_levels#on()
    " autocmd BufWritePost *.vim,*.toml
    "             \ source $MYVIMRC | redraw " Source VIMRC if editing Vim
    " autocmd VimEnter *.js RainbowLevelsOn
    " autocmd BufNewfile, BufRead *.js, *.json, *.ts call rainbow_levels#on()
    " autocmd BufRead call editor#preferences()
augroup END

" Write --------------------------------|BufWrite|
augroup Write
    autocmd!
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif " Close completionw window if no more completions
    autocmd BufWrite * set nohlsearch " Remove Highlting on Write
augroup END

" Format -------------------------------|BufWrite|
augroup Write
    autocmd!
augroup END

" Build ----------------------------|QuickFixCmdPost|
augroup Build
    autocmd!
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost    l* nested lwindow
    autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr())
                \ , "&buftype") == "quickfix"|q
                \ |endif " Close Quickfix if last window
augroup END

" Edit -----------------------------|InsertEnter|
augroup Edit
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

" Completion -----------------------|InsertEnter|
" augroup Complete
"     autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
"                 \ 'name': 'buffer',
"                 \ 'whitelist': ['*'],
"                 \ 'blacklist': ['go'],
"                 \ 'priority': 1,
"                 \ 'completor': function('asyncomplete#sources#buffer#completor'),
"                 \ }))
"
" augroup END

" Resize ---------------------------|InsertEnter|
augroup Resize
    autocmd!
    autocmd VimResized * wincmd =
augroup END

" Save ------------------------------------|BufWrite|
augroup Save
    autocmd!
    " autocmd BufWrite * Autoformat
    " autocmd BufWritePre *
    "             \ try | undojoin
    "             \ | Neoformat
    "             \ | catch /^Vim\%((\a\+)\)\=:E790/
    "                 \ | endtry " Format on Save
augroup END

" Exit -------------------------------------|VimLeave|
augroup Exit
    autocmd!
    " autocmd VimLeave * nested call packages#install()
    " autocmd VimLeave * nested call packages#clean()
augroup END

