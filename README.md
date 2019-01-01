
# Subversive

Subversive provides two new operator motions to make it very easy to perform quick substitutions.  It contains no default mappings and will have no affect until you add your own maps to it.

## Substitution Motion

Example config:

```viml
" s for substitute
nmap s <plug>(SubversiveSubstitute)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)
```

Note that in this case you will be shadowing the change character key `s` so you will have to use the longer form `cl`

After adding these maps, you can then execute `s<motion>` to substitute the text object provided by the motion with the contents of the default register (or an explicit register if provided)

## Substitution Over Range Motion

Another interesting operator provided by subversive allows specifying both the text to replace and the line range over which to apply the change by using multiple consecutive motions.

Example config:

```viml
nmap <leader>s <plug>(SubversiveSubstituteRange)
xmap <leader>s <plug>(SubversiveSubstituteRange)
```

After adding this map, if we execute `<leader>s<motion1><motion2>`, then enter some text into a prompt in the status bar, then the text given by `motion1` should be replaced by the text we entered for each line provided by `motion2`.  Alternatively, we can also select `motion1` in visual mode and then hit `<leader>s<motion2>` for the same effect.

This can be very powerful. For example, you could execute `<leader>siwip` to replace all instances of the current word under the cursor that exist within the paragraph under the cursor.  Or `<leader>sl_` to replace all instances of the character under the cursor on the current line.

Or, you could add a text object for the entire contents of the buffer like this:

```viml
" ie = inner entire buffer
onoremap ie :exec "normal! ggVG"<cr>
```

And then execute `<leader>siwie` to replace all instances of the current word under the cursor in the entire buffer.  Or `<leader>siwgg` to replace only those instances at or before the cursor position.  Etc.

You can also avoid the prompt by explicitly providing a register to use to pull the replacement text from.  For example, `"a<leader>siwip` will immediately replace all instances of the current word under the cursor with the contents of register `a` that exist within the current paragraph.

You might also consider adding a shortcut for the current word under the cursor:

```viml
nmap <space>ss <plug>(SubversiveSubvertWordRange)
```

This will allow you to just execute `<leader>ssip` to replace the word under cursor in the current paragraph.  Note that this matches **complete** words so is different from `<leader>siwip`.  Given `foo` underneath the cursor, the latter would replace the foo in `foobar` but the former would not (because there isn't a word boundary)

Note that to really take advantage of the substitute over range motion, it is helpful to add custom text objects in addition to just the vim built-in ones like current paragraph (`ip`), current sentence (`is`), or current line (`_`).  Custom text objects such as current indent level, current method, current class, entire buffer, current scroll page, etc. can all help a lot here.

Some people find that they prefer to avoid the prompt entirely in favour of just always using the default register instead (unless an explicit register is provided).  The plugs `<plug>(SubversiveSubvertWordRangeNoPrompt)` and `<plug>(SubversiveSubstituteRangeNoPrompt)` can be used instead of the above ones if this is your preference.

## Integration With abolish.vim

If you have also installed [vim-abolish](https://github.com/tpope/vim-abolish), then you might consider adding something similar to the following mapping as well:

```viml
nmap <leader><leader>s <plug>(SubversiveSubvertRange)
xmap <leader><leader>s <plug>(SubversiveSubvertRange)
```

Here we can think of sc as 'Substitute Case-insensitive'.  This will behave the same as `<leader>s` except that it will perform an abolish 'subvert' instead of using vim's built in substitution command.  This will apply the substitution and preserve whatever case the original word has.  For example:

![Abolish Example](https://i.imgur.com/qMfYjBD.gifv)

In this case, we move the cursor overtop `foo` and then execute `<leader><leader>seie` then enter `bar`, which replaces all instances of `foo` regardless of case.

This can be a very convenient way to perform quick renames.

Note that similar to the normal substitute plug there is one that matches complete words as well, which you might bind like this:

```viml
nmap <leader><leader>ss <plug>(SubversiveSubvertWordRange)
```

Note that there are also 'NoPrompt' variations of the subvert plugs as well if you prefer those: `<plug>(SubversiveSubvertRangeNoPrompt)` and `<plug>(SubversiveSubvertWordRangeNoPrompt)`

### Integration with yoink

Note that if you install [vim-yoink](https://github.com/svermeulen/vim-yoink) alongside vim-subversive, then the post-paste yoink swapping feature will automatically work with subversive (single motion) substitutions as well.  In other words, assuming the default mappings, you can execute `siw` then hit `<c-n>` / `<c-p>` to swap between different yanks.

Subversive also provides a plug to replace visual mode paste to provide post past swapping as well:

```viml
xmap s <plug>(SubversiveSubstitute)
xmap p <plug>(SubversiveSubstitute)
xmap P <plug>(SubversiveSubstitute)
```

Now if you hit `p` while in visual mode you can swap between yanks just like when pasting in normal mode.

