
## Subversive

Provides the following:
- Substitution motion
- Substitute current line
- Substitute to end of line

No default mappings. Example config:

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

Note: Requires [vim-repeat](https://github.com/tpope/vim-repeat)

### Integration with yoink

Note that the swapping feature of [vim-yoink](https://github.com/svermeulen/nvim-yoink) will automatically work with the subsitute operations above in addition to just paste (if you have vim-yoink installed alongside vim-subversive)

