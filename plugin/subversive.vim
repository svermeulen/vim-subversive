
if exists('g:loadedSubversive')
	finish
endif
let g:loadedSubversive = 1

augroup subversive_checkdependencies
    autocmd!
    autocmd VimEnter * call subversive#checkRequiredDependencies()
augroup END

" This should automatically be repeatable
nnoremap <silent> <plug>(SubversiveSubstituteMotion) :<c-u>call subversive#onPreSubstitute(v:register)<cr>:set opfunc=subversive#substituteMotion<cr>g@
nnoremap <silent> <plug>(SubversiveSubstituteToEndOfLine) :<c-u>call subversive#substituteToEndOfLine(v:register, v:count)<cr>:call repeat#set("\<plug>(SubversiveSubstituteToEndOfLine)")<cr>
nnoremap <silent> <plug>(SubversiveSubstituteLine) :<c-u>call subversive#substituteLine(v:register, v:count)<cr>:call repeat#set("\<plug>(SubversiveSubstituteLine)")<cr>

