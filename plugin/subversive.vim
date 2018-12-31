
if exists('g:loadedSubversive')
	finish
endif
let g:loadedSubversive = 1

try
    call repeat#invalidate()
catch /\VUnknown function/
    echoerr 'Could not find vim-repeat installed.  vim-subversive requires vim-repeat to function properly.  Please install vim-repeat and restart Vim'
    finish
catch
    " Sometimes error occur due to clearing augroup that doesn't exist
    " So just ignore this case
    " Be nice if there was a less hacky way to do this but I can't think of one
    " Checking runtimepath for vim-repeat doesn't work since not everyone uses it that way
    " and some plugin managers actually merge everything together
endtry

nnoremap <silent> <plug>(SubversiveSubstituteMotion) :<c-u>call subversive#singleMotion#onPreSubstitute(v:register, 0)<cr>:set opfunc=subversive#singleMotion#substituteMotion<cr>g@

" Here we trigger the substitute motion and explicitly use the visual mode marks, but then inside subversive#singleMotion#substituteMotion we again use the visual mode marks
" You might wonder why do we need to use < and > inside subversive#singleMotion#substituteMotion if we are already passing them here?  Won't ] and [ be set to > and < anyway?
" Yes, but for some reason they are often off by one character, so we have to use > and < there instead.  And we continue to pass them to the opfunc here because
" that will automatically set the a:type parameter correctly
xnoremap <silent> <plug>(SubversiveSubstituteMotion) <esc>`<:<c-u>call subversive#singleMotion#onPreSubstitute(v:register, 1)<cr>:set opfunc=subversive#singleMotion#substituteMotion<cr>g@`>
nnoremap <silent> <plug>(SubversiveSubstituteToEndOfLine) :<c-u>call subversive#singleMotion#substituteToEndOfLine(v:register, v:count)<cr>:call repeat#set("\<plug>(SubversiveSubstituteToEndOfLine)")<cr>
nnoremap <silent> <plug>(SubversiveSubstituteLine) :<c-u>call subversive#singleMotion#substituteLine(v:register, v:count)<cr>:call repeat#set("\<plug>(SubversiveSubstituteLine)")<cr>

nnoremap <silent> <plug>(SubversiveSubstituteOverRangeMotion) :call subversive#doubleMotion#preSubstitute()<cr>:set opfunc=subversive#doubleMotion#selectTextMotion<cr>g@
