if g:dein#_cache_version != 100 | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/Users/v/.config/nvim/init.vim'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/Users/v/.dein'
let g:dein#_runtime_path = '/Users/v/.dein/.cache/init.vim/.dein'
let g:dein#_cache_path = '/Users/v/.dein/.cache/init.vim'
let &runtimepath = '/Users/v/.config/nvim,/etc/xdg/nvim,/Users/v/.local/share/nvim/site,/usr/local/share/nvim/site,/Users/v/.dein/repos/github.com/Shougo/dein.vim,/Users/v/.dein/.cache/init.vim/.dein,/usr/share/nvim/site,/usr/local/Cellar/neovim/0.2.0_1/share/nvim/runtime,/Users/v/.dein/.cache/init.vim/.dein/after,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/Users/v/.local/share/nvim/site/after,/etc/xdg/nvim/after,/Users/v/.config/nvim/after'
filetype off
