" ==============================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ==============================================================================

if exists('g:loaded_highlight_registry')
  finish
endif
let g:loaded_highlight_registry = 1


" GLOBAL VARIABLES:
" ==============================================================================

" g:highlight_registry :: { String : String } {{{2
" ------------------------------------------------------------------------------
" The following dictionary corresponds to registers 0-9 and their respective
" colors. Adjust this to set the colors for a given register. If a register
" isn't added to this dictionary before being attempted to be used, one of the
" least most colors will be chosen instead. See *cterm-colors*.
" TODO(jrpotter): Allow for better automatic color choices.

if !exists('g:highlight_registry')
  let g:highlight_registry = { '0' : 'Yellow',
                             \ '1' : 'Blue',
                             \ '2' : 'Red',
                             \ '3' : 'Magenta',
                             \ '4' : 'Green',
                             \ '5' : 'Cyan',
                             \ '6' : 'DarkYellow',
                             \ '7' : 'White',
                             \ '8' : 'Gray',
                             \ '9' : 'Black',
                             \ }
endif


" MAPPINGS: {{{1
" ==============================================================================

let s:word = 'expand("<cword>")'
let s:cword = '\<expand(<cword>)\>'
let s:vword = 'highlight#get_visual_selection()'

" Append Searches
noremap <Plug>HRegistry_AppendToSearch
    \ :call highlight#append_to_search(v:register, 'c')<Bar>
    \  call highlight#count_pattern(eval(s:cword))<CR>
noremap <Plug>HRegistry_GAppendToSearch
    \ :call highlight#append_to_search(v:register, 'g')<Bar>
    \  call highlight#count_pattern(eval(s:word))<CR>
noremap <Plug>HRegistry_VisualAppendToSearch
    \ :call highlight#append_to_search(v:register, 'v')<Bar>
    \  call highlight#count_pattern(eval(s:vword))<CR>

" Remove Searches
noremap <Plug>HRegistry_RemoveFromSearch
    \ :call highlight#remove_from_search(v:register, '\<'.expand('<cword>').'\>')<CR>
noremap <Plug>HRegistry_VisualRemoveFromSearch
    \ :call highlight#remove_from_search(v:register, highlight#get_visual_selection())<CR>

" Other Modifications
noremap <Plug>HRegistry_ClearRegister
    \ :call highlight#clear_register(v:register)<CR>
noremap <Plug>HRegistry_ActivateRegister
    \ :call highlight#activate_register(v:register)<CR>
noremap <Plug>HRegistry_CountLastSeen
    \ :call highlight#count_pattern('\<'.expand('<cword>').'\>')<CR>

" Normal Mappings
nmap <silent>  & <Plug>HRegistry_AppendToSearch
nmap <silent> g& <Plug>HRegistry_GAppendToSearch
nmap <silent> y& <Plug>HRegistry_ActivateRegister
nmap <silent> d& <Plug>HRegistry_RemoveFromSearch
nmap <silent> c& <Plug>HRegistry_ClearRegister

nmap <silent>  * :silent norm! *<CR>&
nmap <silent> g* :silent norm! *<CR>g&

nmap <silent>  # :silent norm! #<CR>&
nmap <silent> g# :silent norm! #<CR>g&

" Visual Mappings
vmap <silent>  & <Plug>HRegistry_VisualAppendToSearch'<
vmap <silent> d& <Plug>HRegistry_VisualRemoveFromSearch'<
vmap <silent>  * &n<Plug>HRegistry_CountLastSeen
vmap <silent>  # &N<Plug>HRegistry_CountLastSeen


" PROCEDURE: Commands {{1
" ==============================================================================

function! s:ClearHighlightRegistry()
  call highlight#clear_all_registers()
endfunction
command ClearHighlightRegistry :call <SID>ClearHighlightRegistry()


" PROCEDURE: Initialize {{{1
" ==============================================================================

call s:ClearHighlightRegistry()
call highlight#append_to_search(v:register, @/)

