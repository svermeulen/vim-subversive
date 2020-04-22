
let s:activeRegister = ''
let s:savedStartPos = []
let s:savedEndPos = []
let s:visualMap = 0
let s:visualMode = 0
let s:hasYoinkInstalled = 0

try
    call yoink#getDefaultReg()
    let s:hasYoinkInstalled = 1
catch
endtry

function! subversive#singleMotion#preSubstitute(register, visualMap, visualMode)
    let s:activeRegister = a:register
    let s:visualMap = a:visualMap
    let s:visualMode = a:visualMode
endfunction

function! subversive#singleMotion#substituteMotion(type, ...)

    if s:visualMap
        let opMode = s:visualMode
    else
        if a:type == 'line'
            let opMode = 'V'
        else
            let opMode = 'v'
        endif
    endif

    " There might be a better way to do this but this seems to work well
    let endsWithNewLine = getreg(s:activeRegister) =~ '\v\n$'

    " We prefer to use change instead of delete and paste since change behaves much better in edge cases
    " like end/beginning of the line, or end/beginning of the file, etc.
    " Need to use paste mode to avoid auto indent etc
    let previousPaste = &paste
    set paste
    exe "normal! `" . (s:visualMap ? "<" : "[") . "\"_c" . opMode . "`" . (s:visualMap ? ">" : "]") . "\<C-R>" . s:activeRegister . (endsWithNewLine ? "\<bs>" : "") . "\<ESC>"
    let &paste=previousPaste

    " For some reason the change operation places the ] mark after the change instead of at the last
    " character of the change so let's fix this
    " This becomes visible when yoink#adjustLastChangeIfNecessary is called and g:yoinkMoveCursorToEndOfPaste 
    " is also set to true but might as well do it in all cases for consistency
    let endChangePos = getpos("']")
    let endChangePos[2] = max([0, endChangePos[2] - 1])
    call setpos("']", endChangePos)

    if s:hasYoinkInstalled && s:activeRegister == yoink#getDefaultReg()
        call yoink#adjustLastChangeIfNecessary()
        call yoink#startUndoRepeatSwap()
    endif
endfunction

function! subversive#singleMotion#substituteLineSetup(reg, count)
    let s:activeRegister = a:reg
    let s:activeCount = a:count > 0 ? a:count : 1
endfunction

function! subversive#singleMotion#substituteLine(...)
    let pasteIsMultiline = getreg(s:activeRegister) =~ '\n'
    let pasteType = "P"

    " If our paste is multiline, then delete the whole line
    " The given count applies only to the delete and not the paste
    if s:activeCount > 1 || pasteIsMultiline
        if line('.') >= line('$') - s:activeCount + 1
            let pasteType = 'p'
        endif
        exe "normal! ". s:activeCount . "\"_dd"
        if !pasteIsMultiline
            exe "normal! O\<esc>"
        endif
    else
        " If our paste is non-multiline, and count is 1, then just replace on current line
        exe "normal! 0\"_d$"
    endif

    exe "normal! \"" . s:activeRegister . pasteType

    if s:hasYoinkInstalled && s:activeRegister == yoink#getDefaultReg()
        call yoink#startUndoRepeatSwap()
    endif
endfunction

function! subversive#singleMotion#substituteToEndOfLineSetup(reg, count)
    let s:activeRegister = a:reg
    let s:activeCount = a:count > 0 ? a:count : 1
endfunction

function! subversive#singleMotion#substituteToEndOfLine(...)
    exec "normal! \"_d$\"" . s:activeRegister . s:activeCount . "p"

    if s:hasYoinkInstalled && s:activeRegister == yoink#getDefaultReg()
        call yoink#startUndoRepeatSwap()
    endif
endfunction

