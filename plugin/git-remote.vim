" Gets the remote / local status for a given branch.
"
" This assumes that git remote update or git fetch has been run.
"
" based on: https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

function s:UpdateStatus()
  if !exists("b:git_dir")
    " set by Fugitive, not in GIT repo
    let b:git_status = ''
    return ''
  endif

  let g:remote_status_auto_update = get (g:, 'remote_status_auto_update', 0)
  let g:remote_status_update_interval = get (g:, 'remote_status_update_interval', 60)

  let b:lastupdate = get (b:, 'lastupdate', 0)
  if g:remote_status_auto_update
    if (localtime () - b:lastupdate) >= g:remote_status_update_interval
      let b:job = job_start ('git remote update')
      let b:lastupdate = localtime()
    endif
  endif

  let local_branch    = '@'
  let upstream_branch = '@{u}'

  try
    let local  = fugitive#RevParse (local_branch)
    let remote = fugitive#RevParse (upstream_branch)
    let base   = system ('git merge-base ' . local_branch . ' ' . upstream_branch)[0:-2]


    if local == remote
      let status = get (g:, 'remote_status_uptodate', '👌')
    elseif local == base
      let status = get (g:, 'remote_status_pull', '↓')
    elseif remote == base
      let status = get (g:, 'remote_status_push', '↑')
    else
      let status = get (g:, 'remote_status_diverged', '↕')
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
    let status = s:UpdateStatus ()

    au BufWritePost <buffer> call s:UpdateStatus()
    au BufReadPost  <buffer> call s:UpdateStatus()
    au BufWinEnter  <buffer> call s:UpdateStatus()
    au BufEnter     <buffer> call s:UpdateStatus()
    au FocusGained  <buffer> call s:UpdateStatus()

  else
    let status = b:git_status
  endif

  return status
endfunction

