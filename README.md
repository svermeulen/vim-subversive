
## Subversive

This vim plugin provides two new operator motions to make quick substitutions very easy.  It contains no default mappings and will have no affect until you add your own maps to it.

## Substitution Motion

Example config:

```
" s for substitute
nmap s <plug>(SubversiveSubstituteMotion)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)
```

Or possibly:
```
" r for replace
nmap r <plug>(SubversiveSubstituteMotion)
nmap rr <plug>(SubversiveSubstituteLine)
nmap R <plug>(SubversiveSubstituteToEndOfLine)
```

After adding these maps, you can then execute `s<motion>` to substitute the text object provided by the motion with the contents of the default register (or an explicit register if provided)

## Substitution Over Range Motion

Another interesting feature of subversive is support for specifying both the text to replace and the line range over which to apply the change by using multiple consecutive motions.

Example config:

```
nmap <leader>s <plug>(SubversiveSubstituteOverRangeMotion)
xmap <leader>s <plug>(SubversiveSubstituteOverRangeMotion)
```

After adding this map, if we execute `<leader>s<motion1><motion2>`, then the text given by `motion1` should be replaced by the contents of the default register (or an explicit register if provided) in each line provided by `motion2`.  Or we can select `motion` in visual mode and then hit `<leader>s<motion2>`

This can be very powerful. For example, you could execute `<leader>siwip` to replace all instances of the current word under the cursor that exist within the paragraph under the cursor.  Or `<leader>sl_` to replace all instances of the character under the cursor on the current line.

Or, you could add a text object for the entire contents of the buffer like this:

```
" ie = inner entire buffer
onoremap if :exec "normal! ggVG"<cr>
```

And then execute `<leader>siwie` to replace all instances of the current word under the cursor in the entire buffer.

You'll often also want to perform a substitution with some new text (rather than always taking from the default register) which you can do with the following map:

```
nmap <leader>sp <plug>(SubversiveSubstituteOverRangeMotionWithPrompt)
xmap <leader>sp <plug>(SubversiveSubstituteOverRangeMotionWithPrompt)
```

This will behave similar to `<leader>s` except that instead of substituting with the contents of the given register, it will display a prompt in the status bar to provide the new text to use instead.  Note that we assume here that `p` does not have another meaning in operator mode (otherwise we will shadow that functionality when starting with `<leader>s`).

### Integration with yoink

Note that if you install [vim-yoink](https://github.com/svermeulen/vim-yoink) alongside vim-subversive, then the post-paste yoink swapping feature will automatically work with subversive single motion substitutions as well.

If you want to enable yoink swapping with visual mode pastes as well you can do that with the following map:

```viml
xmap s <plug>(SubversiveSubstituteMotion)
xmap p <plug>(SubversiveSubstituteMotion)
xmap P <plug>(SubversiveSubstituteMotion)
```

Now if you hit `p` while in visual mode you can cycle between pastes just like when pasting in normal mode.
