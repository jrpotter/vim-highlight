" ======================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

" SCRIPT VARIABLES:
" ======================================================================

" s:last_seen :: String {{{2
" ----------------------------------------------------------------------
" The pattern last appended to a registry list.

let s:last_seen = @/


" s:registry_colors :: { String : String } {{{2
" ----------------------------------------------------------------------
" Mapping between registry name and color that should be used for
" highlighting.

let s:registry_colors = {}


" s:registry :: { String : { String : Match } } {{{2
" ----------------------------------------------------------------------
" Name of register corresponding to a dict of some unique identifier of the
" word being matched, paired with the actual match object.

let s:registry = {}


" FUNCTION: GetGroupName(reg) {{{1
" ======================================================================
" Note group names are not allowed to have special characters; they 
" must be alphanumeric or underscores.

function! highlight#get_group_name()
  return 'highlight_registry_' . char2nr(v:register)
endfunction


" FUNCTION: InitRegister() {{{1
" ======================================================================
" Setups the group and highlighting. Matches are added afterward.

function! highlight#init_register(color)
  call highlight#clear_register()
  let s:registry_colors[v:register] = a:color
  exe 'hi ' . highlight#get_group_name() .
      \ ' cterm=bold,underline ctermfg=' . a:color
endfunction


" FUNCTION: ClearRegister() {{{1
" ======================================================================
" Used to clear out the 'registers' that are used to hold which values are
" highlighted under a certain match group.

function! highlight#clear_register()
  exe 'hi clear ' . highlight#get_group_name()
  if has_key(s:registry_colors, v:register)
    unlet s:registry_colors[v:register]
  endif
  if has_key(s:registry, v:register)
    for key in keys(s:registry[v:register])
      call matchdelete(s:registry[v:register][key])
        unlet s:registry[v:register][key]
    endfor
    unlet s:registry[v:register]
  endif
  call highlight#activate_register()
endfunction


" FUNCTION: CountLastSeen() {{{1
" ======================================================================

function! highlight#count_last_seen()
  if len(@/) > 0
    let pos = getpos('.')
    let pos[2] = pos[2] - 1
    exe ' %s/' . s:last_seen . '//gne'
    call setpos('.', pos)
  endif
endfunction


" FUNCTION: ActivateRegister() {{{1
" ======================================================================
" We must actively set the search register to perform searches as expected.

function! highlight#activate_register()
  if has_key(s:registry, v:register) && has_key(s:registry_colors, v:register)
    let search = ''
    for key in keys(s:registry[v:register])
      let search = search . key . '\|'
    endfor
    let @/ = search[:-3]
    exe 'hi Search cterm=bold,underline ctermbg=none ctermfg=' .
        \ s:registry_colors[v:register]
    set hlsearch
  else
    let @/ = ''
  endif
endfunction


" FUNCTION: AppendToSearch(pattern, ...) {{{1
" ======================================================================

function! highlight#append_to_search(pattern)
  let s:last_seen = a:pattern
  if len(a:pattern) > 0
    if !has_key(s:registry_colors, v:register)
      call highlight#init_register(g:highlight_register_default_color)
    endif
    if !has_key(s:registry, v:register)
      let s:registry[v:register] = {}
    endif
    " Don't want to add multiple match objects into registry
    if !has_key(s:registry[v:register], a:pattern)
      let s:registry[v:register][a:pattern] = 
          \ matchadd(highlight#get_group_name(), a:pattern)
    endif
    call highlight#activate_register()
  endif
endfunction


" FUNCTION: GetVisualSelection {{{1
" ======================================================================

function! highlight#get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return substitute(escape(join(lines, "\n"), '\\/.*$%~[]'), '\n', '\\n', 'g')
endfunction


" FUNCTION: RemoveFromSearch(pattern) {{{1
" ======================================================================

function! highlight#remove_from_search(pattern)
  if has_key(s:registry, v:register)
    if has_key(s:registry[v:register], a:pattern)
      call matchdelete(s:registry[v:register][a:pattern])
      unlet s:registry[v:register][a:pattern]
      if len(s:registry[v:register]) == 0
        unlet s:registry[v:register]
      endif
    endif
  endif
  call highlight#activate_register()
endfunction

