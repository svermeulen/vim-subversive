
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

nmap <leader>ss <plug>(SubversiveSubvertWordRange)
```

After adding this map, if we execute `<leader>s<motion1><motion2>` then enter some text into a prompt in the status bar, then the text given by `motion1` should be replaced by the text we entered in the prompt for each line provided by `motion2`.  Alternatively, we can also select `motion1` in visual mode and then hit `<leader>s<motion2>` for the same effect.

This can be very powerful. For example, you could execute `<leader>siwip` to replace all instances of the current word under the cursor that exist within the paragraph under the cursor.  Or `<leader>sl_` to replace all instances of the character under the cursor on the current line.

The `<leader>ss` mapping is used as a shortcut to replace the current word under the cursor.  This will allow you to execute `<leader>ssip` to replace the word under cursor in the current paragraph.  Note that this matches **complete** words so is different from `<leader>siwip`, which will not require that there be word boundaries on each match.

Let's see it in action:

![Substitute Over Range Example](https://i.imgur.com/gDqNAA8.gif)

In this gif, we first rename the local `foo` parameter by executing `<leader>ssom` then entering `bar` in the prompt (note that `om` is a custom motion that stands for 'outer c# method' and is not provided by this plugin).  And then we switch to visual mode select the `foo` part of `_foos` then execute `<leader>sie` and once again enter `bar` into the prompt.  `ie` is again a custom motion that stands for `entire buffer` and is simply:

```viml
" ie = inner entire buffer
onoremap ie :exec "normal! ggVG"<cr>
```

Then we move to the `Foo` part of `AddFoo` and execute `<leader>seie` and enter `Bar`.  Then finally do the same for the fully capitalized `FOOS`.

Note that to really take advantage of the substitute over range motion, it is helpful to add custom text objects in addition to just the vim built-in ones like current paragraph (`ip`), current sentence (`is`), or current line (`_`).  Custom text objects such as current indent level, current method, current class, entire buffer, current scroll page, etc. can all help a lot here.

### What if I don't want to use the prompt and want to directly replace with a register value?

If you provide an explicit register to any fo the substitute motions above it will not prompt and instead will use the contents of the given register.  For example, `"a<leader>siwip` will immediately replace all instances of the current word under the cursor with the contents of register `a` that exist within the current paragraph.

Even with support for using an explicit register, some people still find that they would prefer to avoid the prompt in favour of the default register instead.   There there are alternative plugs that can be used in this case: `<plug>(SubversiveSubvertWordRangeNoPrompt)` and `<plug>(SubversiveSubstituteRangeNoPrompt)`

## Integration With abolish.vim

If you have also installed [vim-abolish](https://github.com/tpope/vim-abolish), then you might consider adding something similar to the following mapping as well:

```viml
nmap <leader><leader>s <plug>(SubversiveSubvertRange)
xmap <leader><leader>s <plug>(SubversiveSubvertRange)
```

Here we can think of sc as 'Substitute Case-insensitive'.  This will behave the same as `<leader>s` except that it will perform an abolish 'subvert' instead of using vim's built in substitution command.  This will apply the substitution and preserve whatever case the original word has.  For example:

![Abolish Example](https://i.imgur.com/qMfYjBD.gif)

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

