" ======================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

if exists('g:loaded_highlight_registry')
  finish
endif
let g:loaded_highlight_registry = 1


" GLOBAL VARIABLES:
" ======================================================================

" g:highlight_register_default_color :: String {{{2
" ----------------------------------------------------------------------

if !exists('g:highlight_register_default_color')
  let g:highlight_register_default_color = 'Yellow'
endif


" g:highlight_registry :: { String : String } {{{2
" ----------------------------------------------------------------------

if !exists('g:highlight_registry')
    let g:highlight_registry = { '0' : 'Yellow'
                               \ '1' : 'Blue'
                               \ '2' : 'Red'
                               \ '3' : 'Magenta'
                               \ '4' : 'Green'
                               \ '5' : 'Cyan'
                               \ '6' : 'DarkYellow'
                               \ '7' : 'White'
                               \ '8' : 'Gray'
                               \ '9' : 'Black'
                               \ }
endif


" MAPPINGS: {{{1
" ======================================================================

" Append Searches
noremap <Plug>HRegistry_AppendToSearch
    \ :call highlight#append_to_search('\<'.expand('<cword>').'\>')<CR>
    \ :call highlight#count_last_seen()<CR>
noremap <Plug>HRegistry_GlobalAppendToSearch
    \ :call highlight#append_to_search(expand('<cword>'))<CR>
    \ :call highlight#count_last_seen()<CR>
noremap <Plug>HRegistry_VisualAppendToSearch
    \ :call highlight#append_to_search(highlight#get_visual_selection())<CR>
    \ :call highlight#count_last_seen()<CR>'<

" Remove Searches
noremap <Plug>HRegistry_RemoveFromSearch
    \ :call highlight#remove_from_search('\<'.expand('<cword>').'\>')<CR>
noremap <Plug>HRegistry_VisualRemoveFromSearch
    \ :call highlight#remove_from_search(highlight#get_visual_selection())<CR>'<

" Other Modifications
noremap <Plug>HRegistry_ClearRegister :call highlight#clear_register()<CR>
noremap <Plug>HRegistry_ActivateRegister :call highlight#activate_register()<CR>
noremap <Plug>HRegistry_CountLastSeen :call highlight#count_last_seen()<CR>

" Normal Mappings
nmap  & <Plug>HRegistry_AppendToSearch
nmap g& <Plug>HRegistry_GlobalAppendToSearch
nmap y& <Plug>HRegistry_ActivateRegister
nmap d& <Plug>HRegistry_RemoveFromSearch
nmap c& <Plug>HRegistry_ClearRegister

nmap  * :silent norm! *<CR>&
nmap g* :silent norm! *<CR>g&

nmap  # :silent norm! #<CR>&
nmap g# :silent norm! #<CR>g&

" Visual Mappings
vmap  & <Plug>HRegistry_VisualAppendToSearch
vmap d& <Plug>HRegistry_VisualRemoveFromSearch
vmap  * &n<Plug>HRegistry_CountLastSeen
vmap  # &N<Plug>HRegistry_CountLastSeen


" PROCEDURE: Initialize {{{1
" ======================================================================

for key in keys(g:highlight_registry)
  call highlight#init_register(key, g:highlight_registry[key])
endfor
call highlight#append_to_search(v:register, @/)

