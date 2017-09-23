" Plugins ------------------------------------------

" Setup
set runtimepath+=/Users/v/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('/Users/v/.dein')
  call dein#begin('/Users/v/.dein')


  " Dein {{{
  call dein#add('/Users/v/.dein/repos/github.com/Shougo/dein.vim')

  " Save
  call dein#end()
  call dein#save_state()
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

