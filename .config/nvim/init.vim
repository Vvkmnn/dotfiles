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
    autocmd VimEnter * nested call packages#deload()
    autocmd VimEnter * nested call packages#setup()
    autocmd VimEnter * nested call packages#install()
    autocmd VimEnter * nested call defaults#settings()
    autocmd VimEnter * nested call aesthetic#highlights()
    autocmd VimEnter * nested call bindings#leader()
    autocmd VimEnter * nested call bindings#normal()
    autocmd VimEnter * nested call bindings#insert()
    autocmd VimEnter * nested call bindings#visual()
    autocmd VimEnter * nested call bindings#terminal()
augroup END

" Read ------------------------|BufNewFile, BufRead|
augroup Read
    autocmd!
    autocmd BufNewFile, BufRead *
                \ | call rainbow_parentheses#toggle()
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
    " autocmd VimLeave * call packages#update()
    " autocmd VimLeave * nested call packages#clean()
augroup END

