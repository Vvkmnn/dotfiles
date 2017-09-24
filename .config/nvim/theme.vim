" Theme --------------------------------------------

" True Color support
set termguicolors
set t_Co=256

" Enable Syntax
syntax enable

" Dracula!
colorscheme dracula

" Background
set background=dark

" Split Formatting
hi vertsplit ctermfg=238 ctermbg=235
hi LineNr ctermfg=237
hi StatusLine ctermfg=235 ctermbg=245
hi StatusLineNC ctermfg=235 ctermbg=237
hi Search ctermbg=58 ctermfg=15
hi Default ctermfg=1
hi clear SignColumn
hi SignColumn ctermbg=235

" Split Defaults
set wmh=0
set splitright

" Sytnax Highlight Limiter
set synmaxcol=200

" Document Length
set tw=79
set nowrap
set fo-=t

" Color Column
"set colorcolumn=80
"highlight ColorColumn ctermfg=238 ctermbg=235

" Statusline 
set statusline=%=%P\ %f\ %m
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2
set noshowmode

" Git Gutter formatting
hi GitGutterAdd ctermbg=235 ctermfg=245
hi GitGutterChange ctermbg=235 ctermfg=245
hi GitGutterDelete ctermbg=235 ctermfg=245
hi GitGutterChangeDelete ctermbg=235 ctermfg=245
hi EndOfBuffer ctermfg=237 ctermbg=235

" Highlight 81st Column of Wide Lines
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

" Show tabs, trailing whitespace, and non-breaking spaces
exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list


" Swap : ; and for easy command access
nnoremap  ;  :
nnoremap  :  ;

