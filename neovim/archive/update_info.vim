augroup CheckTime
    autocmd!
    autocmd BufWritePost *.py call CheckAndUpdateDate()
    autocmd BufWritePost *.md call CheckAndUpdateDate()
augroup END

function! CheckAndUpdateDate()
  if search("date: '\\d\\{4\\}-\\d\\{2\\}-\\d\\{2\\}'")
    let current_date = strftime("%Y-%m-%d")
    let update_date = system("grep -oP '(?<=date: ).*' ".expand("%:p"))
    if update_date != ''
        execute ":%s/date: .*$/date: '".current_date. "'"
    endif
  else
  endif
endfunction

function! CheckDate()
endfunction
