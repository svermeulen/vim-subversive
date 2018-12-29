
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

nnoremap <silent> <plug>(SubversiveSubstituteMotion) :<c-u>call subversive#onPreSubstitute(v:register)<cr>:set opfunc=subversive#substituteMotion<cr>g@
nnoremap <silent> <plug>(SubversiveSubstituteToEndOfLine) :<c-u>call subversive#substituteToEndOfLine(v:register, v:count)<cr>:call repeat#set("\<plug>(SubversiveSubstituteToEndOfLine)")<cr>
nnoremap <silent> <plug>(SubversiveSubstituteLine) :<c-u>call subversive#substituteLine(v:register, v:count)<cr>:call repeat#set("\<plug>(SubversiveSubstituteLine)")<cr>

