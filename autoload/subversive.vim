
let s:activeRegister = ''
let s:isFirstMotion = 0
let s:savedStartPos = []
let s:savedEndPos = []

try
    call yoink#getDefaultReg()
    let s:hasYoinkInstalled = 1
catch /\VUnknown function/
    let s:hasYoinkInstalled = 0
endtry

function! subversive#onPreSubstitute(register)
    let s:activeRegister = a:register
    let s:isFirstMotion = 1
endfunction

function! subversive#substituteMotion(type, ...)

    let opMode = 'v'

    if a:type == 'line'
        let opMode = 'V'
    endif

    if s:isFirstMotion
        let s:savedStartPos = getpos("'[")
        let s:savedEndPos = getpos("']")
        let s:isFirstMotion = 0
    else
        " Necessary for when executing repeat after an undo (like with yoink)
        call setpos("'[", s:savedStartPos)
        call setpos("']", s:savedEndPos)
    endif

    let previousPaste = &paste
    set paste
    exe "normal! `[\"_c" . opMode . "`]\<C-R>" . s:activeRegister . "\<ESC>"
    let &paste=previousPaste

    if s:hasYoinkInstalled && s:activeRegister == yoink#getDefaultReg()
        call yoink#startUndoRepeatSwap()
    endif
endfunction

function! subversive#substituteLine(reg, count)
    let count = a:count > 0 ? a:count : 1
    let pasteIsMultiline = getreg(a:reg) =~ '\n'

    " If our paste is multiline, then delete the whole line
    " The given count applies only to the delete and not the paste
    if count > 1 || pasteIsMultiline
        exe "normal! ". count . "\"_dd"
        if !pasteIsMultiline
            exe "normal! O\<esc>"
        endif
    else
        " If our paste is non-multiline, and count is 1, then just replace on current line
        exe "normal! 0\"_d$"
    endif

    exe "normal! \"" . a:reg . "P"

    if s:hasYoinkInstalled && a:reg == yoink#getDefaultReg()
        call yoink#startUndoRepeatSwap()
    endif
endfunction

function! subversive#substituteToEndOfLine(reg, count)
    let count = a:count > 0 ? a:count : 1
    exec "normal! \"_d$\"" . a:reg . count . "p"

    if s:hasYoinkInstalled && a:reg == yoink#getDefaultReg()
        call yoink#startUndoRepeatSwap()
    endif
endfunction

