
let s:activeRegister = ''
let s:savedStartPos = []
let s:savedEndPos = []
let s:visualMode = 0

try
    call yoink#getDefaultReg()
    let s:hasYoinkInstalled = 1
catch /\VUnknown function/
    let s:hasYoinkInstalled = 0
endtry

function! subversive#singleMotion#preSubstitute(register, visualMode)
    let s:activeRegister = a:register
    let s:visualMode = a:visualMode
endfunction

function! subversive#singleMotion#substituteMotion(type, ...)

    let opMode = 'v'

    if a:type == 'line'
        let opMode = 'V'
    endif

    " There might be a better way to do this but this seems to work well
    let endsWithNewLine = getreg(s:activeRegister) =~ '\v\n$'

    " We prefer to use change instead of delete and paste since change behaves much better in edge cases
    " like end/beginning of the line, or end/beginning of the file, etc.
    " Need to use paste mode to avoid auto indent etc
    let previousPaste = &paste
    set paste
    exe "normal! `" . (s:visualMode ? "<" : "[") . "\"_c" . opMode . "`" . (s:visualMode ? ">" : "]") . "\<C-R>" . s:activeRegister . (endsWithNewLine ? "\<bs>" : "") . "\<ESC>"
    let &paste=previousPaste

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

    " If our paste is multiline, then delete the whole line
    " The given count applies only to the delete and not the paste
    if s:activeCount > 1 || pasteIsMultiline
        exe "normal! ". s:activeCount . "\"_dd"
        if !pasteIsMultiline
            exe "normal! O\<esc>"
        endif
    else
        " If our paste is non-multiline, and count is 1, then just replace on current line
        exe "normal! 0\"_d$"
    endif

    exe "normal! \"" . s:activeRegister . "P"

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

