
nnoremap <silent> <plug>(_SubversiveSubstituteOverAreaMotionRange) :set opfunc=subversive#doubleMotion#selectRangeMotion<cr>g@

let s:searchText = ''
let s:preStartPos = []
let s:preWinView = {}

function! s:ClearHighlight()
    augroup SubversiveClearHighlight
        autocmd!
    augroup END

    silent! call matchdelete(w:patternHighlightId)
endfunction

function! s:AttachClearHighlightAutoCommands()
    augroup SubversiveClearHighlight
        autocmd!
        autocmd InsertEnter,WinLeave,BufLeave * call <sid>ClearHighlight()
        autocmd CursorMoved * call <sid>ClearHighlight()
    augroup END
endfunction

function! s:UpdateHighlight(searchText, rangeStart, rangeEnd)
    call s:ClearHighlight()
    call s:AttachClearHighlightAutoCommands()

    let searchText = '\V\C' . escape(a:searchText, '\')

    if a:rangeStart != -1
        let searchText .= '\%>' . max([0, a:rangeStart-1]) . 'l'
    endif

    if a:rangeEnd != -1
        let searchText .= '\%<' . (a:rangeEnd+1) . 'l'
    endif

    let w:patternHighlightId = matchadd('Search', searchText, 2, get(w:, 'patternHighlightId', -1))
endfunction

function! subversive#doubleMotion#preSubstitute()
    let s:preStartPos = getpos('.')
    let s:preWinView = winsaveview()
endfunction

function! subversive#doubleMotion#selectTextMotion(type)
    if a:type !=# 'char'
        echo "Substitution cancelled - Multiline is not supported by subversive substitute over area motion"
        return
    endif

    let start = getpos("'[")
    let end = getpos("']")

    if start[1] != end[1]
        echo "Substitution cancelled - Multiline is not supported by subversive substitute over area motion"
        return
    endif

    let line = getline(start[1])
    let s:searchText = line[start[2]-1:end[2]-1]

    call s:UpdateHighlight(s:searchText, start[1], start[1])

    call feedkeys("\<plug>(_SubversiveSubstituteOverAreaMotionRange)", "m")
endfunction

function! s:RestoreStartCursorPosition()
    call setpos('.', s:preStartPos)
    call winrestview(s:preWinView)
endfunction

function! subversive#doubleMotion#selectRangeMotion(type)

    let startLine = line("'[")
    let endLine = line("']")

    call s:UpdateHighlight(s:searchText, startLine, endLine)

    " Need to do this here in addition to after the substitution because the second motion
    " can be large (ie the whole file)
    call s:RestoreStartCursorPosition()
    " This is necessary to render highlight before the prompt
    redraw

    let replaceText = input('Substitute With: ')

    if empty(replaceText)
        " Cancelled
        return ''
    endif

    exec startLine . ',' . endLine . 's/\V\C'. escape(s:searchText, '/\') .'/'. escape(replaceText, '/\') .'/'
    call s:RestoreStartCursorPosition()
endfunction

