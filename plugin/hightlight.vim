" ======================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

if exists('g:loaded_highlight')
    finish
endif
let g:loaded_highlight = 1


" GLOBAL VARIABLES:
" ======================================================================

let g:highlight_register_default_color = 'Yellow'


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


" FUNCTION: GroupName(reg) {{{1
" ======================================================================
" Note group names are not allowed to have special characters; they 
" must be alphanumeric or underscores.

function! s:GroupName(reg)
    return 'HighlightRegistry_' . char2nr(a:reg)
endfunction


" FUNCTION: InitRegister(reg) {{{1
" ======================================================================
" Setups the group and highlighting. Matches are added afterward.

function! s:InitRegister(reg, color)
    call s:ClearRegister(a:reg)
    let s:registry_colors[a:reg] = a:color
    exe 'hi ' . s:GroupName(a:reg) . ' cterm=bold,underline ctermfg=' . a:color
endfunction


" FUNCTION: ClearRegister(reg) {{{1
" ======================================================================
" Used to clear out the 'registers' that are used to hold which values are
" highlighted under a certain match group.

function! s:ClearRegister(reg)
    exe 'hi clear ' . s:GroupName(a:reg)
    if has_key(s:registry_colors, a:reg)
        unlet s:registry_colors[a:reg]
    endif
    if has_key(s:registry, a:reg)
        for key in keys(s:registry[a:reg])
            call matchdelete(s:registry[a:reg][key])
            unlet s:registry[a:reg][key]
        endfor
        unlet s:registry[a:reg]
    endif
    call s:ActivateRegister(a:reg)
endfunction


" FUNCTION: CountLastSeen() {{{1
" ======================================================================

function! s:CountLastSeen()
    if len(@/) > 0
        let pos = getpos('.')
        exe ' %s/' . s:last_seen . '//gne'
        call setpos('.', pos)
    endif
endfunction


" FUNCTION: ActivateRegister(reg) {{{1
" ======================================================================
" We must actively set the search register to perform searches as expected.

function! s:ActivateRegister(reg)
    if has_key(s:registry, a:reg) && has_key(s:registry_colors, a:reg)
        let search = ''
        for key in keys(s:registry[a:reg])
            let search = search . key . '\|'
        endfor
        let @/ = search[:-3]
        exe 'hi Search cterm=bold,underline ctermbg=none ctermfg=' . s:registry_colors[a:reg]
        set hlsearch
    else
        let @/ = ''
    endif
endfunction


" FUNCTION: AppendToSearch(reg, pattern, ...) {{{1
" ======================================================================

function! s:AppendToSearch(reg, pattern)
    let s:last_seen = a:pattern
    if len(a:pattern) > 0
        if !has_key(s:registry_colors, a:reg)
            call s:InitRegister(a:reg, g:highlight_register_default_color)
        endif
        if !has_key(s:registry, a:reg)
            let s:registry[a:reg] = {}
        endif
        " Don't want to add multiple match objects into registry
        if !has_key(s:registry[a:reg], a:pattern)
            let s:registry[a:reg][a:pattern] = 
                        \ matchadd(s:GroupName(a:reg), a:pattern)
        endif
        call s:ActivateRegister(a:reg)
    endif
endfunction


" FUNCTION: GetVisualSelection {{{1
" ======================================================================

function! s:GetVisualSelection()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return substitute(escape(join(lines, "\n"), '\\/.*$%~[]'), '\n', '\\n', 'g')
endfunction


" FUNCTION: RemoveFromSearch(reg, pattern) {{{1
" ======================================================================

function! s:RemoveFromSearch(reg, pattern)
    if has_key(s:registry, a:reg) && has_key(s:registry[a:reg], a:pattern)
        call matchdelete(s:registry[a:reg][a:pattern])
        unlet s:registry[a:reg][a:pattern]
        if len(s:registry[a:reg]) == 0
            unlet s:registry[a:reg]
        endif
    endif
    call s:ActivateRegister(a:reg)
endfunction


" PROCEDURE: Initialize {{{1
" ======================================================================

exe 'hi Search cterm=bold,underline ctermbg=none ctermfg=' . g:highlight_register_default_color

call s:InitRegister('0', 'Yellow')
call s:InitRegister('1', 'Blue')
call s:InitRegister('2', 'Red')
call s:InitRegister('3', 'Magenta')
call s:InitRegister('4', 'Green')
call s:InitRegister('5', 'Cyan')
call s:InitRegister('6', 'DarkYellow')
call s:InitRegister('7', 'White')
call s:InitRegister('8', 'Gray')
call s:InitRegister('9', 'Black')

call s:AppendToSearch(v:register, @/)

" Word Boundary Search Modifications
noremap <unique> <silent> <Plug>HighlightRegistry_AppendToSearch
            \ :call <SID>AppendToSearch(v:register, '\<'.expand('<cword>').'\>')<CR>
            \ :call <SID>CountLastSeen()<CR>
noremap <unique> <silent> <Plug>HighlightRegistry_RemoveFromSearch
            \ :call <SID>RemoveFromSearch(v:register, '\<'.expand('<cword>').'\>')<CR>

" Arbitrary Search Modifications
noremap <unique> <silent> <Plug>HighlightRegistry_GlobalAppendToSearch
            \ :call <SID>AppendToSearch(v:register, expand('<cword>'))<CR>
            \ :call <SID>CountLastSeen()<CR>
noremap <unique> <silent> <Plug>HighlightRegistry_VisualAppendToSearch
            \ :call <SID>AppendToSearch(v:register, <SID>GetVisualSelection())<CR>
            \ :call <SID>CountLastSeen()<CR>
noremap <unique> <silent> <Plug>HighlightRegistry_VisualRemoveFromSearch
            \ :call <SID>RemoveFromSearch(v:register, <SID>GetVisualSelection())<CR>

" Register Modifications
noremap <unique> <silent> <Plug>HighlightRegistry_ClearRegister
            \ :call <SID>ClearRegister(v:register)<CR>
noremap <unique> <silent> <Plug>HighlightRegistry_ActivateRegister
            \ :call <SID>ActivateRegister(v:register)<CR>

" Miscellaneous Mappings
noremap <unique> <silent> <Plug>HighlightRegistry_CountLastSeen
            \ :call <SID>CountLastSeen()<CR>

" Default Mappings
nmap & <Plug>HighlightRegistry_AppendToSearch
nmap * :silent norm! *<CR>&
nmap # :silent norm! #<CR>&

nmap g& <Plug>HighlightRegistry_GlobalAppendToSearch
nmap g* :silent norm! *<CR>g&
nmap g# :silent norm! #<CR>g&

nmap y& <Plug>HighlightRegistry_ActivateRegister
nmap d& <Plug>HighlightRegistry_RemoveFromSearch
nmap c& <Plug>HighlightRegistry_ClearRegister

vmap & <Plug>HighlightRegistry_VisualAppendToSearch'<
vmap * &n<Plug>HighlightRegistry_CountLastSeen
vmap # &N<Plug>HighlightRegistry_CountLastSeen

vmap d& <Plug>HighlightRegistry_VisualRemoveFromSearch'<

