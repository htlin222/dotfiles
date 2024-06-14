augroup PythonTempate
  autocmd!
  au BufNewFile *.py
        \ call append(0,[
        \ "#!/usr/bin/env python3",
        \ "# -*- coding: utf-8 -*-",
        \ '# title: ' . split(expand('%:r'),'/')[-1],
        \ '# date: "' . split(strftime("%Y-%m-%d").'"','/')[-1], "",
        \ '# author: Hsieh-Ting Lin, the Lizard 🦎',
        \ 'import os',
        \ "def main():",
        \ "    print\('your code here'\)", "","",
        \ "if __name__ == '__main__':",
        \ "    main()"])
augroup END
command! Scholar call Scholar()
function! Scholar()
  execute "normal! gvy"
  let l:python_arg = @"
  let l:output = system("python $HOME/Documents/Medical/scripts/scholar_search.py '" . l:python_arg . "'")
  put =l:output
endfunction
