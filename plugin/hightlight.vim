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
    let l:colors = [ 'Yellow', 'LightBlue', 'Red', 'Magenta', 'Green', 'Cyan',
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


" g:highlight_persist_unnamed_register :: Boolean {{{2
" ------------------------------------------------------------------------------
" Determines how to manage the unnamed register '"'. If set to false, we regard
" the unnamed register to implicitly imply use of the last activated register.

if !exists('g:highlight_persist_unnamed_register')
  let g:highlight_persist_unnamed_register = 0
endif


" g:highlight_register_prefix :: String {{{2
" ------------------------------------------------------------------------------
" Prefix used for group names and for link between Search highlight group and
" the highlight registries. That is,
" hi link Search {g:highlight_register_prefix}
" and
" hi link {g:highlight_register_prefix} {active search register}.

if !exists('g:highlight_register_prefix')
  let g:highlight_register_prefix = 'HighlightRegister'
endif


" g:highlight_register_prefix_link :: String
" ------------------------------------------------------------------------------
" Name of the highlight group the highlight_register_prefix group should be
" linked to when no longer active. By default, this is NONE.

if !exists('g:highlight_register_prefix_link')
  let g:highlight_register_prefix_link = 'NONE'
endif


" MAPPINGS: {{{1
" ==============================================================================

" Append Searches
noremap <Plug>HRegistry_AppendToSearch
    \ :call highlight#append_to_search(highlight#expand_reg(v:register),
    \                                  highlight#expand_flag('c'))
    \ <Bar>call highlight#count_pattern(highlight#expand_flag('c'))<CR>
noremap <Plug>HRegistry_GAppendToSearch
    \ :call highlight#append_to_search(highlight#expand_reg(v:register),
    \                                  highlight#expand_flag('g'))
    \ <Bar>call highlight#count_pattern(highlight#expand_flag('g'))<CR>
noremap <Plug>HRegistry_VisualAppendToSearch
    \ :call highlight#append_to_search(highlight#expand_reg(v:register),
    \                                  highlight#expand_flag('v'))
    \ <Bar>call highlight#count_pattern(highlight#expand_flag('v'))<CR>

" Remove Searches
noremap <Plug>HRegistry_RemoveFromSearch
    \ :call highlight#remove_from_search(highlight#expand_reg(v:register),
    \                                    highlight#expand_flag('c'))<CR>
noremap <Plug>HRegistry_VisualRemoveFromSearch
    \ :call highlight#remove_from_search(highlight#expand_reg(v:register),
    \                                    highlight#expand_flag('v'))<CR>

" Other Modifications
noremap <Plug>HRegistry_ClearRegister
    \ :call highlight#clear_register(highlight#expand_reg(v:register))<Bar>
    \  call highlight#activate_register(highlight#expand_reg(v:register))<CR>
noremap <Plug>HRegistry_ActivateRegister
    \ :call highlight#activate_register(highlight#expand_reg(v:register))<CR>
noremap <Plug>HRegistry_CountLastSeen
    \ :call highlight#count_pattern(highlight#expand_flag('c'))<CR>

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

