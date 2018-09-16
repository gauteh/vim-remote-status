# Git Remote status for statusline (e.g. Flagship)

Adds a remote status for your GIT branch for [vim-flagship](https://github.com/tpope/vim-flagship). Requires [vim-fugitive](https://github.com/tpope/vim-fugitive).

If using vim-flagship:

```
  autocmd User Flags call Hoist("buffer", 1, "GitRemoteStatus")
```

If you want to try automatically fetching the remote try:

```
  let g:remote_status_auto_update = 1
```

<img src="remote-status.png"></img>

For more help see `:help [remote-status](doc/remote-status.txt)`.


