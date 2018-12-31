
let s:searchText = ''
let s:startCursorPos = []
let s:startWinView = {}
let s:activeRegister = ''
let s:promptForReplaceText = 0

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

function! s:UpdateHighlight(searchText, startLine, endLine, startCol, endCol)
    call s:ClearHighlight()
    call s:AttachClearHighlightAutoCommands()

    let searchText = '\V\C' . escape(a:searchText, '\')

    if a:startLine != -1
        let searchText .= '\%>' . max([0, a:startLine-1]) . 'l'
    endif

    if a:endLine != -1
        let searchText .= '\%<' . (a:endLine+1) . 'l'
    endif

    if a:startCol == a:endCol
        if a:startCol != -1
            let searchText .= '\%' . (a:startCol+1) . 'c'
        endif
    else
        if a:startCol != -1
            let searchText .= '\%>' . (a:startCol+1) . 'c'
        endif

        if a:endCol != -1
            let searchText .= '\%<' . (a:endCol+2) . 'c'
        endif
    endif

    let w:patternHighlightId = matchadd('Search', searchText, 2, get(w:, 'patternHighlightId', -1))
endfunction

function! subversive#doubleMotion#preSubstitute(register, promptForReplaceText)
    let s:startCursorPos = getpos('.')
    let s:startWinView = winsaveview()
    let s:activeRegister = a:register
    let s:promptForReplaceText = a:promptForReplaceText
endfunction

function! subversive#doubleMotion#selectTextMotion(type, ...)
    if a:type !=# 'char'
        echo "Substitution cancelled - Multiline is not supported by subversive substitute over area motion"
        return
    endif

    let fromVisualMode = a:0 > 0

    let start = getpos("'" . (fromVisualMode ? '<' : '['))
    let end = getpos("'" . (fromVisualMode ? '>' : ']'))

    if start[1] != end[1]
        echo "Substitution cancelled - Multiline is not supported by subversive substitute over area motion"
        return
    endif

    let line = getline(start[1])
    let s:searchText = line[start[2]-1:end[2]-1]

    call s:UpdateHighlight(s:searchText, start[1], start[1], start[2], end[2])

    call feedkeys("\<plug>(_SubversiveSubstituteOverAreaMotionRange)", "m")
endfunction

function! s:RestoreStartCursorPosition()
    call setpos('.', s:startCursorPos)
    call winrestview(s:startWinView)
endfunction

function! subversive#doubleMotion#selectRangeMotion(type)

    let startLine = line("'[")
    let endLine = line("']")

    if s:promptForReplaceText
        call s:UpdateHighlight(s:searchText, startLine, endLine, -1, -1)

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
    else
        let replaceText = getreg(s:activeRegister)

        if replaceText =~ '\n'
            echo "Substitution cancelled - Multiline is not supported by subversive substitute over area motion"
            return
        endif
    endif

    exec startLine . ',' . endLine . 's/\V\C'. escape(s:searchText, '/\') .'/'. escape(replaceText, '/\') .'/'
    call s:RestoreStartCursorPosition()
endfunction

