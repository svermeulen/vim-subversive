
if exists('g:loadedSubversive')
	finish
endif
let g:loadedSubversive = 1

nnoremap <silent> <plug>(SubversiveSubstituteMotion) :<c-u>call subversive#singleMotion#preSubstitute(v:register, 0)<cr>:set opfunc=subversive#singleMotion#substituteMotion<cr>g@

" Here we trigger the substitute motion and explicitly use the visual mode marks, but then inside subversive#singleMotion#substituteMotion we again use the visual mode marks
" You might wonder why do we need to use < and > inside subversive#singleMotion#substituteMotion if we are already passing them here?  Won't ] and [ be set to > and < anyway?
" Yes, but for some reason they are often off by one character, so we have to use > and < there instead.  And we still continue to pass them to the opfunc here because
" that will automatically set the a:type parameter correctly
xnoremap <silent> <plug>(SubversiveSubstituteMotion) :<c-u>call subversive#singleMotion#preSubstitute(v:register, 1)<cr><esc>`<:set opfunc=subversive#singleMotion#substituteMotion<cr>g@`>

" Use opfunc in this case too even though we don't need to, so that it works with repeat operation
nnoremap <silent> <plug>(SubversiveSubstituteToEndOfLine) :<c-u>call subversive#singleMotion#substituteToEndOfLineSetup(v:register, v:count)<cr>:set opfunc=subversive#singleMotion#substituteToEndOfLine<cr>g@l
nnoremap <silent> <plug>(SubversiveSubstituteLine) :<c-u>call subversive#singleMotion#substituteLineSetup(v:register, v:count)<cr>:set opfunc=subversive#singleMotion#substituteLine<cr>g@l

nnoremap <silent> <plug>(SubversiveSubstituteOverRangeMotion) :<c-u>call subversive#doubleMotion#preSubstitute(v:register, 0)<cr>:set opfunc=subversive#doubleMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteOverRangeMotion) :<c-u>call subversive#doubleMotion#preSubstitute(v:register, 0)<cr><esc>:call subversive#doubleMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubstituteOverRangeMotionWithPrompt) :<c-u>call subversive#doubleMotion#preSubstitute(v:register, 1)<cr>:set opfunc=subversive#doubleMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteOverRangeMotionWithPrompt) :<c-u>call subversive#doubleMotion#preSubstitute(v:register, 1)<cr><esc>:call subversive#doubleMotion#selectTextMotion('char', 1)<cr>

" For internal use only
nnoremap <silent> <plug>(_SubversiveSubstituteOverAreaMotionRange) :<c-u>set opfunc=subversive#doubleMotion#selectRangeMotion<cr>g@

