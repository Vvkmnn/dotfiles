" Functions ----------------------------------------

" Blink link with match
function! HLNext (blinktime)
       set invcursorline
       redraw
       exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
       set invcursorline
       redraw
   endfunction

