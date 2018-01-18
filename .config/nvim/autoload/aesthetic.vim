" Theme --------------------------------------------

function! aesthetic#settings() abort
	echom "[._.] Loading aesthetic settings..."
	colorscheme dracula 		         " Dracula!
endfunction

function! aesthetic#highlights() abort
	echom "[._.] Loading aesthetic highlights..."
	
	" Split Formatting
	highlight vertsplit ctermfg=238 ctermbg=235
	highlight vertsplit guifg=238 guibg=235
	
	" Line Numbers
	highlight LineNr ctermfg=237
	highlight LineNr guifg=237
	
	" StatusLine
	" set statusline=%=%P\ %f\ %m
	" set fillchars=vert:\ ,stl:\ ,stlnc:\
	set laststatus=2
	set noshowmode
	
	highlight StatusLine ctermfg=235 ctermbg=245
	highlight StatusLineNC ctermfg=235 ctermbg=237
	highlight StatusLine guifg=235 guibg=245
	highlight StatusLineNC guifg=235 guibg=237
	
	" Search
	highlight Search ctermbg=58 ctermfg=15
	highlight Search guibg=58 guifg=15
	
	" Default
	highlight Default ctermfg=1
	highlight Default guifg=1
	
	" Sign Column
	highlight clear SignColumn
	highlight SignColumn ctermbg=235
	highlight SignColumn guibg=235
	
	" Git Gutter
	highlight GitGutterAdd ctermbg=235 ctermfg=245
	highlight GitGutterChange ctermbg=235 ctermfg=245
	highlight GitGutterDelete ctermbg=235 ctermfg=245
	highlight GitGutterChangeDelete ctermbg=235 ctermfg=245
	
	highlight GitGutterAdd guibg=235 guifg=245
	highlight GitGutterChange guibg=235 guifg=245
	highlight GitGutterDelete guibg=235 guifg=245
	highlight GitGutterChangeDelete guibg=235 guifg=245
	
	" End of Buffer
	highlight EndOfBuffer ctermfg=237 ctermbg=235
	highlight EndOfBuffer guifg=237 guibg=235
	
	" Color Column
	" set colorcolumn=80
	highlight ColorColumn ctermfg=238 ctermbg=235
	highlight ColorColumn guifg=238 guibg=235
	
	" Highlight 81st Column of Wide Lines
	highlight ColorColumn ctermbg=magenta
	call matchadd('ColorColumn', '\%81v', 100)

endfunction

" augroup Aesthetic
"     autocmd!
"     autocmd ColorScheme * call aestheticHighlights()
"     autocmd ColorScheme * call aestheticSettings()
" augroup EN""D
