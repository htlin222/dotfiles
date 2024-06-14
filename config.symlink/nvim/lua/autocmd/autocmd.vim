let g:ovff = v:false

au BufWinEnter * set shm+=I

augroup ChangeAfterIM
  autocmd!
  autocmd InsertLeavePre * call ABC()
augroup END

augroup ChangeBeforeIM
  autocmd!
  autocmd InsertEnter * call OVFF()
augroup END

function ABC() " im-select, to switch input method to ABC
  let l:im_select_output = system('im-select')
  if match(l:im_select_output, 'ABC') == -1
    let g:ovff = v:true
    call system('im-select com.apple.keylayout.ABC')
  else
    let g:ovff = v:false
  endif
  let l:output = system('fcitx5-remote')
  let l:output = substitute(l:output, '\n', '', 'g')
  if l:output == '1'
    let g:ovff = v:true
    call system('fcitx5-remote -t')
  else
    let g:ovff = v:false
  endif
endfunction

function OVFF()
  if g:ovff
    call system('fcitx5-remote -t')
    call system('im-select com.boshiamy.inputmethod.BoshiamyIMK')
  endif
endfunction

" im-select com.apple.keylayout.ABC

