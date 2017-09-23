" Plugins ------------------------------------------

" Setup
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('~/.dein')
  call dein#begin('~/.dein')


  " Dein {{{ Package Manager }}}
  call dein#add('~/.dein/repos/github.com/Shougo/dein.vim')

  " Dracula {{{ Colorscheme }}}
  call dein#add('dracula/vim')

  " Save
  call dein#end()
  call dein#save_state()
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

