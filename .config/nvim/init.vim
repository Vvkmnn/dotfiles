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

" Runtime Path -------------------------------------
" set runtimepath^='~/.config/nvim/dein'
" set packpath^=~/.config/nvim/pack/*/start

" Startup ------------------------------------------
augroup Startup
    autocmd!
    autocmd VimEnter * call packages#deload()
    autocmd VimEnter * call packages#setup()
    autocmd VimEnter * call packages#check()
    autocmd VimEnter * call defaults#settings()
    autocmd VimEnter * call aesthetic#settings()
    autocmd VimEnter * call aesthetic#highlights()
    autocmd VimEnter * call bindings#leader()
    autocmd VimEnter * call bindings#normal()
    autocmd VimEnter * call bindings#insert()
    autocmd VimEnter * call bindings#visual()
    autocmd VimEnter * call bindings#terminal()
augroup END

" New  ---------------------------------|BufNewFile|
augroup New
    autocmd!
    " autocmd BufNewFile *.py Template *.py
    " autocmd BufNewFile call editor#preferences()
    " autocmd BufNewFile *.py
    " autocmd VimEnter * call packages#setup()
augroup END

" Read ------------------------------------|BufRead|
augroup Read
    autocmd!
    autocmd VimEnter *.ts,*.js,*.json
                \ RainbowLevelsOn
    " autocmd VimEnter *.js RainbowLevelsOn
    " autocmd BufNewfile, BufRead *.js, *.json, *.ts call rainbow_levels#on()
    " autocmd BufRead call editor#preferences()
    " autocmd FileType markdown,mkd call lexical#init()
    " autocmd FileType markdown,mkd call lexical#init()
    " autocmd FileType textile call lexical#init()
    " autocmd FileType text call lexical#init({ 'spell': 0 })
augroup END

" Build ----------------------------|QuickFixCmdPost|
augroup Build
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost    l* nested lwindow
    autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr())
                \ , "&buftype") == "quickfix"|q
                \ |endif " Close Quickfix if last window
augroup END

" Edit -----------------------------|InsertEnter|
augroup Edit
    " autocmd QuickFixCmdPost [^l]* nested cwindow
    " autocmd QuickFixCmdPost    l* nested lwindow
augroup END

" Save ------------------------------------|BufWrite|
augroup Save
    autocmd!
    " autocmd BufWritePre * try | undojoin | Neoformat
    "             \ | catch /^Vim\%((\a\+)\)\=:E790/
    "                 \ | finally | silent Neoformat
    "                     \ | endtry " Format on Save
augroup END

" Exit -------------------------------------|VimLeave|
augroup Exit
    autocmd VimLeave * nested call packages#check()
augroup END
