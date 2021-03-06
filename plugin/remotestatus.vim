" Gets the remote / local status for a given branch.
"
" based on: https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

function! remotestatus#UpdateStatusHandler(channel)
  call remotestatus#UpdateStatus (v:true)
  redrawstatus
  return
endfunction

function! remotestatus#UpdateStatus(in_cb)
  if !exists("b:git_dir")
    " set by Fugitive, not in GIT repo
    let b:git_status = ''
    return ''
  endif

  let g:remote_status_auto_update = get (g:, 'remote_status_auto_update', 0)
  let g:remote_status_update_interval = get (g:, 'remote_status_update_interval', 60)

  let b:lastupdate = get (b:, 'lastupdate', 0)
  if !a:in_cb
    if g:remote_status_auto_update
      if (localtime () - b:lastupdate) >= g:remote_status_update_interval
        if exists("b:remote_status_job") && job_status(b:remote_status_job) == "run"
          " job already running
          let b:lastupdate = localtime()
        else
          let b:remote_status_job = job_start ('git remote update', { "cwd" : b:git_dir, "close_cb" : "remotestatus#UpdateStatusHandler"})
        endif
      endif
    endif
  else
    let b:lastupdate = localtime()
  endif

  let local_branch    = '@'
  let upstream_branch = '@{u}'

  if get (g:, 'webdevicons_enable', 0) || get (g:, 'remote_status_nerd_font', 0)
    let s_uptodate =  get (g:, 'remote_status_uptodate', '👌')
    let s_pull =      get (g:, 'remote_status_pull', '↓')
    let s_push =      get (g:, 'remote_status_push', '↑')
    let s_diverged =  get (g:, 'remote_status_diverged', '↕')
    let s_updating =  get (g:, 'remote_status_upating', '%')
  else
    let s_uptodate =  get (g:, 'remote_status_uptodate', 'OK')
    let s_pull =      get (g:, 'remote_status_pull', 'PL')
    let s_push =      get (g:, 'remote_status_push', 'PS')
    let s_diverged =  get (g:, 'remote_status_diverged', 'DV')
    let s_updating =  get (g:, 'remote_status_upating', '%')
  endif

  if exists("b:remote_status_job") && job_status(b:remote_status_job) == "run"
    let b:git_status = s_updating
    return b:git_status
  endif

  try
    let local  = fugitive#RevParse (local_branch)
    let remote = fugitive#RevParse (upstream_branch)
    let base   = system ('git merge-base ' . local_branch . ' ' . upstream_branch)[0:-2]


    if local == remote
      let status = s_uptodate
    elseif local == base
      let status = s_pull
    elseif remote == base
      let status = s_push
    else
      let status = s_diverged
    endif

  catch /^fugitive:/
    let status = ''
  finally
    let b:git_status = status
  endtry

  return status
endfunction

function! GitRemoteStatus()
  if !exists('b:git_status')
    let status = remotestatus#UpdateStatus (v:false)

    au BufWritePost <buffer> call remotestatus#UpdateStatus(v:false)
    au BufReadPost  <buffer> call remotestatus#UpdateStatus(v:false)
    " au BufWinEnter  <buffer> call remotestatus#UpdateStatus(v:false)
    " au BufEnter     <buffer> call remotestatus#UpdateStatus(v:false)
    " au FocusGained  <buffer> call remotestatus#UpdateStatus(v:false)

    au BufReadPost  index    call remotestatus#UpdateStatus(v:false)

  else
    let status = b:git_status
  endif

  return status
endfunction

