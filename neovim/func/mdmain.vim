scriptencoding utf-8
augroup creatprevious
  au BufLeave *.md let g:previous=expand('%:t:r')
  " silent execute '!ffplay -v 0 -nodisp -autoexit ~/.config/nvim/lua/custom/media/enter.wav &'
augroup END
" autocmd BufWritePre ~/Documents/Medical/*.md silent! call MySubstituteCommand()
command! -nargs=0 Ali :call Aliasing()
" NB: keymapping here as well
nnoremap <silent> <leader>li :silent! call MySubstituteCommand()<CR>
function! MySubstituteCommand()
    " %s/是\([^:]\)/ 是: \1/g
    " %s/為\([^:]\)/ 為: \1/g
    " %s/在\([^ ]\)/在 ↣ \1/g
    %s/\([^ ]\)不/\1 ✖ 不/g
    %s/\([^ ]\)無/\1 ✖ 無/g
    %s/\([^ ]\)避免/\1 ☢ 避免/g
    %s/\([^ ]\)因此/\1 ∴ 因此/g
    %s/\([^ ]\)所以/\1 ∴ 所以/g
    %s/\([^ ]\)因為/\1 ∵ 因為/g
    %s/\([^ ]\)由於/\1 ∵ 由於/g
    %s/\([^ ]\)沒有/\1 💥 沒有/g
    %s/可以\([^ ]\)/可以 ✔ \1/g
    " uptodate formate ┄
    %s/–/-/g
    %s/—/-/g
    %s/（/ (/g
    %s/）/) /g
    %s/^•/- /g
    %s/^●/- /g
    " %s/與\([^ ]\)/ ↙ 與 ↘ \1/g
    " %s/和\([^ ]\)/ ↙ 和 ↘ \1/g
    " %s/或\([^ ]\)/ ↙ 或 ↘ \1/g
    " %s/並\([^ ]\)/並 〓 \1/g
    %s/造成\([^ ]\)/造成 ↪ \1/g
    %s/產生\([^ ]\)/產生 ↪ \1/g
    %s/包括\([^ ]\)/包括 ≡ \1/g
    %s/上升\([^ ]\)/上升 ↑ \1/g
    %s/增加\([^ ]\)/增加 ↑ \1/g
    %s/下降\([^ ]\)/下降 ↓ \1/g
    %s/減少\([^ ]\)/減少 ↓ \1/g
    %s/降低\([^ ]\)/降低 ↓ \1/g
    %s/。\([^ ]\)/\r- \1/g"
    " -- English -- 英文要注意 單字前後都有 空格
    " %s/ is \([^→]\)/ is → \1/g
    " %s/ then \([^→]\)/ then → \1/g
    " %s/ at \([^↣]\)/ at ↣ \1/g
    " %s/ of \([^↩]\)/ of ↩ \1/g
    " ≡ ⊕ ⊙ ◎ ▲ ■ ★ ✪ ♛ ♟ ☞ ▆▁↝ ↣ ↦ 〓 ❥ ✔ ⒤  ●
endfunction
" au BufWritePre *.md silent! call MyMarkdownLint()
" function! MyMarkdownLint()
  " %s/\n\{3,}/\r\r/g
  " %s/!\[\]/![Figure: ]/g
  " %s/， /，/g
  " %s/。 /。/g
  " /\v([**])(不正確|正確)/**\1**/g
  " %s/\(\*\*\)\@<!\(正確\|不正確\)\(\*\*\)\@!/\1**\2**\3/g
" endfunction

function! MarpYaml()
    call append(0, [
          \ '---',
          \ 'title: "' . split(expand('%:r'),'/')[-1] . '"',
          \ 'date: "' . strftime("%Y-%m-%d") . '"',
          \ 'marp: true',
          \ 'author: Hsieh-Ting Lin',
          \ 'paginate: true',
          \ 'theme: my-theme',
          \ '# headingDivider: 2',
          \ '---',
          \ '',
          \ ])
    call Slug()
    echo '✔建立了Marp簡報' . split(expand('%:r'),'/')[-1] . '🐣'
endfunction

