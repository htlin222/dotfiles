augroup filetype_vimwiki
    autocmd!
    autocmd FileType markdown nnoremap <silent><leader>wp :call PandocCite()<CR>
    autocmd FileType markdown xnoremap <silent><leader>wx :call ReplaceSpace()<CR>
    autocmd FileType markdown nnoremap <silent><leader>wk :call Remark()<CR>
augroup END

command! Slug call Slug()
function! Slug()
  let l:python_arg = expand('%:t:r')
  " Run the Python script and save the output to a variable
  " let l:output = system("$HOME/.pyenv/versions/automator/bin/python $HOME/Dropbox/scripts/slug.py '" . l:python_arg . "'")
  2put =l:output
endfunction
command! Pandoc call PandocCite()
function PandocCite()
  :silent !pandoc --citeproc --bibliography="$HOME/Zotero/zotero_main.bib" -s -t gfm --csl="$HOME/Zotero/styles/american-mejical-association.csl" "%" -o "%"
  :silent !sed -i "" 's/\\\[/[/g' "%"
  :silent !sed -i "" 's/\\\]/]/g' "%"
  :silent !sed -i "" 's/\\//g' "%"
  call ExportToHtml()
endfunction
function! Recruit()
  " Check if current buffer is a .md file
  if expand('%:e') == 'md'
    write
    let filepath = expand('%:p')
    let command = 'python ~/Dropbox/scripts/recruit.py ' . filepath
    call system(command)
    echo "⏪︎反轉術式發動⏪︎"
    edit

  else
    echo "Current buffer is not a Markdown file."
  endif
endfunction
function! SplitByH2()
  " Check if current buffer is a .md file
  write
  if expand('%:e') == 'md'
    let filepath = expand('%:p')
    let command = 'python3 ~/pyscripts/split_by_h2.py "' . filepath . '"'
    call system(command)
    echohl Blue
    echom '🤞領域展開✨領域展開🤞'
    echom '✨ むりょうくうきょ ✨'
    echohl None
    edit
  else
    echo "Current buffer is not a Markdown file."
  endif
endfunction
function! ExportToHtml()
  " Check if current buffer is a .md file
  if expand('%:e') == 'md'
    let filepath = expand('%:p')
    let filename = fnamemodify(filepath, ':t:r')
    let output_path = expand('~/Downloads/') . filename . '.html'
    let command = 'pandoc --standalone ' . filepath . ' -o ' . output_path
    call system(command)
    let open_command = 'open ' . output_path
    echo "Export to Html"
    call system(open_command)

  else
    echo "Current buffer is not a Markdown file."
  endif
endfunction
command! ReplaceSpace call ReplaceSpace()
function! ReplaceSpace()
    exec ':s/\%V\W/-/g'
endfunction
command! Recent call Recent()
function! Recent()
    silent exec ':!python3 $HOME/Dropbox/scripts/gen_recent_list.py'
    :vsp $HOME/Dropbox/Medical/recent.md
endfunction
command! Remark call Remark()
function Remark()
  :silent !npx remark "%" -o
  :silent !sed -i "" 's/\\\[/[/g' "%"
  :silent !sed -i "" 's/\\\]/]/g' "%"
  :silent !sed -i "" 's/\\//g' "%"
endfunction
command! Inbox silent call Inbox()
function Inbox()
  silent exec '!python3 $HOME/Drobpox/scripts/gen_inbox_list.py'
  set filetype=markdown
  :vsp $HOME/Drobpox/inbox/inbox.md
endfunction
command! AddSnippet silent call Trigger()
function Trigger()
  silent exec '!python3 scripts/note_espanso.py'
endfunction
command! AddTag call AddTag()
function! AddTag()
  let file = expand('%:p')
  let tag = input("Enter tag: ")
  let cmd = "python ~/Dropbox/scripts/addtag.py --file='" . file . "' --tag='" . tag . "'"
  let output = system(cmd)
  echo output
  if output == "Added tag '" . tag . "' to file '" . file . "'\n"
    e
  endif
endfunction
command! Explain call Explain()
function! Explain()
  let file = expand('%:p')
  let cmd = "python $HOME/Documents/Medical/scripts/explain.py --file='" . file . "'"
  let output = system(cmd)
  echo output
  if output == "done"
    e
  endif
endfunction

autocmd BufNewFile  *.md
  \ if getline(1) !~ '^---$' |
  \     call append(0,[
  \     "# " . split(expand('%:r'),'/')[-1] ,
  \     "" ]) |
  \ endif

command! -nargs=0 Html call ExportToHtml()

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


command! Pubmed call Pubmed()
function! Pubmed()
  let l:saved_reg = @"
  execute "normal! gvy"
  let l:python_arg = @"
  let l:output = system("python $HOME/Documents/Medical/scripts/pubmed.py '" . l:python_arg . "'")
  put =l:output
endfunction
command! Define call Define()
function! Define()
  let l:python_arg = @"
  " Run the Python script and save the output to a variable
  let l:output = system("python $HOME/Documents/Medical/scripts/define.py '" . l:python_arg . "'")
  put =l:output
endfunction
