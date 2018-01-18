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




" Startup ------------------------------------------
augroup Startup
    autocmd!
    autocmd VimEnter * call packages#setup()    " Packages
    autocmd VimEnter * call defaults#settings() " Settings
    autocmd VimEnter * call defaults#bindings() " Bindings
    autocmd VimEnter * call aesthetic#settings()   " Theme
    autocmd VimEnter * call aesthetic#highlights() " Highlights
augroup END

" Read -------------------------------------|BufRead|
augroup Read
    autocmd!
    " autocmd FileType * nested call editor#preferences()
    " autocmd FileType markdown,mkd call lexical#init()
    " autocmd FileType textile call lexical#init()
    " autocmd FileType text call lexical#init({ 'spell': 0 })
augroup END

" Write -----------------------------------|BufWrite|
" augroup Write
"     autocmd!
"     autocmd BufWritePre * try                      " Format on Save
"                 \ | packadd Neoformat 
"                 \ | undojoin | Neoformat 
"                 \ | catch /^Vim\%((\a\+)\)\=:E790/ 
"                 \ | finally | silent Neoformat 
"                 \ | endtry
" augroup END

" Exit -------------------------------------|VimLeave|
augroup Exit
    " autocmd VimLeave * nested call packages#maintan()
augroup END
