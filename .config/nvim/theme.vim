" Theme --------------------------------------------

" True Color support
" set termguicolors
" set t_Co=256

" Enable Syntax Highlighting
syntax enable

" Dracula!
colorscheme dracula

" Background
set background=dark

" No Hihglight Background?
" highlight Normal ctermbg=none
" highlight NonText ctermbg=none
" highlight Normal guibg=none
" highlight NonText guibg=none

" Split Formatting
hi vertsplit ctermfg=238 ctermbg=235
hi vertsplit guifg=238 guibg=235

" Line Numbers
hi LineNr ctermfg=237
hi LineNr guifg=237

" StatusLine
set statusline=%=%P\ %f\ %m
set fillchars=vert:\ ,stl:\ ,stlnc:\
set laststatus=2
set noshowmode

hi StatusLine ctermfg=235 ctermbg=245
hi StatusLineNC ctermfg=235 ctermbg=237
hi StatusLine guifg=235 guibg=245
hi StatusLineNC guifg=235 guibg=237

" Search
hi Search ctermbg=58 ctermfg=15
hi Search guibg=58 guifg=15

" Default
hi Default ctermfg=1
hi Default guifg=1

" Sign Column
hi clear SignColumn
hi SignColumn ctermbg=235
hi SignColumn guibg=235

" Git Gutter
hi GitGutterAdd ctermbg=235 ctermfg=245
hi GitGutterChange ctermbg=235 ctermfg=245
hi GitGutterDelete ctermbg=235 ctermfg=245
hi GitGutterChangeDelete ctermbg=235 ctermfg=245

hi GitGutterAdd guibg=235 guifg=245
hi GitGutterChange guibg=235 guifg=245
hi GitGutterDelete guibg=235 guifg=245
hi GitGutterChangeDelete guibg=235 guifg=245

" End of Buffer
hi EndOfBuffer ctermfg=237 ctermbg=235
hi EndOfBuffer guifg=237 guibg=235

" Sytnax Highlight Limiter
set synmaxcol=200

" Document Length
set tw=79
set nowrap
set fo-=t

" Color Column
" set colorcolumn=80
highlight ColorColumn ctermfg=238 ctermbg=235
highlight ColorColumn guifg=238 guibg=235

" Highlight 81st Column of Wide Lines
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

" Show tabs, trailing whitespace, and non-breaking spaces
exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list
