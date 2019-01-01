
# Subversive

Subversive provides two new operator motions to make quick substitutions very easy.  It contains no default mappings and will have no affect until you add your own maps to it.

## Substitution Motion

Example config:

```viml
" s for substitute
nmap s <plug>(SubversiveSubstituteMotion)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)
```

Note that in this case you will be shadowing the change character key `s` so you would have to use the longer form `cl`

After adding these maps, you can then execute `s<motion>` to substitute the text object provided by the motion with the contents of the default register (or an explicit register if provided)

## Substitution Over Range Motion

Another interesting operator provided by subversive allows specifying both the text to replace and the line range over which to apply the change by using multiple consecutive motions.

Example config:

```viml
nmap <leader>s <plug>(SubversiveSubstituteOverRangeMotion)
xmap <leader>s <plug>(SubversiveSubstituteOverRangeMotion)
```

After adding this map, if we execute `<leader>s<motion1><motion2>`, then enter some text into a prompt in the status bar, then the text given by `motion1` should be replaced by the text we entered for each line provided by `motion2`.  Alternatively, we can also select `motion1` in visual mode and then hit `<leader>s<motion2>` for the same effect.

This can be very powerful. For example, you could execute `<leader>siwip` to replace all instances of the current word under the cursor that exist within the paragraph under the cursor.  Or `<leader>sl_` to replace all instances of the character under the cursor on the current line.

Or, you could add a text object for the entire contents of the buffer like this:

```viml
" ie = inner entire buffer
onoremap if :exec "normal! ggVG"<cr>
```

And then execute `<leader>siwie` to replace all instances of the current word under the cursor in the entire buffer.

You can also avoid the prompt by explicitly providing a register to use to pull the replacement text from.  For example, `"a<leader>siwip` will immediately replace all instances of the current word under the cursor with the contents of register `a` that exist within the current paragraph.

If instead you want to always use registers and never prompt, you can do that to by using the NoPrompt plug variants:

```viml
nmap <leader>s <plug>(SubversiveSubstituteOverRangeMotionNoPrompt)
xmap <leader>s <plug>(SubversiveSubstituteOverRangeMotionNoPrompt)
```

In this case, it will always use the default register instead of prompting when an explicit register is not given.

You might also consider adding a shortcut for the current word under the cursor, if it is a common operation. For example:

```viml
nmap <leader>ss <plug>(SubversiveSubstituteOverRangeMotion)iw
```

This will allow us to just execute `<leader>ssip` rather than `<leader>siwip`

## Integration With abolish.vim

If you have also installed [vim-abolish](https://github.com/tpope/vim-abolish), then you might consider adding something similar to the following mapping as well:

```viml
nmap <leader>sc <plug>(SubversiveSubvertOverRangeMotion)
xmap <leader>sc <plug>(SubversiveSubvertOverRangeMotion)
```

Here we can think of sc as 'Substitute Case-insensitive'.  This will behave the same as `<leader>s` except that it will perform an abolish 'subvert' instead of using vim's built in substitution command.  This will allow the replace to apply regardless of case.  For example, given the following text:

```csharp
class FooManager
{
    static int MAX_FOOS = 3;

    List<^Foo> _foos = new List<Foo>();

    public void AddFoo(Foo foo)
    {
        if (_foos.Count >= MAX_FOOS)
        {
            throw new Exception("Too many foos");
        }

        _foos.Add(foo);
    }
}
```

Assuming our cursor is at the `^` character, if we execute `<leader>sceie` (assuming we've also added the `ie` operator from above) then enter `Bar` then our file becomes:

```csharp
class BarManager
{
    static int MAX_BARS = 3;

    List<^Bar> _bars = new List<Bar>();

    public void AddBar(Bar bar)
    {
        if (_bars.Count >= MAX_BARS)
        {
            throw new Exception("Too many bars");
        }

        _bars.Add(bar);
    }
}
```

This can be a very convenient way to perform quick renames.

Note that there is also a NoPrompt variation of this plug as well if you prefer that:

```viml
nmap <leader>sc <plug>(SubversiveSubvertOverRangeMotionNoPrompt)
xmap <leader>sc <plug>(SubversiveSubvertOverRangeMotionNoPrompt)
```

### Integration with yoink

Note that if you install [vim-yoink](https://github.com/svermeulen/vim-yoink) alongside vim-subversive, then the post-paste yoink swapping feature will automatically work with subversive single motion substitutions as well.

If you want to enable yoink swapping with visual mode pastes as well you can do that with the following map:

```viml
xmap s <plug>(SubversiveSubstituteMotion)
xmap p <plug>(SubversiveSubstituteMotion)
xmap P <plug>(SubversiveSubstituteMotion)
```

Now if you hit `p` while in visual mode you can cycle between pastes just like when pasting in normal mode.

## Other Notes

- Note that to really take advantage of the substitute over range motion above, it is helpful to add custom text objects in addition to just the vim built-in ones like current paragraph (`ip`), current sentence (`is`), or current line (`_`).  Custom text objects such as current indent level, current method, current class, entire buffer, current scroll page, etc. can all help a lot here.

