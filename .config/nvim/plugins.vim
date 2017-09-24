" Plugins ------------------------------------------

" Setup
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('~/.dein')
  call dein#begin('~/.dein')


  " Dein -- A Dark  Package Manager 
  call dein#add('~/.dein/repos/github.com/Shougo/dein.vim')

  " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
  call dein#add('christoomey/vim-tmux-navigator')

  " Dracula - A Dark Colorscheme
  call dein#add('dracula/vim')

  " Dash - A Plugin to search Dash <Dash:>
  call dein#add('rizzatti/dash.vim')

  " Vim-Move - Alt-kj for moving lines up and down
  call dein#add('matze/vim-move')

  " Save
  call dein#end()
  call dein#save_state()
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

