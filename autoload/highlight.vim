" ==============================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ==============================================================================

" SCRIPT VARIABLES:
" ==============================================================================

" s:active_register :: String {{{2
" ------------------------------------------------------------------------------
" The register currently active. This defaults to the unnamed register.

let s:active_register = "\""


" s:registry :: { String : { String : Match } } {{{2
" ------------------------------------------------------------------------------
" The keys of the outer dictionary are any active registers (that is, before a
" call to clear register is called). By default, this will be set to be
" populated with at least g:highlight_registry once the plugin is loaded.
"
" The corresponding values of the outer dictionary is a key value pairing of a
" matched identifier and the Match object corresponding to it. We must keep
" track of match objects as they must be deleted manually by matchdelete.

let s:registry = {}


" FUNCTION: ExpandFlag(flag) {{{1
" ==============================================================================
" Convenience method used to make the mappings in plugin/highlight.vim a bit
" easier to read through. The passed flag can be:
"
" c) Indicates the current word, with word boundary.
" g) Indicates the current word, without word boundary.
" v) Indicates the current visual selection.

function! highlight#expand_flag(a:flag) abort
  if a:flag ==# 'c'
    return '\<' . expand('<cword>') . '\>'
  elseif a:flag ==# 'g'
    return expand('<cword>')
  elseif a:flag ==# 'v'
    return highlight#get_visual_selection()
  endif
  throw 'Could not expand passed flag: ' . a:flag
endfunction


" FUNCTION: CountPattern(flag) {{{1
" ==============================================================================
" Convenience method used to display the number of times the passed pattern has
" occurred in the current buffer.

function! highlight#count_pattern(flag)
  let l:pattern = highlight#expand_flag(a:flag)
  if len(@/) > 0
    let pos = getpos('.')
    exe ' %s/' . l:pattern . '//gne'
    call setpos('.', pos)
  endif
endfunction


" FUNCTION: GetVisualSelection {{{1
" ==============================================================================

function! highlight#get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return substitute(escape(join(lines, "\n"), '\\/.*$%~[]'), '\n', '\\n', 'g')
endfunction


" FUNCTION: Statusline() {{{1
" ==============================================================================
" Allow for integrating the currently highlighted section into the statusline.
" If airline is found, synchronize the accent with the highlighting.
" Can use as follows:
" call airline#parts#define_function('foo', 'highlight#airline_status()')
" call airline#parts#define_minwidth('foo', 50)
" let g:airline_section_y = airline#section#create_right(['ffenc', 'foo'])

function! highlight#statusline(...)
  let l:group_name = highlight#get_group_name(s:active_register)
  " If airline is defined, this function should be called in the context of
  " airline#parts#define_function('foo', 'highlight#airline_status'). Thus it
  " should be sufficient to check that airline#parts#define_accent exists to
  " ensure airline is defined.
  if a:0 > 0 && exists('*airline#parts#define_accent')
    call airline#parts#define_accent(a:1, l:group_name)
    return airline#section#create_right([a:1])
  else
    return '%#' . l:group_name . '#xxx (" . s:active_register . ")%*'
  endif
endfunction


" FUNCTION: GetGroupName(reg) {{{1
" ==============================================================================
" Note group names are not allowed to have special characters; they 
" must be alphanumeric or underscores.

function! highlight#get_group_name(reg)
  return 'highlight_registry_' . char2nr(a:reg)
endfunction


" FUNCTION: InitRegister() {{{1
" ==============================================================================
" Setups the group and highlighting. Matches are added afterward.

function! highlight#init_register(reg, color)
  call highlight#clear_register(a:reg)
  exe 'hi ' . highlight#get_group_name(a:reg) .
      \ ' cterm=bold,underline ctermfg=' . a:color
endfunction


" FUNCTION: ClearRegister() {{{1
" ==============================================================================
" Used to clear out the 'registers' that are used to hold which values are
" highlighted under a certain match group.

function! highlight#clear_register(reg)
  exe 'hi clear ' . highlight#get_group_name(a:reg)
  if has_key(s:registry, a:reg)
    for key in keys(s:registry[a:reg])
      silent! call matchdelete(s:registry[a:reg][key])
      unlet s:registry[a:reg][key]
    endfor
    unlet s:registry[a:reg]
  endif
  call highlight#activate_register(a:reg)
endfunction


" FUNCTION: ClearAllRegisters() {{{1
" ==============================================================================

function! highlight#clear_all_registers()
  for key in keys(g:highlight_registry)
    call highlight#init_register(key, g:highlight_registry[key])
  endfor
  for key in keys(s:registry)
    if !has_key(g:highlight_registry, key)
      call highlight#clear_register(key)
    endif
  endfor
endfunction


" FUNCTION: ActivateRegister() {{{1
" ==============================================================================
" We must actively set the search register to perform searches as expected.

function! highlight#activate_register(reg)
  let s:active_register = a:reg
  if has_key(s:registry, a:reg)
    let search = ''
    for key in keys(s:registry[a:reg])
      let search = search . key . '\|'
    endfor
    let @/ = search[:-3]
    exe 'hi! link Search ' . highlight#get_group_name(a:reg)
    set hlsearch
  else
    let @/ = ''
  endif
endfunction


" FUNCTION: AppendToSearch(pattern) {{{1
" ==============================================================================

function! highlight#append_to_search(reg, pattern)
  if len(a:pattern) == 0
    return
  endif
  if !has_key(s:registry, a:reg)
    " TODO(jrpotter): Change to one of least used color.
    call highlight#init_register(a:reg, 'Yellow')
    let s:registry[a:reg] = {}
  endif
  " Don't want to add multiple match objects into registry
  if !has_key(s:registry[a:reg], a:pattern)
    let s:registry[a:reg][a:pattern] = 
        \ matchadd(highlight#get_group_name(a:reg), a:pattern)
  endif
  call highlight#activate_register(a:reg)
endfunction


" FUNCTION: RemoveFromSearch(pattern) {{{1
" ==============================================================================

function! highlight#remove_from_search(reg, pattern)
  if has_key(s:registry, a:reg)
    if has_key(s:registry[a:reg], a:pattern)
      call matchdelete(s:registry[a:reg][a:pattern])
      unlet s:registry[a:reg][a:pattern]
      if len(s:registry[a:reg]) == 0
        unlet s:registry[a:reg]
      endif
    endif
  endif
  call highlight#activate_register(a:reg)
endfunction

