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



" Plugins ------------------------------------------

" Fzf --
"   In Neovim, you can set up fzf window using a Vim command

"   Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Dirvish {{
"   Interact with Fugitive forGstatus
autocmd FileType dirvish call fugitive#detect(@%)
" }}

" Ale {{

" Lint Gutter Alwaus open
let g:ale_sign_column_always = 1

" Airline Integration
let g:airline#extensions#ale#enabled = 1

" }} 
