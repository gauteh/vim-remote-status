# Git Remote status for statusline (e.g. Flagship)

Adds a remote status for your GIT branch for [vim-flagship](https://github.com/tpope/vim-flagship). Requires [vim-fugitive](https://github.com/tpope/vim-fugitive).

If using vim-flagship:

```
  autocmd User Flags call Hoist("buffer", 1, "GitRemoteStatus")
```


You can use the GitRemoteStatus() function in your own statusline: >

```
  :echo call GitRemoteStatus()
```

If you want to try automatically fetching the remote try:

```
  let g:remote_status_auto_update = 1
```

<img src="remote-status.png"></img>

The icons are UTF symbols, which will be used if g:webdevicons_enabled is 1 or
g:remote_status_nerd_font is set to 1. See vim-devicons or nerdfonts for more
information. See docs on how to set them manually.

For more help see [`:help remote-status`](doc/remote-status.txt).


