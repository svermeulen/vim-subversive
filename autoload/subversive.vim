
let s:activeRegister = ''

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

    exec "set virtualedit=". oldVirtualEdit

    if g:subversiveIntegrateWithYoink && s:activeRegister == yoink#getDefaultReg()
        " We need to start the paste as a distinct operation here so that undo applies to it only
        call feedkeys("\<plug>(YoinkPaste_P)", 'tm')
    else
        exe "normal! \"" . s:activeRegister . "P"
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

    if g:subversiveIntegrateWithYoink && a:reg == yoink#getDefaultReg()
        " We need to start the paste as a distinct operation here so that undo applies to it only
        call feedkeys("\<plug>(YoinkPaste_P)", 'tm')
    else
        exe "normal! \"" . a:reg . "P"
    endif
endfunction

function! subversive#substituteToEndOfLine(reg, count)
    let count = a:count > 0 ? a:count : 1
    exec "normal! \"_d$"

    if g:subversiveIntegrateWithYoink && a:reg == yoink#getDefaultReg()
        " We need to start the paste as a distinct operation here so that undo applies to it only
        call feedkeys(count . "\<plug>(YoinkPaste_p)", 'tm')
    else
        exec "normal! \"" . a:reg . count . "p"
    endif
endfunction

