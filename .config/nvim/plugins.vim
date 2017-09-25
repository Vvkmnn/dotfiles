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

  " FZF - Fuzzy File Finder!
  call dein#add('junegunn/fzf', { 'build': './install ~/.fzf', 'rtp': '' })
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

  " Dracula - A Dark Colorscheme
  call dein#add('dracula/vim')

  " Dash - A Plugin to search Dash <Dash:>
  call dein#add('rizzatti/dash.vim')

  " Fugitive -- Git management from Vim
  call dein#add('tpope/vim-fugitive')

  " vim-gitgutter -- Git status next to line numbers
  call dein#add('airblade/vim-gitgutter')

  " denite.vim - A more generic FZF?
  " call dein#add('Shougo/denite.nvim')

  " Vim Dirvish -- Inline Vim File Navigation
  call dein#add('justinmk/vim-dirvish')

  " Vim Eunech -- Unix helpers via <:Delete>, <:Move>, ..
  call dein#add('tpope/vim-eunuch')

  " NERDTree -- Tree File System Explorer
  " call dein#add('scrooloose/nerdtree')

  " Vim-Move - Alt-kj for moving lines up and down
  call dein#add('matze/vim-move')

  " WindowSwap.vim -- Swap any windows with <leader>ww
  call dein#add('wesQ3/vim-windowswap')

  " VimDevIcons -- Icons in Vim
   call dein#add('ryanoasis/vim-devicons')

  " Save
  call dein#end()
  call dein#save_state()
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