augroup MarkdownFrontMatter
  autocmd!
  autocmd BufNewFile ~/Dropbox/Medical/*.md call CreateMedicalDiary()
  autocmd BufNewFile ~/Dropbox/patients/*.md call CreateRegular()
  autocmd BufNewFile ~/Dropbox/inbox/*.md call CreateRegular()
  autocmd BufNewFile ~/Dropbox/slides/*.md call MarpYaml()
  autocmd BufNewFile ~/Dropbox/blog/*.md call NewBlogPost()
augroup END

function! CreateRegular()
    execute 'silent !ffplay -v 0 -nodisp -autoexit ' . shellescape(expand('$HOME/.config/nvim/lua/custom/media/hit.wav')) . ' &'
    let g:previous = get(g:, 'previous', 'index')
    call append(0, [
          \ '---',
          \ 'title: "' . split(expand('%:r'),'/')[-1] . '"',
          \ 'date: "' . strftime("%Y-%m-%d") . '"',
          \ '---',
          \ '',
          \ '> 🌱 來自: [[' . g:previous . ']] 🧬',
          \ '',
          \ ])
    echo '領域展開🔪伏魔御廚子🍴' . g:previous . '🔀' . split(expand('%:r'),'/')[-1]
endfunction
function! CreateMedicalDiary()
    execute 'silent !ffplay -v 0 -nodisp -autoexit ' . shellescape(expand('$HOME/.config/nvim/lua/custom/media/newmd.mp3')) . ' &'
    let g:previous = get(g:, 'previous', 'index')
    call append(0, [
          \ '---',
          \ 'title: "' . split(expand('%:r'),'/')[-1] . '"',
          \ 'date: "' . strftime("%Y-%m-%d") . '"',
          \ 'enableToc: false',
          \ 'tags:', '    - building',
          \ '---',
          \ '',
          \ '> [!info]',
          \ '>',
          \ '> 🌱 來自: [[' . g:previous . ']]',
          \ '',
          \ ])
    call Slug()
    echo '領域展開🔪伏魔御廚子🍴' . g:previous . '🔀' . split(expand('%:r'),'/')[-1]
endfunction

function! NewBlogPost()
    let g:previous = get(g:, 'previous', 'index')
    call append(0, [
          \ '---',
          \ 'template: post',
          \ 'title: "' . split(expand('%:r'),'/')[-1] . '"',
          \ 'date: "' . strftime("%Y-%m-%d") . '"',
          \ 'draft: True',
          \ 'tags:',
          \ '  - building',
          \ 'category: tutorial',
          \ '---',
          \ '',
          \ ])
" socialImage: /media/JAMA.png
    call Slug()
    echo '登登！可喜可賀！你從🥚' . g:previous . '這條筆記裡 ✔建立了' . split(expand('%:r'),'/')[-1] . '🐣'
endfunction
function! AddDashToVisualLines()
    let save_cursor = getpos('.')
    " Get the selected lines range in Visual Line mode
    let [start_line, end_line] = [line("'<"), line("'>")]
    " Loop through the selected lines
    for line_num in range(start_line, end_line)
        " Get the content of the line without leading/trailing whitespace
        let line_content = substitute(getline(line_num), '^\s*\|\s*$', '', '')

        " Check if the line is not blank and does not start with "- "
        if !empty(line_content) && line_content[0:1] != '- '
            " Add "- " to the beginning of the line
            call setline(line_num, '- ' . getline(line_num))
        endif
    endfor
    call setpos('.', save_cursor)
endfunction
function! AddDashToCurrentLine()
  let line_num = line('.')
  let line_content = substitute(getline(line_num), '^\s*\|\s*$', '', '')
  if col('.') == 1 && !empty(line_content) && line_content[0:1] != '- '
      " Add "- " to the beginning of the line
      call setline(line_num, '- ' . getline(line_num))
endif
endfunction
" NB: here is a key mapping
xnoremap <silent> <C-n> :<C-u>call AddDashToVisualLines()<CR>

function! SubstitutionForCurrentLine()
    let cursor_position = getpos('.')
    normal! 0
    silent! call AddDashToCurrentLine()
    silent! execute 'normal! >>'
    call setpos('.', cursor_position)
    silent! execute "normal! :s/\\.\\s\\([A-Z]\\)/.\\r- \\1/g\<CR>"
    silent! execute "normal! :s/。\\([^ ]\\)/。\\r- \\1/g\<CR>"
endfunction
function! SubstitutionForCurrentLineComma()
    let cursor_position = getpos('.')
    normal! 0
    " silent! execute "normal! >>I- "
    silent! call AddDashToCurrentLine()
    silent! execute 'normal! >>'
    call setpos('.', cursor_position)
    silent! execute "normal! :s/\\,\\s\\([^ ]\\)/,\\r\\t- \\1/g\<CR>"
    silent! execute "normal! :s/、\\([^ ]\\)/、\\r\\t- \\1/g\<CR>"
endfunction
function! SubstitutionForCurrentChineseComma()
    let cursor_position = getpos('.')
    normal! 0
    " silent! execute "normal! >>I- "
    silent! call AddDashToCurrentLine()
    silent! execute 'normal! >>'
    call setpos('.', cursor_position)
    execute "normal! :s/，\\([^ ]\\)/，\\r\\t- \\1/g\<CR>"
    " :s/，\([^ ]\)/，\r\t- \1/g<CR>'
endfunction
function! SubstitutionForCurrentLineSemiColon()
    let cursor_position = getpos('.')
    normal! 0
    silent! call setpos('.', cursor_position)
    silent! call AddDashToCurrentLine()
    silent! execute 'normal! >>'
    silent! execute "normal! :s/\\;\\s\\([^ ]\\)/;\\r\\t- \\1/g\<CR>"
    silent! execute "normal! :s/；\\([^ ]\\)/；\\r\\t- \\1/g\<CR>"
endfunction
function! Aliasing()
    let USERINPUT = input('請輸入你要的Alias名稱: ')
    if USERINPUT == ''
        echo '未輸入Alias名稱，操作已取消。'
        return
    endif
    let g:alias=  USERINPUT
    let current_file = expand('%:r')
    let command = 'ln -s "./' . current_file . '.md" "./' . USERINPUT . '.md"'
    silent! execute '!'. command
    echo 'Alias created successfully!'
    let yaml_ali =  'alias: "' . USERINPUT . '"'
    execute '2pu= yaml_ali'
endfunction

function! AliasingNoPrompt(ali)
    let USERINPUT = a:ali
    let g:alias=  USERINPUT
    let current_file = expand('%:r')
    let command = 'ln -s "./' . current_file . '.md" "./' . USERINPUT . '.md"'
    silent! execute '!'. command
    echo 'Alias created successfully!'
    execute "2pu= 'alias: ' . USERINPUT"
endfunction
command! -nargs=0 Ali :call Aliasing()
" NB: keymapping here as well
nnoremap <silent> <leader>s :call Aliasing()<CR>

" NB: gen TOC
function! Toc()
    let current_file = expand('%:t')
    let command = 'doctoc --title "**Table of contents**" "./' . current_file . '"'
    silent! execute '!'. command
    echo 'TOC created successfully!'
endfunction
" NB: keymapping here as well
nnoremap <silent> <leader>toc :call Toc()<CR>

" NB: In Yaml, if there's building in the tags list, then lint the note
function! CheckYAMLLint()
  if &filetype == 'markdown'
    let first_lines = getline(1, 10)
    if join(first_lines) =~ 'building'
      silent! call MySubstituteCommand()
    endif
  endif
endfunction
augroup YAMLMDLint
  autocmd!
  autocmd BufWritePre *.md call CheckYAMLLint()
augroup END

function! AddPrefix()
    let USERINPUT = input('請輸入你要的prefix名稱，注意最好有個符號當開頭: ')
    let g:prefix=  USERINPUT
    let yaml_prefix =  'prefix: "' . USERINPUT . '"'
    execute '3pu= yaml_prefix'
endfunction

function! AddPrefixNoPrompt(pfx)
    let USERINPUT = a:pfx
    let g:prefix=  USERINPUT
    let yaml_prefix =  'prefix: "' . USERINPUT . '"'
    execute '3pu= yaml_prefix'
endfunction

function! Prefix()
  if &filetype ==? 'markdown'
    let first_lines = getline(1, 10)
    if join(first_lines) =~? 'prefix:'
      let current_file = expand('%:r')
      let command = 'python ~/pyscripts/add_snippet_by_pfx.py "' . current_file . '.md"' . ' ~/.dotfiles/neovim/vscode_snippets/garden.json'
      silent! execute '!'. command
      " execute '!'. command
      echo 'Add Prefix 🥰'
    endif
  endif
endfunction
function! WithAnkiTagThenSentToSimplenote()
  if &filetype == 'markdown'
    let current_file = expand('%:r')
    let command = 'python ~/Dropbox/scripts/add_md_to_sn.py ' . current_file . '.md ' . 'anki'
    silent! execute '!'. command
    echo 'Added this note to simplenote because of anki tag 🥰'
  endif
endfunction
" when save
function! CheckAnki()
  write
  let app_name = "Anki"
  let running = system("pidof " . app_name)
  if running != ''
    echo app_name . " is running."
  else
    let choice = confirm(app_name . " is not running. Open it now?", "&Yes\n&No", 1)
    if choice == 1
      call system("open -g " . app_name)
      echo app_name . " has been opened."
    else
      echo app_name . " was not opened."
    endif
  endif
  if &filetype == 'markdown'
    let app_name = "Anki"
    let current_file = expand('%:r')
    let command = 'python ~/pyscripts/add_md_to_anki.py ' . current_file . '.md'
    silent! execute '!'. command
    echo 'Add To Anki 🤩'
    e
  endif
endfunction
augroup Prefix
  autocmd!
  autocmd BufWritePost *.md call Prefix()
augroup END
augroup CountDay
  autocmd VimEnter */imboard/index.md silent! call Countdown()
