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
" #####               ######    #                ###
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
" set runtimepath^=~/.config/nvim
" set packpath^=~/.config/nvim/pack/*/start

" Startup ------------------------------------------
augroup Startup
    autocmd!
    autocmd VimEnter * call defaults#settings()
    autocmd VimEnter * call packages#setup()
    autocmd VimEnter * call aesthetic#settings()
    autocmd VimEnter * call aesthetic#highlights()
    autocmd VimEnter * call bindings#leader()
    autocmd VimEnter * call bindings#normal()
    autocmd VimEnter * call bindings#visual()
    autocmd VimEnter * call bindings#terminal()
augroup END

" Read -------------------------------------|BufRead|
augroup Read
    autocmd!
    autocmd BufNewFile,BufRead call editor#preferences()
    " autocmd FileType markdown,mkd call lexical#init()
    " autocmd FileType markdown,mkd call lexical#init()
    " autocmd FileType textile call lexical#init()
    " autocmd FileType text call lexical#init({ 'spell': 0 })
augroup END

" Make -----------------------------|QuickFixCmdPost|
augroup Quickfix
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost    l* nested lwindow
augroup END

" Write -----------------------------------|BufWrite|
augroup Write
    autocmd!
    " autocmd BufWritePre * try | undojoin | Neoformat " Format on Save
augroup END

" Exit -------------------------------------|VimLeave|
augroup Exit
    autocmd VimLeave * call packages#check()
augroup END
