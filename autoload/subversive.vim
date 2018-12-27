
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

    echom 'a:type = ' . a:type

    if a:type ==# 'line'
        let pasteIsMultiline = getreg(s:activeRegister) =~ '\n'

        if deletedMultipleLines && !pasteIsMultiline
            " This is a bit more intuitive IMO, otherwise the lines combine
            exe "keepjump normal! O\<esc>"
        endif
    endif

    exe "keepjump normal! \"" . s:activeRegister . "P"

    exec "set virtualedit=". oldVirtualEdit
endfunction

function! subversive#checkRequiredDependencies()
    try
        call repeat#invalidate()
    catch /\VUnknown function/
        echohl ErrorMsg
        echo 'Could not find vim-repeat installed.  vim-subversive requires vim-repeat to function properly.  Please install vim-repeat and restart Vim'
        echohl None
    catch
        " Sometimes error occurs due to clearing augroup that doesn't exist
        " So just ignore this case
        " Be nice if there was a less hacky way to do this but I can't think of one
        " Checking runtimepath for vim-repeat doesn't work since not everyone uses it that way
        " and some plugin managers actually merge everything together
    endtry
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
endfunction

function! subversive#substituteToEndOfLine(reg, count)
    let count = a:count > 0 ? a:count : 1
    exec "normal! \"_d$\"" . a:reg . count . "p"
endfunction

