" Plugins ------------------------------------------

" Required
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

" Start
if dein#load_state('~/.dein')
  call dein#begin('~/.dein')

  " Dein -- A Dark  Package Manager 
  call dein#add('Shougo/dein.vim')

  " Tmux Navigator --  Native Ctrl-HJKL Navigation in Tmux & Vim
  " call dein#add('christoomey/vim-tmux-navigator')

  " vim-autoswap -- No swap messages; just switch or recover
  call dein#add('gioele/vim-autoswap')

  " FZF - Fuzzy File Finder!
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

  " Dracula - A Dark Colorscheme
  call dein#add('dracula/vim')

  " vim-polyglot - language packs for Vim
  call dein#add('sheerun/vim-polyglot')

  " vim-neoformat -- Script formatting
  call dein#add('sbdchd/neoformat')

  " Dash - A Plugin to search Dash <Dash:>
  call dein#add('rizzatti/dash.vim')
  
  " echodoc.vim - Displays docs in the function area
  call dein#add('Shougo/echodoc.vim')

  " vim-gitgutter -- Git status next to line numbers
  call dein#add('airblade/vim-gitgutter')

  " Vim Dirvish -- Inline Vim File Navigation
  call dein#add('justinmk/vim-dirvish')

  " Vim Eunech -- Unix helpers via <:Delete>, <:Move>, ..
  call dein#add('tpope/vim-eunuch')

  " NERDTree -- Tree File System Explorer
  " call dein#add('scrooloose/nerdtree')

  " Fugitive - Git management for Vim
  call dein#add('tpope/vim-fugitive')

  " vim-move - Alt-kj for moving lines up and down
  call dein#add('matze/vim-move')

  " vim-schlepp - Allow the movement of lines (or blocks) of text around easily
  call dein#add('zirrostig/vim-schlepp')

  " neoterm -- one terminal for everything!
  call dein#add('kassio/neoterm')

  " iron.vim -- Interactive Repls Over Neovim
  " call dein#add('hkupty/iron.nvim')

  " NVIMUX -- mimic tmux on neovim
  call dein#add('hkupty/nvimux')

  " WindowSwap.vim -- Swap any windows with <leader>ww
  call dein#add('wesQ3/vim-windowswap')

  " ultisnips - Vim Snippet Framework
  call dein#add('SirVer/ultisnips')

  " vim-snippets - snipMate & UltiSnip Snippets
  call dein#add('honza/vim-snippets')

  " Ale - Asynchrous Linting Engine
  call dein#add('w0rp/ale')

  " Rainbow Parentheses Improved - Color code by depth
  call dein#add('luochen1990/rainbow')

if has('gui_running')

  " Supertab - Use <Tab> for all your insert completion needs
  " call dein#add('ervandew/supertab')

  " Gutentags - The Vim .tags manager
  call dein#add('ludovicchabant/vim-gutentags')

  " Deoplete - dark powered neo-completion
  call dein#add('Shougo/deoplete.nvim')

  " Neomake - Asynchronously run Programs <:Neomake>
  " call dein#add('neomake/neomake')

  " LanguageClient-neovim - Language Server Protocol support for neovim.
  call dein#add('autozimu/LanguageClient-neovim')

  " Tagbar - a class outline viewer for Vim
  call dein#add('majutsushi/tagbar')
  " VimDevIcons -- Icons in Vim
   " call dein#add('ryanoasis/vim-devicons')
endif

  " Save
  call dein#end()
  call dein#save_state()
endif

" Startup
" Check installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

