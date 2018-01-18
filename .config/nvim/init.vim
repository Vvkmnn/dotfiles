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


"

" Startup ------------------------------------------
augroup startup
    autocmd!

    " Settings {{{
    autocmd VimEnter * call defaults#settings()
    " }}}
    
    " Packages {{{
    autocmd VimEnter call minpac#update()
    autocmd VimLeave call packages#setup()
    autocmd VimLeave call minpac#clean()
    " }}}

    autocmd VimEnter * call aesthetic#settings()
    " autocmd VimEnter call aesthetic#highlights()
    " }}}

augroup END


" Read -------------------------------------|BufRead|

" Write -----------------------------------|BufWrite|

" Exit -------------------------------------|VimLeave|
"
