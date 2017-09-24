" Magic --------------------------------------------

" This rewires n and N to do the highlighing...
function! HLNext (blinktime)
    set invcursorline
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
    set invcursorline
    redraw
endfunction

" Plugins
" Dirvish --
"   Interact with Fugitive forGstatus
autocmd FileType dirvish call fugitive#detect(@%)
