" Functions

" Use Tab for NeoSnippet Expansion / Completion
" If we are inside a completion menu jump to the next item. 
" Else check if there is any snippet to expand, if yes expand it. 
" Also if inside a snippet and we need to jump tab jumps. If none
" of the above matches we just call our usual 'tab'.

function! NeoSnippetComplete() abort
  if pumvisible()
    return "\<c-n>"
  else
    if neosnippet#expandable_or_jumpable() 
      return "\<Plug>(neosnippet_expand_or_jump)"
    endif
    return "\<tab>"
  endif
endfunction


" Highlight Line on Big Cursor Move
function! HighlightLine() abort
    let cur_pos = winline()
    if g:last_pos == 0
        set cul
        let g:last_pos = cur_pos
        return
    endif
    let diff = g:last_pos - cur_pos
    if diff > 1 || diff < -1
        set cul
    else
        set nocul
    endif
    let g:last_pos = cur_pos
endfunction

" Toggle Search HIghlighting
function! ToggleHlBack() abort
    if &hlsearch == 'nohlsearch'
        set hlsearch
    endif
endfunction

" ColorScheme
function ShowColourSchemeName() abort
    try
        echo g:colors_name
    catch /^Vim:E121/
        echo "default
    endtry
endfunction

" AuGroup
command! LogAutocmds call s:log_autocmds_toggle()

function! s:log_autocmds_toggle()
    augroup LogAutocmd
        autocmd!
    augroup END

    let l:date = strftime('%F', localtime())
    let s:activate = get(s:, 'activate', 0) ? 0 : 1
    if !s:activate
        call s:log('Stopped autocmd log (' . l:date . ')')
        return
    endif

    call s:log('Started autocmd log (' . l:date . ')')
    augroup LogAutocmd
        for l:au in s:aulist
            silent execute 'autocmd' l:au '* call s:log(''' . l:au . ''')'
        endfor
    augroup END
endfunction

function! s:log(message)
    silent execute '!echo "'
                \ . strftime('%T', localtime()) . ' - ' . a:message . '"'
                \ '>> /tmp/vim_log_autocommands'
endfunction

" These are deliberately left out due to side effects
" - SourceCmd
" - FileAppendCmd
" - FileWriteCmd
" - BufWriteCmd
" - FileReadCmd
" - BufReadCmd
" - FuncUndefined

let s:aulist = [
            \ 'BufNewFile',
            \ 'BufReadPre',
            \ 'BufRead',
            \ 'BufReadPost',
            \ 'FileReadPre',
            \ 'FileReadPost',
            \ 'FilterReadPre',
            \ 'FilterReadPost',
            \ 'StdinReadPre',
            \ 'StdinReadPost',
            \ 'BufWrite',
            \ 'BufWritePre',
            \ 'BufWritePost',
            \ 'FileWritePre',
            \ 'FileWritePost',
            \ 'FileAppendPre',
            \ 'FileAppendPost',
            \ 'FilterWritePre',
            \ 'FilterWritePost',
            \ 'BufAdd',
            \ 'BufCreate',
            \ 'BufDelete',
            \ 'BufWipeout',
            \ 'BufFilePre',
            \ 'BufFilePost',
            \ 'BufEnter',
            \ 'BufLeave',
            \ 'BufWinEnter',
            \ 'BufWinLeave',
            \ 'BufUnload',
            \ 'BufHidden',
            \ 'BufNew',
            \ 'SwapExists',
            \ 'FileType',
            \ 'Syntax',
            \ 'EncodingChanged',
            \ 'TermChanged',
            \ 'VimEnter',
            \ 'GUIEnter',
            \ 'GUIFailed',
            \ 'TermResponse',
            \ 'QuitPre',
            \ 'VimLeavePre',
            \ 'VimLeave',
            \ 'FileChangedShell',
            \ 'FileChangedShellPost',
            \ 'FileChangedRO',
            \ 'ShellCmdPost',
            \ 'ShellFilterPost',
            \ 'CmdUndefined',
            \ 'SpellFileMissing',
            \ 'SourcePre',
            \ 'VimResized',
            \ 'FocusGained',
            \ 'FocusLost',
            \ 'CursorHold',
            \ 'CursorHoldI',
            \ 'CursorMoved',
            \ 'CursorMovedI',
            \ 'WinEnter',
            \ 'WinLeave',
            \ 'TabEnter',
            \ 'TabLeave',
            \ 'CmdwinEnter',
            \ 'CmdwinLeave',
            \ 'InsertEnter',
            \ 'InsertChange',
            \ 'InsertLeave',
            \ 'InsertCharPre',
            \ 'TextChanged',
            \ 'TextChangedI',
            \ 'ColorScheme',
            \ 'RemoteReply',
            \ 'QuickFixCmdPre',
            \ 'QuickFixCmdPost',
            \ 'SessionLoadPost',
            \ 'MenuPopup',
            \ 'CompleteDone',
            \ 'User',
            \ ]

