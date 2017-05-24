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


" FUNCTION: ExpandRegister(reg) {{{1
" ==============================================================================
" Convenience method to determine which register is being currently used.
" The unnamed register defaults to the last used register to avoid having to
" constantly prefix registration. This can be changed by setting the value of
" g:persist_unnamed_register to 1.

function! highlight#expand_register(reg)
  if !g:persist_unnamed_register && a:reg ==# '"'
    return s:active_register
  endif
  return a:reg
endfunction


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
" Mirrors the look of a given prompted highlight group (e.g. :hi Search)

function! highlight#statusline()
  return repeat(s:active_register, 3)
endfunction


" FUNCTION: GetGroupName(reg) {{{1
" ==============================================================================
" Group names are not allowed to have special characters; they must be
" alphanumeric or underscores.

function! highlight#get_group_name(reg)
  return 'highlight_registry_' . char2nr(a:reg)
endfunction


" FUNCTION: GetGroupSpecification(reg) {{{1
" ==============================================================================
" Gets the specification created in the g:highlight_registry for a given
" h_register. If it does not exist then we pick a 'random' option from the
" registry. 

function! highlight#get_group_specification(reg)
  if has_key(g:highlight_registry, a:reg)
    return g:highlight_registry[a:reg]
  endif
  " Since vim does not have built in random functionality, we instead look at
  " the given line we are currently at and choose this value mod the size of the
  " registry.
  "
  " TODO(jrpotter): Neovim provides Lua builtin. Perhaps use that instead?
  let l:target = line('.') % len(g:highlight_registry)
  let l:index = 0
  for l:key in keys(g:highlight_registry)
    if l:index == l:target
      return g:highlight_registry[l:key]
    else
      let l:index = l:index + 1
    endif
  endfor
endfunction


" FUNCTION: InitRegister() {{{1
" ==============================================================================
" Sets up the highlight group. This must be called before any attempts to add
" matches to a given h_register is performed.

function! highlight#init_register(reg, color)
  call highlight#clear_register(a:reg)
  let s:registry[a:reg] = {}

  " Build custom highlight group with any attributes supported by cterm. If the
  " specification has a 'group' key, use that group as a base template instead
  " of the default 'Search' group.
  let l:specs = highlight#get_group_specification(a:reg)
  let l:group = get(l:specs, 'group', 'Search')

  " Supported attributes for 'cterm' and 'gui', as indicated by *synIDattr*.
  let l:attrs = [ 'fg', 'bg', 'bold', 'italic', 'underline',
                \ 'reverse', 'inverse', 'standout', 'underline', 'undercurl']

  let l:highlight=[]
  for l:mode in ['cterm', 'gui']
    let l:group_fg = synIDattr(synIDtrans(hlID(l:group)), 'fg', l:mode)
    let l:group_bg = synIDattr(synIDtrans(hlID(l:group)), 'bg', l:mode)
    let l:group_attrs = {}
    for l:key in l:attrs[2:]
      if synIDattr(synIDtrans(hlID(l:group)), l:key, l:mode)
        let l:attrs[l:key] = '1'
      endif
    endfor
    " First build up text formats.
    let l:text_format = []
    for l:key in l:attrs[2:]
      if has_key(l:specs, l:key)
        if l:specs[l:key] ==# '1'
          call add(l:text_format, l:key)
        endif
      " If not present, then can default to highlight group.
      elseif get(l:group_attrs, l:key, '0') ==# '1'
        call add(l:text_format, l:key)
      endif
    endfor
    " Now append the attributes for the given mode.
    if !empty(get(l:specs, 'fg', l:group_fg))
      call add(l:highlight, l:mode . 'fg=' . get(l:specs, 'fg', l:group_fg)) 
    endif
    if !empty(get(l:specs, 'bg', l:group_bg))
      call add(l:highlight, l:mode . 'bg=' . get(l:specs, 'bg', l:group_bg)) 
    endif
    if !empty(l:text_format)
      call add(l:highlight, l:mode . '=' . join(l:text_format, ','))
    endif
  endfor

  exe 'hi' highlight#get_group_name(a:reg) join(l:highlight)
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
    exe 'hi! link Search' highlight#get_group_name(a:reg)
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
    if len(s:registry[a:reg]) == 1
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

