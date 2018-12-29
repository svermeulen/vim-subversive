
let s:activeRegister = ''

try
    call yoink#getDefaultReg()
    let s:hasYoinkInstalled = 1
catch /\VUnknown function/
    let s:hasYoinkInstalled = 0
endtry

function! subversive#onPreSubstitute(register)
    let s:activeRegister = a:register
endfunction

function! subversive#substituteMotion(type, ...)

    if &selection ==# 'exclusive'
        let exclRight = "\<right>"
    else
        let exclRight = ""
    endif

    let oldVirtualEdit=&virtualedit
    set virtualedit=onemore
    let deletedMultipleLines = 0

    " use keepjumps since we only want to change jumplist
    " if it's multiline
    if a:type ==# 'line'
        let selectKeys = "'[V']"
        let deletedMultipleLines = line("'[") != line("']")
    elseif a:type ==# 'char'
        let selectKeys = "`[v`]"
    else
        echom "Unexpected selection type"
        exec "set virtualedit=". oldVirtualEdit
        return
    endif

    exe "keepjump normal! " . selectKeys . exclRight . "\"_d"

    if a:type ==# 'line'
        let pasteIsMultiline = getreg(s:activeRegister) =~ '\n'

        if deletedMultipleLines && !pasteIsMultiline
            " This is a bit more intuitive IMO, otherwise the lines combine
            exe "keepjump normal! O\<esc>"
        endif
    endif

    exe "normal! \"" . s:activeRegister . "P"
    exec "set virtualedit=". oldVirtualEdit

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

