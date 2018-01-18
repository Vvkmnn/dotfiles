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

" Startup --------------------------------|VimEnter|
augroup startup
    autocmd!

    " Packages {{{
    autocmd VimEnter * call dein#load_state('~/.dein')
    " }}}

    " Aesthetic {{{
    autocmd VimEnter * call aesthetic#Settings()
    autocmd VimEnter * call aesthetic#Highlights()
    " }}}
augroup END


" Read -------------------------------------|BufRead|

" ugroup filetype_ruby
"     autocmd!
"     autocmd FileType ruby nnoremap <buffer> <localleader>t :!rake test
" augroup END
" 
" augroup filetype_erlang
"     autocmd!
"     autocmd FileType erlang nnoremap <buffer> <localleader>t :!rebar eunit
" augroup END
"
" Write -----------------------------------|BufWrite|

" Exit -------------------------------------|VimLeave|

augroup leave
	autocmd!
	autocmd VimLeave * call if dein#check_install()
				\ call dein#install()
				\ endif
augroup END
