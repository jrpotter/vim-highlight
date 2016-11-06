" ======================================================================
" File:            highlight.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

if exists('g:loaded_highlight')
    finish
endif
let g:loaded_highlight = 1


" SCRIPT VARIABLES:
" ======================================================================

" s:highlight_register_color :: { String : Match } {{{2
" ----------------------------------------------------------------------

let s:highlight_register_color = { 0 : 'Yellow',
                                 \ 1 : 'DarkYellow',
                                 \ 2 : 'Red',
                                 \ 3 : 'DarkRed',
                                 \ 4 : 'Green',
                                 \ 5 : 'DarkGreen',
                                 \ 6 : 'Blue',
                                 \ 7 : 'DarkBlue',
                                 \ 8 : 'Magenta',
                                 \ 9 : 'DarkMagenta',
                                 \ }


" s:matches :: { String : Match } {{{2
" ----------------------------------------------------------------------
" List of matches corresponding to the registry for potential deletion

let s:matches = {}


" s:registry :: { String : [String] } {{{2
" ----------------------------------------------------------------------
" Register to key corresponding to match. Keeps track of matches for
" deletion afterward

let s:registry = {}


" FUNCTION: MatchName(reg, word) {{{1
" ======================================================================

function! s:MatchName(reg, word)
    return a:reg . "_" . word
endfunction!


" FUNCTION: GroupName(reg) {{{1
" ======================================================================

function! s:GroupName(reg)
    return "PlugHighlightRegister_" . a:reg
endfunction


" FUNCTION: ClearHighlightRegister(reg) {{{1
" ======================================================================
" Used to clear out the 'registers' that are used to hold which values are
" highlighted under a certain match group.

function! s:ClearHighlightRegister(reg)
    exe "hi clear " . s:GroupName(a:reg)
    unlet s:highlight_register_color[a:reg]
    if has_key(s:registry, a:reg)
        for m in s:registry[a:reg]
            matchdelete(s:matches[s:registry[a:reg]])
            unlet s:matches[s:registry[a:reg]]
        endfor
        unlet s:registry[a:reg]
    endif
endfunction


" FUNCTION: InitHighlightRegister(reg) {{{1
" ======================================================================
" Setups the group and highlighting. Matches are added afterward

function! s:InitHighlightRegister(reg, color)
    call c:ClearHighlightRegister(a:reg)
    let s:highlight_register_color[a:reg] = a:color
    exe "hi " . s:GroupName(a:reg) . " cterm=bold, underline ctermbg=" . a:color
endfunction


" FUNCTION: AppendToSearch(reg, word) {{{1
" ======================================================================

function! s:AppendToSearch(reg, word)
    let m = matchadd(s:GroupName(a:reg), "\<" . a:word . "\>")
    let s:matches[s:MatchName(a:reg, a:word)] = l:m
    if !has_key(s:registry, a:reg)
        let s:registry[a:reg] = []
    endif
    append(s:registry[a:reg], s:MatchName(a:reg, a:word))
endfunction


" FUNCTION: RemoveFromSearch(reg, word) {{{1
" ======================================================================

function! s:RemoveFromSearch(reg, word)
    matchdelete(s:matches[s:MatchName(a:reg, a:word)])
    unlet s:matches[s:MatchName(a:reg, a:word)]
    let i = 0
    while i < len(s:registry[a:reg])
        if s:registry[a:reg] == s:MatchName(a:reg, a:word)
            unlet s:registry[a:reg][i]
            break
        endif
        i = i + 1
    endwhile
    if len(s:registry[a:reg]) == 0
        unlet s:registry[a:reg]
    endif
endfunction


" FUNCTION: Initialize {{{1
" ======================================================================

call s:InitHighlightRegister('0', 'Yellow')
call s:InitHighlightRegister('1', 'DarkYellow')
call s:InitHighlightRegister('2', 'Red')
call s:InitHighlightRegister('3', 'DarkRed')
call s:InitHighlightRegister('4', 'Green')
call s:InitHighlightRegister('5', 'DarkGreen')
call s:InitHighlightRegister('6', 'Blue')
call s:InitHighlightRegister('7', 'DarkBlue')
call s:InitHighlightRegister('8', 'Magenta')
call s:InitHighlightRegister('9', 'DarkMagenta')

