" ==============================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
" Comment:         For the sake of distinguishing between vim *:reg*isters and
"                  highlight registers used in the given script, we use register
"                  to describe the former and h_register to describe the latter.
"
" ==============================================================================

" SCRIPT VARIABLES:
" ==============================================================================

" s:active_register :: String {{{2
" ------------------------------------------------------------------------------
" The h_register currently active. This defaults to the unnamed register.

let s:active_register = "\""


" s:registry :: { String : { String : Match } } {{{2
" ------------------------------------------------------------------------------
" The keys of the outer dictionary are any active h_registers (that is, before a
" call to ClearRegister is called). By default, this will be set to be
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
" c: Indicates the current word, with word boundary.
" g: Indicates the current word, without word boundary.
" v: Indicates the current visual selection.
"
" Throws an error otherwise.

function! highlight#expand_flag(flag) abort
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
" Borrowed from http://stackoverflow.com/a/6271254/794380.

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

" TODO(jrpotter): Polish and test
" function! highlight#statusline(...)
"   let l:group_name = highlight#get_group_name(s:active_register)
"   " If airline is defined, this function should be called in the context of
"   " airline#parts#define_function('foo', 'highlight#airline_status'). Thus it
"   " should be sufficient to check that airline#parts#define_accent exists to
"   " ensure airline is defined.
"   if a:0 > 0 && exists('*airline#parts#define_accent')
"     call airline#parts#define_accent(a:1, l:group_name)
"     return airline#section#create_right([a:1])
"   else
"     return '%#' . l:group_name . '#xxx (" . s:active_register . ")%*'
"   endif
" endfunction


" FUNCTION: GetGroupName(reg) {{{1
" ==============================================================================
" Group names are not allowed to have special characters; they must be
" alphanumeric or underscores.

function! highlight#get_group_name(reg)
  return 'highlight_registry_' . char2nr(a:reg)
endfunction


" FUNCTION: InitRegister() {{{1
" ==============================================================================
" Sets up the highlight group. This must be called before any attempts to add
" matches to a given h_register is performed.

function! highlight#init_register(reg, color)
  call highlight#clear_register(a:reg)
  " TODO(jrpotter): Mirror current Search group
  exe 'hi ' . highlight#get_group_name(a:reg) .
      \ ' cterm=bold,underline ctermfg=' . a:color
  let s:registry[a:reg] = {}
endfunction


" FUNCTION: ActivateRegister() {{{1
" ==============================================================================
" Places the contents of a highlight register into the search register and links
" the Search highlight group to the highlight group name. Activation of an
" h_register that has not yet been initialized is allowed - in this case, the
" search register is simply cleared.

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


" FUNCTION: AppendToSearch(reg, flag) {{{1
" ==============================================================================
" Extends the current matches of h_register reg with the pattern found once flag
" is expanded. If the h_register specified has not yet been initialized, simply
" create a new h_register and continue.

function! highlight#append_to_search(reg, flag)
  let l:pattern = highlight#expand_flag(a:flag)
  if len(l:pattern) > 0
    if !has_key(s:registry, a:reg)
      " TODO(jrpotter): Choose color better.
      call highlight#init_register(a:reg, 'Yellow')
    endif
    " Don't want to add multiple match objects into registry
    if !has_key(s:registry[a:reg], l:pattern)
      let s:registry[a:reg][l:pattern] = 
          \ matchadd(highlight#get_group_name(a:reg), l:pattern)
    endif
    " Updates the search register
    call highlight#activate_register(a:reg)
  endif
endfunction


" FUNCTION: RemoveFromSearch(reg, flag) {{{1
" ==============================================================================
" Removes the given pattern found once flag is expanded from the passed
" h_register reg. If the h_register will be emptied as a result of this call,
" instead delegating to clearing out the register instead.

function! highlight#remove_from_search(reg, flag)
  let l:pattern = highlight#expand_flag(a:flag)
  if has_key(s:registry, a:reg) && has_key(s:registry[a:reg], l:pattern)
    if len(s:registry[a:reg] == 1)
      call highlight#clear_register(a:reg)
    else
      silent! call matchdelete(s:registry[a:reg][l:pattern])
      unlet s:registry[a:reg][l:pattern]
    endif
  endif
  " Updates the search register
  call highlight#activate_register(a:reg)
endfunction


" FUNCTION: ClearRegister(reg) {{{1
" ==============================================================================
" Used to clear out the h_register reg and potentially unlink the Search
" highlight group.

function! highlight#clear_register(reg)
  exe 'hi clear ' . highlight#get_group_name(a:reg)
  if has_key(s:registry, a:reg)
    for key in keys(s:registry[a:reg])
      silent! call matchdelete(s:registry[a:reg][key])
      unlet s:registry[a:reg][key]
    endfor
    unlet s:registry[a:reg]
  endif
  if a:reg ==# s:active_register
    hi! link Search NONE
  endif
endfunction


" FUNCTION: Reset() {{{1
" ==============================================================================
" Used to reset the state of all h_register's.

function! highlight#reset()
  for key in keys(s:registry)
    call highlight#clear_register(key)
  endfor
  for [key, value] in items(g:highlight_registry)
    call highlight#init_register(key, value)
  endfor
endfunction

