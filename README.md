
## Subversive

Provides the following:
- Substitution motion
- Substitute current line
- Substitute to end of line

No default mappings. Example config:

```
" r for replace
nmap r <plug>(SubversiveSubstituteMotion)
nmap rr <plug>(SubversiveSubstituteLine)
nmap R <plug>(SubversiveSubstituteToEndOfLine)
```

Or possibly:
```
" s for subtitute
nmap s <plug>(SubversiveSubstituteMotion)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)
```

Note: Requires [vim-repeat](https://github.com/tpope/vim-repeat)

