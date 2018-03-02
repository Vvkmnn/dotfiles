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

" Startup ------------------------------------------
augroup Startup
    autocmd!
    autocmd VimEnter * call packages#deload()
    \ | call packages#setup()
    \ | call packages#install()
augroup END

" Setup --------------------------------------------
augroup Setup
    autocmd!
    autocmd VimEnter * call bindings#leader()
                \ | call bindings#normal()
                \ | call bindings#insert()
                \ | call bindings#visual()
                \ | call bindings#terminal()
    autocmd VimEnter * call aesthetic#core()
                \ | call aesthetic#highlights()
    autocmd VimEnter * call defaults#core()
                \ | call defaults#aesthetic()
                \ | call defaults#edit()
                \ | call defaults#search()
                \ | call defaults#indent()
                \ | call defaults#files()
augroup END

" Read ------------------------|BufNewFile, BufRead|
augroup Read
    autocmd!
    autocmd BufNewFile, BufRead *
                \ call rainbow_parentheses#toggle()
    autocmd BufNewFile, BufRead *.md,*.txt
                \ call lexical#init()
    autocmd BufNewFile, BufRead *.ts,*.js,*.json
                \ call rainbow_levels#on()
    autocmd BufWritePost *.vim,*.toml 
                \ source $MYVIMRC | redraw " Source VIMRC if editing Vim
  " autocmd VimEnter *.js RainbowLevelsOn
  " autocmd BufNewfile, BufRead *.js, *.json, *.ts call rainbow_levels#on()
  " autocmd BufRead call editor#preferences()
augroup END

" Write --------------------------------|BufWrite|
augroup Write
    autocmd!
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif
    autocmd BufWrite * set nohlsearch " Remove Highlting on Write
    " autocmd FileType markdown,mkd,textile,text * nested
    "             \ call lexical#init()
augroup END

" Build ----------------------------|QuickFixCmdPost|
augroup Build
    " autocmd QuickFixCmdPost [^l]* nested cwindow
    " autocmd QuickFixCmdPost    l* nested lwindow
    " autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr())
    "             \ , "&buftype") == "quickfix"|q
    "             \ |endif " Close Quickfix if last window
augroup END

" Edit -----------------------------|InsertEnter|
augroup Edit
    autocmd!
    au VimEnter,WinEnter,BufWinEnter *
                \ setlocal cursorline
    au WinLeave *
                \ setlocal nocursorline
augroup END

" Resize ---------------------------|InsertEnter|
augroup Resize
    autocmd!
    autocmd VimResized * wincmd =
augroup END

" Save ------------------------------------|BufWrite|
augroup Save
    autocmd!
    " autocmd BufWritePre *
    "             \ try | undojoin
    "             \ | Neoformat
    "             \ | catch /^Vim\%((\a\+)\)\=:E790/
    "                 \ | endtry " Format on Save
augroup END

" Exit -------------------------------------|VimLeave|
augroup Exit
    autocmd!
    autocmd VimLeave * nested call packages#install()
    autocmd VimLeave * nested call packages#clean()
augroup END

