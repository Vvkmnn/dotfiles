" nstallVivek Menon - mail@vvkmnn.xyz

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

" Runtime Path -------------------------------------
" set runtimepath^='~/.config/nvim/dein'
" set packpath^=~/.config/nvim/pack/*/start

" Startup ------------------------------------------
augroup Startup
    autocmd!
    autocmd VimEnter * nested
                \ call packages#deload()
                \ | call packages#setup()
                \ | call packages#install()
                \ | call defaults#settings()
                \ | call aesthetic#highlights()
                \ | call rainbow_parentheses#toggle()
augroup END

" Read ------------------------|BufNewFile, BufRead|
augroup Read
    autocmd!
    autocmd VimEnter *
                \ call bindings#leader()
                \ | call bindings#normal()
                \ | call bindings#insert()
                \ | call bindings#visual()
                \ | call bindings#terminal()
    autocmd BufNewFile, BufRead *.md,*.txt
                \ call lexical#init()
    autocmd BufNewFile, BufRead *.ts,*.js,*.json
                \ call rainbow_levels#on()
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
    " autocmd QuickFixCmdPost [^l]* nested cwindow
    " autocmd QuickFixCmdPost    l* nested lwindow
augroup END

" Resize ---------------------------|InsertEnter|
augroup Resize
    autocmd!
    autocmd VimResized * wincmd =
augroup END

" Save ------------------------------------|BufWrite|
augroup Save
    autocmd!
    autocmd BufWritePre *
                \ try | undojoin
                \ | Neoformat
                \ | catch /^Vim\%((\a\+)\)\=:E790/
                    \ | endtry " Format on Save
augroup END

" Exit -------------------------------------|VimLeave|
augroup Exit
    autocmd!
    " autocmd VimLeave * call packages#update()
    autocmd VimLeave * nested
                \ call packages#clean()
augroup END
