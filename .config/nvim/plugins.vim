" Plugins ------------------------------------------

" Required
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('~/.dein')
  call dein#begin('~/.dein')

  " Dein -- A Dark  Package Manager 
  call dein#add('Shougo/dein.vim')

  " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
  call dein#add('christoomey/vim-tmux-navigator')

  " FZF - Fuzzy File Finder!
  call dein#add('junegunn/fzf', { 'build': './install ~/.fzf', 'rtp': '' })
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

  " Airline - Statusline for Vim
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')

  " Dracula - A Dark Colorscheme
  call dein#add('dracula/vim')

  " Dash - A Plugin to search Dash <Dash:>
  call dein#add('rizzatti/dash.vim')

  " split-term.vim - A terminal manager <Term:, Vterm:>
  call dein#add('mklabs/split-term.vim')

  " Fugitive -- Git management from Vim
  call dein#add('tpope/vim-fugitive')

  " vim-autoformat -- Script formatting
  call dein#add('Chiel92/vim-autoformat')

  " Ale - Asynchrous Linting Engine
  call dein#add('w0rp/ale')
  
  " Supertab - Use <Tab> for all your insert completion needs
  call dein#add('ervandew/supertab')

  " completer.vim - Asynchronous Completion Framework 
  call dein#add('maralla/completor.vim')

  " ultisnips - Vim Snippet Framework
  call dein#add('SirVer/ultisnips')

  " vim-snippets - snipMate & UltiSnip Snippets
  call dein#add('honza/vim-snippets')

  " }}}
  " async.vim - Async dependency for Neovim and Vim8
  " call dein#add('prabirshrestha/async.vim')

  " asynccomplete.vim - Asynchronous Completion Engine
  " call dein#add('prabirshrestha/asyncomplete.vim')

  " Omni, Tag, and Buffer Completion
  " call dein#add('yami-beta/asyncomplete-omni.vim')
  " call dein#add('prabirshrestha/asyncomplete-tags.vim')
  " call dein#add('prabirshrestha/asyncomplete-buffer.vim')

  " LSP - the Language Server Protocol
  " call dein#add('prabirshrestha/vim-lsp')
  " call dein#add('prabirshrestha/asyncomplete-lsp.vim')

  " Gutentags - Asychronously generates ctags 
  call dein#add('ludovicchabant/vim-gutentags')

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
   " call dein#add('ryanoasis/vim-devicons')

  " Save
  call dein#end()
  call dein#save_state()
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

