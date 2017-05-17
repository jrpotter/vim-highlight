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

" g:highlight_registry :: { String : { String : String } } {{{2
" ------------------------------------------------------------------------------
" The following dictionary corresponds to registers 0-9 and their respective
" syntax attributes. Adjust this to set the properties for a given highlight
" group. Allowed keys in the nested dictionary are listed in *synIDattr*, except
" for the 'name' attribute. Unrecognized keys are simply ignored. Only 'cterm'
" related attributes are supported (that is, gui specific attributes are not
" supported).
"
" In addition, can also include a key of 'group' in the nested dictionary to
" indicate which highlight group to default a property to. By default, this
" group is 'Search'. Thus, key '0' could also be written as:
" { 'fg' : 'Yellow', 'group' : 'Search', 'bold': '0' }.
"
" TODO(jrpotter): Consider adding support for GUI and term?

if !exists('g:highlight_registry')
  function! s:InitializeHighlightRegistry()
    let g:highlight_registry = {}
    let l:colors = [ 'Yellow', 'Blue', 'Red', 'Magenta', 'Green', 'Cyan',
                   \ 'DarkYellow', 'White', 'Gray', 'Black' ]
    let l:index = 0
    while l:index < len(l:colors)
      let g:highlight_registry[string(l:index)] =
            \{ 'fg' : l:colors[l:index], 'bg' : 'none', 'bold' : '1' }
      let l:index = l:index + 1
    endwhile
  endfunction
  call s:InitializeHighlightRegistry()
endif


" g:highlight_linkage :: [ String ] {{{2
" ------------------------------------------------------------------------------
"  Provides support for adding linkage to other accent groups if desired. For
"  instance, airline's statusline uses highlight group __accent_Search if using
"  Search, and want to keep this updated if possible.

if !exists('g:highlight_linkage')
  let g:highlight_linkage = ['Search']
else
  call add(g:highlight_linkage, 'Search')
endif


" MAPPINGS: {{{1
" ==============================================================================

" Append Searches
noremap <Plug>HRegistry_AppendToSearch
    \ :call highlight#append_to_search(v:register, 'c')<Bar>
    \  call highlight#count_pattern('c')<CR>
noremap <Plug>HRegistry_GAppendToSearch
    \ :call highlight#append_to_search(v:register, 'g')<Bar>
    \  call highlight#count_pattern('g')<CR>
noremap <Plug>HRegistry_VisualAppendToSearch
    \ :call highlight#append_to_search(v:register, 'v')<Bar>
    \  call highlight#count_pattern('v')<CR>

" Remove Searches
noremap <Plug>HRegistry_RemoveFromSearch
    \ :call highlight#remove_from_search(v:register, 'c')<CR>
noremap <Plug>HRegistry_VisualRemoveFromSearch
    \ :call highlight#remove_from_search(v:register, 'v')<CR>

" Other Modifications
noremap <Plug>HRegistry_ClearRegister
    \ :call highlight#clear_register(v:register)<Bar>
    \  call highlight#activate_register(v:register)<CR>
noremap <Plug>HRegistry_ActivateRegister
    \ :call highlight#activate_register(v:register)<CR>
noremap <Plug>HRegistry_CountLastSeen
    \ :call highlight#count_pattern('c')<CR>

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

command ResetHighlightRegistry :call highlight#reset()


" PROCEDURE: Initialize {{{1
" ==============================================================================

call highlight#reset()

