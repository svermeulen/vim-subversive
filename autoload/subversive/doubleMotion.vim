
let s:searchText = ''
let s:startCursorPos = []
let s:startWinView = {}
let s:activeRegister = ''
let s:promptForReplaceText = 0
let s:useAbolish = 0
let s:completeWord = 0
let s:confirmReplace = 0

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

function! s:UpdateHighlight(searchText, startLine, endLine, startCol, endCol, caseSensitive, completeWord)
    call s:ClearHighlight()
    call s:AttachClearHighlightAutoCommands()

    let searchQuery = '\V' . (a:caseSensitive ? '\C' : '\c')

    let escapedSearchText = escape(a:searchText, '\')

    if a:completeWord
        let searchQuery .= '\<' . escapedSearchText . '\>'
    else
        let searchQuery .= escapedSearchText
    endif

    if a:startLine != -1
        let searchQuery .= '\%>' . max([0, a:startLine-1]) . 'l'
    endif

    if a:endLine != -1
        let searchQuery .= '\%<' . (a:endLine+1) . 'l'
    endif

    if a:startCol == a:endCol
        if a:startCol != -1
            let searchQuery .= '\%' . (a:startCol+1) . 'c'
        endif
    else
        if a:startCol != -1
            let searchQuery .= '\%>' . (a:startCol+1) . 'c'
        endif

        if a:endCol != -1
            let searchQuery .= '\%<' . (a:endCol+2) . 'c'
        endif
    endif

    let w:patternHighlightId = matchadd('Search', searchQuery, 2, get(w:, 'patternHighlightId', -1))
endfunction

function! subversive#doubleMotion#preSubstitute(register, promptForReplaceText, useAbolish, completeWord, confirmReplace)
    let s:startCursorPos = getpos('.')
    let s:startWinView = winsaveview()
    let s:activeRegister = a:register
    let s:promptForReplaceText = a:promptForReplaceText
    let s:useAbolish = a:useAbolish
    let s:completeWord = a:completeWord
    let s:confirmReplace = a:confirmReplace
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

    call s:UpdateHighlight(s:searchText, start[1], start[1], start[2], end[2], 1, s:completeWord)

    call feedkeys("\<plug>(_SubversiveSubstituteRangeSecondary)", "m")
endfunction

function! s:RestoreStartCursorPosition()
    call setpos('.', s:startCursorPos)
    call winrestview(s:startWinView)
endfunction

function! s:getDefaultReg()
    let clipboardFlags = split(&clipboard, ',')
    if index(clipboardFlags, 'unnamedplus') >= 0
        return "+"
    elseif index(clipboardFlags, 'unnamed') >= 0
        return "*"
    else
        return "\""
    endif
endfunction

function! subversive#doubleMotion#selectRangeMotion(type)

    let startLine = line("'[")
    let endLine = line("']")

    if s:activeRegister == s:getDefaultReg() && s:promptForReplaceText
        call s:UpdateHighlight(s:searchText, startLine, endLine, -1, -1, !s:useAbolish, s:completeWord)

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

    let commandStr = startLine . ',' . endLine

    if s:useAbolish
        let commandStr .= 'S/'
    else
        let commandStr .= 's/\V\C'
    endif

    let escapedSearchText = escape(s:searchText, '/\')

    if s:completeWord && !s:useAbolish
        let commandStr .= '\<' . escapedSearchText . '\>'
    else
        let commandStr .= escapedSearchText
    endif

    let commandStr .= '/'. escape(replaceText, '/\') .'/'

    if s:completeWord && s:useAbolish
        let commandStr .= 'w'
    endif

    if !&gdefault
        let commandStr .= 'g'
    endif

    let didConfirm = 0

    if !s:useAbolish
        let commandStr .= 'I'

        if s:confirmReplace
            let commandStr .= 'c'
            let didConfirm = 1
        endif
    endif

    exec commandStr

    " Leave cursor wherever it finished if confirming each replace
    if !didConfirm
        call s:RestoreStartCursorPosition()
    endif
endfunction

