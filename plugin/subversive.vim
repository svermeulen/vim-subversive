
if exists('g:loadedSubversive')
	finish
endif
let g:loadedSubversive = 1

" --- Single motions -- 
nnoremap <silent> <plug>(SubversiveSubstitute) :<c-u>call subversive#singleMotion#preSubstitute(v:register, 0, '')<cr>:set opfunc=subversive#singleMotion#substituteMotion<cr>g@

" Here we trigger the substitute motion and explicitly use the visual mode marks, but then inside subversive#singleMotion#substituteMotion we again use the visual mode marks
" You might wonder why do we need to use < and > inside subversive#singleMotion#substituteMotion if we are already passing them here?  Won't ] and [ be set to > and < anyway?
" Yes, but for some reason they are often off by one character, so we have to use > and < there instead.  And we still continue to pass them to the opfunc here because
" that will automatically set the a:type parameter correctly
xnoremap <silent> <plug>(SubversiveSubstitute) :<c-u>call subversive#singleMotion#preSubstitute(v:register, 1, visualmode())<cr><esc>`<:set opfunc=subversive#singleMotion#substituteMotion<cr>g@`>

" Use opfunc in this case too even though we don't need to, so that it works with repeat operation
nnoremap <silent> <plug>(SubversiveSubstituteToEndOfLine) :<c-u>call subversive#singleMotion#substituteToEndOfLineSetup(v:register, v:count)<cr>:set opfunc=subversive#singleMotion#substituteToEndOfLine<cr>g@l
nnoremap <silent> <plug>(SubversiveSubstituteLine) :<c-u>call subversive#singleMotion#substituteLineSetup(v:register, v:count)<cr>:set opfunc=subversive#singleMotion#substituteLine<cr>g@l

" --- Standard double motions -- 
nnoremap <silent> <plug>(SubversiveSubstituteRange) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 0, 0, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteRange) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 0, 0, 0)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubstituteRangeDelete) :<c-u>call subversive#lineRangeMotion#preSubstitute("_", 1, 0, 0, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteRangeDelete) :<c-u>call subversive#lineRangeMotion#preSubstitute("_", 1, 0, 0, 0)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubstituteWordRange) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 0, 1, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@iw

" -- Confirm variants
nnoremap <silent> <plug>(SubversiveSubstituteRangeConfirm) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 0, 0, 1)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteRangeConfirm) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 0, 0, 1)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubstituteWordRangeConfirm) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 0, 1, 1)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@iw

" -- NoPrompt variants
nnoremap <silent> <plug>(SubversiveSubstituteRangeNoPrompt) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 0, 0, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteRangeNoPrompt) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 0, 0, 0)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubstituteWordRangeNoPrompt) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 0, 1, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@iw

" -- NoPrompt + Confirm variants
nnoremap <silent> <plug>(SubversiveSubstituteRangeNoPromptConfirm) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 0, 0, 1)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubstituteRangeNoPromptConfirm) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 0, 0, 1)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubstituteWordRangeNoPromptConfirm) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 0, 1, 1)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@iw

" -- Abolish variants
nnoremap <silent> <plug>(SubversiveSubvertRange) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 1, 0, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubvertRange) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 1, 0, 0)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubvertWordRange) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 1, 1, 1, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@iw

" -- Abolish + NoPrompt variants

nnoremap <silent> <plug>(SubversiveSubvertRangeNoPrompt) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 1, 0, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@
xnoremap <silent> <plug>(SubversiveSubvertRangeNoPrompt) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 1, 0, 0)<cr><esc>:call subversive#lineRangeMotion#selectTextMotion('char', 1)<cr>

nnoremap <silent> <plug>(SubversiveSubvertWordRangeNoPrompt) :<c-u>call subversive#lineRangeMotion#preSubstitute(v:register, 0, 1, 1, 0)<cr>:set opfunc=subversive#lineRangeMotion#selectTextMotion<cr>g@iw

" For internal use only
nnoremap <silent> <plug>(_SubversiveSubstituteRangeSecondary) :<c-u>set opfunc=subversive#lineRangeMotion#selectRangeMotion<cr>g@