augroup END
function! Countdown()
    let command = 'python3 $HOME/quail_template/imboard/countdown.py'
    silent! execute '!'. command
endfunction
" 函數用來保存當前緩衝區的完整路徑為全局變量 g:queue
function! SaveBufferToQueue()
    let current_file = expand('%:p')
    let file_name_with_ext = expand('%:t')
    let file_name_only = fnamemodify(file_name_with_ext, ':r')
    if file_name_with_ext != 'index.md'
        let g:queue = fnameescape(current_file)
        let g:title = file_name_only
        echo 'Current title: ' . g:title
    endif
endfunction
function! InsertFilenameFromQueue()
    if exists('g:queue') && !empty(g:queue)
        let full_path = g:queue
        let dest_dir = expand('%:p:h') . '/'
        let filename_only = fnamemodify(full_path, ':t')
        let new_full_path = dest_dir . filename_only

        " 移動檔案
        if full_path != new_full_path
            echo new_full_path
            call rename(full_path, new_full_path)
        endif
        let current_buffer_name_only = fnamemodify(expand('%:t'), ':r')
        call writefile(['> 👉 from [[' . current_buffer_name_only . ']]'], new_full_path, 'a')

        " 插入檔案名稱到當前緩衝區
        let title = g:title
        let insert_text = '- ✌️  [[' . title . ']]'
        call setreg('z', insert_text)
        normal "zP
        let g:queue = ''
        let g:title = ''
    else
        echo "Nothing in queue"
    endif
endfunction
" 當緩衝區是在 $HOME/Dropbox/inbox/ 和以 .md 結尾，並且你離開該緩衝區時，調用 SaveBufferToQueue 函數
augroup CountDay
  autocmd BufLeave $HOME/Dropbox/inbox/*.md call SaveBufferToQueue()
augroup END
function! SearchGoogle() abort
    normal! gv"ay
    let search_text = getreg('a', 1, 1)[0]
    echo 'searh for ' . search_text
    if empty(search_text)
        echoerr 'No selection found!'
        return
    endif
    silent! execute '!s '. search_text
endfunction
let s:searched = 0
function! SearchForFillarea()
  " 判斷光標是否在尖括號 <> 中的文字上
  let line = getline('.')
  let col = col('.')
  let word = matchstr(line, '<\([^>]*\)>', col - 1)

  " 如果光標在尖括號 <> 中的文字上
  if word != ""
    normal ciw
  else
    " 搜尋並高亮封閉在尖括號中的任何字元
    if s:searched == 0
      execute "/<\\([^>]*\\)>"
      set hlsearch
      let s:searched = 1
    else
      " 如果已經搜尋過，導航至下一個匹配結果
      normal n
    endif
  endif
endfunction
