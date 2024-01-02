
let g:subversivePromptWithCurrent = get(g:, 'subversivePromptWithCurrent', 0)
let g:subversiveCurrentTextRegister = get(g:, 'subversiveCurrentTextRegister', '')
let g:subversivePreserveCursorPosition = get(g:, 'subversivePreserveCursorPosition', 0)

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

function! subversive#lineRangeMotion#UpdateHighlight(searchText, startLine, endLine, startCol, endCol, caseSensitive, completeWord)
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

function! subversive#lineRangeMotion#getSubstituteCommand(searchText, replaceText, useAbolish, completeWord, confirmReplace)
    call subversive#lineRangeMotion#preSubstitute('', 0, a:useAbolish, a:completeWord, a:confirmReplace)
    let s:searchText = a:searchText
    return s:getCommandPrefix() . escape(a:replaceText, '/') . s:getCommandSuffix()
endfunction

function! subversive#lineRangeMotion#preSubstitute(register, promptForReplaceText, useAbolish, completeWord, confirmReplace)
    let s:startCursorPos = getpos('.')
    let s:startWinView = winsaveview()
    let s:activeRegister = a:register
    let s:promptForReplaceText = a:promptForReplaceText
    let s:useAbolish = a:useAbolish
    let s:completeWord = a:completeWord
    let s:confirmReplace = a:confirmReplace
endfunction

function! subversive#lineRangeMotion#selectTextMotion(type, ...)
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

    call subversive#lineRangeMotion#UpdateHighlight(s:searchText, start[1], start[1], start[2], end[2], 1, s:completeWord)

    call feedkeys("\<plug>(_SubversiveSubstituteRangeSecondary)", "mi")
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

function! s:getCommandPrefix()
    let commandPrefix = ''

    if s:useAbolish
        let commandPrefix .= 'S/'
    else
        let commandPrefix .= 's/\V\C'
    endif

    let escapedSearchText = escape(s:searchText, '/\')

    if s:completeWord && !s:useAbolish
        let commandPrefix .= '\<' . escapedSearchText . '\>'
    else
        let commandPrefix .= escapedSearchText
    endif

    let commandPrefix .= '/'
    return commandPrefix
endfunction

function! s:getCommandSuffix()

    let commandSuffix = '/'

    if s:completeWord && s:useAbolish
        let commandSuffix .= 'w'
    endif

    if !&gdefault
        let commandSuffix .= 'g'
    endif

    if !s:useAbolish
        let commandSuffix .= 'I'

        if s:confirmReplace
            let commandSuffix .= 'c'
        endif
    endif

    return commandSuffix
endfunction

function! subversive#lineRangeMotion#selectRangeMotion(type)

    let linesRange = '''[,'']'
    let commandPrefix = linesRange . s:getCommandPrefix()
    let commandSuffix = s:getCommandSuffix()

    if s:activeRegister == s:getDefaultReg() && s:promptForReplaceText
        call subversive#lineRangeMotion#UpdateHighlight(s:searchText, line("'["), line("']"), -1, -1, !s:useAbolish, s:completeWord)

        " Need to do this here in addition to after the substitution because the second motion
        " can be large (ie the whole file)
        call s:RestoreStartCursorPosition()
        " This is necessary to render highlight before the prompt
        redraw

        if g:subversiveCurrentTextRegister != ''
            call setreg(g:subversiveCurrentTextRegister, s:searchText)
        endif

        let promptWithActualCommand = get(g:, 'subversivePromptWithActualCommand', v:null)

        " When unset, show actual command only when &inccommand is set
        " so that the user gets visual feedback
        " Otherwise default to a simple prompt
        if promptWithActualCommand is v:null
          let promptWithActualCommand = !s:useAbolish && exists("&inccommand") && &inccommand !=# ''
        endif

        " If they have inccommand set in neovim then always prompt with actual command
        " so they can get the instant feedback
        if promptWithActualCommand
            let fullCommand = ":" . commandPrefix . commandSuffix

            for i in range(len(commandSuffix))
                let fullCommand .= "\<left>"
            endfor

            if g:subversivePromptWithCurrent
                let fullCommand .= escape(s:searchText, '/\')
            endif

            call feedkeys(fullCommand, "tn")
        else
            let replaceText = input('Substitute With: ', (g:subversivePromptWithCurrent ? s:searchText : ''))

            if empty(replaceText)
                " Cancelled
                return ''
            endif

            call s:execRepeatableCommand(commandPrefix . escape(replaceText, '/\') . commandSuffix)
        endif
    else
        let replaceText = getreg(s:activeRegister)

        if replaceText =~ '\n'
            echo "Substitution cancelled - Multiline is not supported by subversive substitute over area motion"
            return
        endif

        call s:execRepeatableCommand(commandPrefix . escape(replaceText, '/\') . commandSuffix)
    endif

    let didConfirm = !s:useAbolish && s:confirmReplace
    " Leave cursor wherever it finished if confirming each replace
    if !didConfirm && g:subversivePreserveCursorPosition
        call s:RestoreStartCursorPosition()
    endif
endfunction

function! s:execRepeatableCommand(command)
    let s:substituteCommand = a:command
    exec s:substituteCommand
    let &operatorfunc = 'subversive#lineRangeMotion#repeatMotion'
endfunction

function! subversive#lineRangeMotion#repeatMotion(type)
    exec s:substituteCommand
endfunction
